//! ZIP password cracking module.
//!
//! Provides efficient algorithms for recovering passwords from ZipCrypto-protected
//! archives. Employs a multi-phase approach:
//!
//! 1. **Fast Header Validation**: Uses accumulated CRC32 state to quickly reject
//!    invalid passwords without decompression. ~1/256 false positive rate.
//!
//! 2. **Full Verification**: Candidates passing the fast path are validated by
//!    actually decompressing file contents and verifying CRC32, eliminating collisions.
//!
//! 3. **Parallel Processing**: Both dictionary and brute force attacks exploit
//!    multi-core systems via rayon for significant speedup.
//!
//! ## Attack Phases
//!
//! - **Dictionary Attack**: Tests built-in RockYou.txt password list in parallel chunks
//! - **Brute Force**: Generates passwords of increasing length using configurable character sets
//!
//! ## Performance Considerations
//!
//! - CRC32 operations are inlined for maximum throughput
//! - Atomic operations use relaxed ordering where safe to reduce contention
//! - Progress tracking runs on a separate thread to avoid blocking worker threads
//! - Chunk-based parallelism maintains cache locality

use std::io::Read;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Arc, OnceLock};

use anyhow::{anyhow, Result};
use rayon::prelude::*;

use crate::frb_generated::StreamSink;

/// Global pause state for cracking operations.
static PAUSE_FLAG: OnceLock<Arc<AtomicBool>> = OnceLock::new();

/// Retrieves or initializes the global pause flag.
fn get_pause_flag() -> Arc<AtomicBool> {
    PAUSE_FLAG
        .get_or_init(|| Arc::new(AtomicBool::new(false)))
        .clone()
}

/// Pauses or resumes the cracking operation.
pub fn set_pause(paused: bool) {
    get_pause_flag().store(paused, Ordering::Relaxed);
}

/// Returns whether the cracking operation is currently paused.
pub fn is_paused() -> bool {
    get_pause_flag().load(Ordering::Relaxed)
}

/// Blocks the current thread until the cracking operation is resumed.
#[inline]
fn wait_if_paused() {
    const PAUSE_CHECK_INTERVAL: std::time::Duration = std::time::Duration::from_millis(50);
    let pause_flag = get_pause_flag();
    while pause_flag.load(Ordering::Relaxed) {
        std::thread::sleep(PAUSE_CHECK_INTERVAL);
    }
}

/// Represents the current progress of a cracking operation.
#[derive(Debug, Clone)]
pub struct CrackProgress {
    /// Total password attempts made so far.
    pub attempts: u64,
    /// The most recently tested password.
    pub current_password: String,
    /// Elapsed time in seconds since the operation started.
    pub elapsed_seconds: u64,
    /// Estimated passwords tested per second.
    pub passwords_per_second: f64,
    /// Current phase of the operation (e.g., "Dictionary", "Running", "Done").
    pub phase: String,
}

/// Configuration for password cracking operations.
#[derive(Debug, Clone)]
pub struct CrackConfig {
    /// Minimum length for generated passwords.
    pub min_length: usize,
    /// Maximum length for generated passwords.
    pub max_length: usize,
    /// Include lowercase letters in character set.
    pub use_lowercase: bool,
    /// Include uppercase letters in character set.
    pub use_uppercase: bool,
    /// Include digits in character set.
    pub use_numbers: bool,
    /// Include special symbols in character set.
    pub use_symbols: bool,
    /// Use dictionary attack before brute force.
    pub use_dictionary: bool,
    /// Custom words to include in dictionary attack.
    pub custom_words: Vec<String>,
}

/// Parameters extracted from a ZIP archive's encryption header.
/// Used for fast password validation without decompression.
#[derive(Clone, Copy, Debug)]
struct CryptoHeader {
    /// The 12-byte encryption header from the ZIP.
    header: [u8; 12],
    /// Check byte derived from the CRC32 or modification time.
    check_byte: u8,
}

/// Pre-computed CRC32 lookup table for efficient polynomial calculation.
/// Implements the standard ZIP CRC32 polynomial.
const CRC32_TABLE: [u32; 256] = define_crc32_table();

/// Generates the CRC32 lookup table at compile time.
const fn define_crc32_table() -> [u32; 256] {
    let mut table = [0u32; 256];
    let mut i = 0;
    while i < 256 {
        let mut crc = i as u32;
        let mut j = 0;
        while j < 8 {
            crc = if (crc & 1) != 0 {
                (crc >> 1) ^ 0xEDB88320
            } else {
                crc >> 1
            };
            j += 1;
        }
        table[i] = crc;
        i += 1;
    }
    table
}

/// Efficiently stores a character set as a fixed-size array with bounds checking.
/// Avoids heap allocations and maintains a tight memory footprint.
#[derive(Clone)]
struct CharacterSet {
    data: [u8; 94],  // Maximum possible ASCII printable characters
    len: usize,
}

impl CharacterSet {
    /// Constructs a character set based on the provided configuration.
    fn new(config: &CrackConfig) -> Self {
        let mut data = [0u8; 94];
        let mut len = 0usize;

        if config.use_numbers {
            for b in b'0'..=b'9' {
                data[len] = b;
                len += 1;
            }
        }
        if config.use_lowercase {
            for b in b'a'..=b'z' {
                data[len] = b;
                len += 1;
            }
        }
        if config.use_uppercase {
            for b in b'A'..=b'Z' {
                data[len] = b;
                len += 1;
            }
        }
        if config.use_symbols {
            for &b in b"!@#$%^&*()-_=+[]{}|;:'\",.<>?/~`\\" {
                data[len] = b;
                len += 1;
            }
        }

        Self { data, len }
    }

    /// Returns the character set as a slice.
    #[inline(always)]
    fn chars(&self) -> &[u8] {
        &self.data[..self.len]
    }
}

/// Validates a password by attempting to decompress and verify CRC32 of the ZIP archive.
///
/// This function performs the slow path verification: after a fast header check has
/// identified a candidate password, this function validates it by actually decompressing
/// the contents and checking the CRC32. This eliminates false positives from the fast path.
///
/// # Arguments
/// * `file_bytes` - The raw ZIP file contents
/// * `password` - The password to validate
///
/// # Returns
/// `true` if the password successfully decompresses the file and passes CRC32 verification
fn verify_password_integrity(file_bytes: &[u8], password: &str) -> bool {
    let cursor = std::io::Cursor::new(file_bytes);
    let mut archive = match zip::ZipArchive::new(cursor) {
        Ok(a) => a,
        Err(_) => return false,
    };

    for i in 0..archive.len() {
        let file_result = archive.by_index_decrypt(i, password.as_bytes());

        match file_result {
            Ok(Ok(mut file)) => {
                // File opened successfully. Now verify by reading it completely.
                // If reading fails, it's a false positive (hash collision).
                let mut buffer = [0u8; 4096];
                let mut is_valid = true;

                loop {
                    match file.read(&mut buffer) {
                        Ok(0) => break,
                        Ok(_) => continue,
                        Err(_) => {
                            is_valid = false;
                            break;
                        }
                    }
                }

                if is_valid {
                    return true;
                }
            }
            _ => continue,
        }
    }
    false
}

/// Extracts the encryption header from a ZIP file.
///
/// Scans the ZIP file for the Local File Header and returns the crypto header
/// and check byte needed for fast password validation. Returns an error if the
/// file uses unsupported encryption methods (e.g., WinZip AES).
///
/// # Arguments
/// * `data` - Raw ZIP file contents
///
/// # Returns
/// * `Ok(CryptoHeader)` if a valid ZipCrypto header is found
/// * `Err` if no ZipCrypto headers found or unsupported encryption is detected
fn locate_zip_crypto_header(data: &[u8]) -> Result<CryptoHeader> {
    const LOCAL_FILE_HEADER_SIGNATURE: [u8; 4] = [0x50, 0x4B, 0x03, 0x04]; // "PK\x03\x04"
    const MIN_HEADER_SIZE: usize = 30;
    const ENCRYPTION_FLAG_BIT: u16 = 0x01;
    const AES_ENCRYPTION_METHOD: u16 = 99;

    let mut cursor = 0;

    while cursor < data.len().saturating_sub(MIN_HEADER_SIZE) {
        if data[cursor..cursor + 4] != LOCAL_FILE_HEADER_SIGNATURE {
            cursor += 1;
            continue;
        }

        // Parse the Local File Header structure
        let flags = u16::from_le_bytes([data[cursor + 6], data[cursor + 7]]);

        // Skip non-encrypted files
        if (flags & ENCRYPTION_FLAG_BIT) == 0 {
            cursor += 1;
            continue;
        }

        // Reject unsupported encryption methods
        let method = u16::from_le_bytes([data[cursor + 8], data[cursor + 9]]);
        if method == AES_ENCRYPTION_METHOD {
            return Err(anyhow!(
                "WinZip AES encryption detected. Fast path not supported."
            ));
        }

        let mod_time = u16::from_le_bytes([data[cursor + 10], data[cursor + 11]]);
        let crc = u32::from_le_bytes([
            data[cursor + 14],
            data[cursor + 15],
            data[cursor + 16],
            data[cursor + 17],
        ]);
        let fname_len = u16::from_le_bytes([data[cursor + 26], data[cursor + 27]]) as usize;
        let extra_len = u16::from_le_bytes([data[cursor + 28], data[cursor + 29]]) as usize;

        let header_start = cursor + MIN_HEADER_SIZE + fname_len + extra_len;
        if header_start + 12 > data.len() {
            return Err(anyhow!("Truncated ZIP file"));
        }

        let mut header = [0u8; 12];
        header.copy_from_slice(&data[header_start..header_start + 12]);

        // Determine check byte from file modification time or CRC
        let check_byte = if (flags & (1 << 3)) != 0 {
            (mod_time >> 8) as u8
        } else {
            (crc >> 24) as u8
        };

        return Ok(CryptoHeader { header, check_byte });
    }

    Err(anyhow!("No ZipCrypto encrypted files found in archive"))
}

/// Tests a single password against a ZIP file using fast header validation.
///
/// # Arguments
/// * `file_bytes` - Raw ZIP file contents
/// * `password` - Password to test
///
/// # Returns
/// * `Ok(true)` if the password is valid
/// * `Ok(false)` if the password is invalid
/// * `Err` if the ZIP file is malformed or uses unsupported encryption
pub fn test_zip_password(file_bytes: Vec<u8>, password: String) -> Result<bool> {
    let header = locate_zip_crypto_header(&file_bytes)?;
    Ok(validate_password_header(&header, password.as_bytes()))
}

/// Estimates the total number of possible password combinations given a config.
///
/// # Arguments
/// * `config` - Password generation configuration
///
/// # Returns
/// The total number of possible combinations, with overflow protection.
pub fn estimate_combinations(config: CrackConfig) -> Result<u64> {
    let charset = CharacterSet::new(&config);
    let base = charset.chars().len() as u64;

    let mut total: u64 = 0;
    for length in config.min_length..=config.max_length {
        let combinations = base.saturating_pow(length as u32);
        total = total.saturating_add(combinations);
    }

    Ok(total)
}

/// Attempts to crack a ZIP password using dictionary and brute force attacks.
///
/// This function employs a two-phase approach:
/// 1. **Dictionary Attack**: Tests a built-in password dictionary (RockYou.txt) in parallel
/// 2. **Brute Force**: Systematically generates and tests passwords of increasing length
///
/// Each candidate is validated using a fast header check, then confirmed with full
/// decompression to eliminate false positives. Progress is reported via a stream sink.
///
/// # Arguments
/// * `file_bytes` - Raw ZIP file contents
/// * `config` - Password generation and attack configuration
/// * `progress_sink` - Stream for reporting progress updates
///
/// # Returns
/// * `Ok(())` when the operation completes (password found or exhausted)
/// * `Err` if the ZIP file is malformed or uses unsupported encryption
pub fn crack_zip_password(
    file_bytes: Vec<u8>,
    config: CrackConfig,
    progress_sink: StreamSink<CrackProgress>,
) -> Result<()> {
    let start_time = std::time::Instant::now();

    let header = match locate_zip_crypto_header(&file_bytes) {
        Ok(h) => h,
        Err(e) => {
            report_progress_error(&progress_sink, &format!("Cannot perform fast path: {}", e));
            return Ok(());
        }
    };

    let attempts = Arc::new(AtomicU64::new(0));
    let found = Arc::new(AtomicBool::new(false));
    let current_sample = Arc::new(std::sync::RwLock::new(String::new()));

    // Skip dictionary for numeric-only passwords since brute force is faster
    let use_dictionary = config.use_dictionary
        && !(config.use_numbers && !config.use_lowercase && !config.use_uppercase && !config.use_symbols);

    if use_dictionary {
        if let Some(password) = attempt_dictionary_attack(
            &file_bytes,
            &header,
            &attempts,
            &found,
            &current_sample,
            &progress_sink,
        ) {
            send_success(&progress_sink, &password, &attempts, start_time);
            return Ok(());
        }
    }

    // Proceed to brute force if dictionary didn't find anything
    attempt_brute_force(
        &file_bytes,
        &config,
        &header,
        &attempts,
        &found,
        &current_sample,
        &progress_sink,
        start_time,
    )
}

/// Performs a dictionary-based attack on the ZIP file.
///
/// Tests passwords from the RockYou.txt dictionary in parallel. Uses the fast path
/// for initial validation and full decompression for confirmation.
///
/// Returns the password if found, or None if exhausted.
fn attempt_dictionary_attack(
    file_bytes: &[u8],
    header: &CryptoHeader,
    attempts: &Arc<AtomicU64>,
    found: &Arc<AtomicBool>,
    current_sample: &Arc<std::sync::RwLock<String>>,
    progress_sink: &StreamSink<CrackProgress>,
) -> Option<String> {
    const DICTIONARY_CHUNK_SIZE: usize = 1024 * 1024; // 1MB chunks
    const PROGRESS_UPDATE_INTERVAL: u64 = 20000;

    let _ = progress_sink.add(CrackProgress {
        attempts: 0,
        current_password: "Scanning dictionary...".to_string(),
        elapsed_seconds: 0,
        passwords_per_second: 0.0,
        phase: "Dictionary".to_string(),
    });

    const ROCKYOU_BYTES: &[u8] = include_bytes!("rockyou.txt");
    let chunks: Vec<&[u8]> = ROCKYOU_BYTES.chunks(DICTIONARY_CHUNK_SIZE).collect();

    chunks.into_par_iter().find_map_any(|chunk| {
        let mut remaining = chunk;
        let mut local_count = 0u64;

        while let Some(newline_pos) = remaining.iter().position(|&b| b == b'\n') {
            if found.load(Ordering::Relaxed) {
                return None;
            }

            let line = &remaining[..newline_pos];
            let pwd_bytes = line.strip_suffix(b"\r").unwrap_or(line);

            // Fast path: header check
            if validate_password_header(header, pwd_bytes) {
                let candidate = String::from_utf8_lossy(pwd_bytes).to_string();
                // Slow path: full verification
                if verify_password_integrity(file_bytes, &candidate) {
                    found.store(true, Ordering::SeqCst);
                    return Some(candidate);
                }
            }

            local_count += 1;
            if local_count % PROGRESS_UPDATE_INTERVAL == 0 {
                attempts.fetch_add(PROGRESS_UPDATE_INTERVAL, Ordering::Relaxed);
                if let Ok(mut s) = current_sample.write() {
                    *s = String::from_utf8_lossy(pwd_bytes).to_string();
                }
            }

            remaining = &remaining[newline_pos + 1..];
        }

        let remainder = local_count % PROGRESS_UPDATE_INTERVAL;
        if remainder > 0 {
            attempts.fetch_add(remainder, Ordering::Relaxed);
        }

        None
    })
}

/// Performs a brute force attack on the ZIP file.
///
/// Systematically generates and tests passwords of increasing length using
/// the configured character set. Uses parallel chunks for improved throughput.
fn attempt_brute_force(
    file_bytes: &[u8],
    config: &CrackConfig,
    header: &CryptoHeader,
    attempts: &Arc<AtomicU64>,
    found: &Arc<AtomicBool>,
    current_sample: &Arc<std::sync::RwLock<String>>,
    progress_sink: &StreamSink<CrackProgress>,
    start_time: std::time::Instant,
) -> Result<()> {
    const CHUNK_SIZE: u64 = 65536;
    const CHECK_INTERVAL: u64 = 0x2710; // 10000 in hex
    const PROGRESS_UPDATE_INTERVAL: u64 = 20000;

    let charset = CharacterSet::new(config);
    let progress_thread = spawn_progress_reporter(
        Arc::clone(attempts),
        Arc::clone(found),
        Arc::clone(current_sample),
        progress_sink.clone(),
    );

    let charset_bytes = charset.chars();

    for length in config.min_length..=config.max_length {
        if found.load(Ordering::Relaxed) {
            break;
        }

        let total = (charset_bytes.len() as u64).pow(length as u32);
        let num_chunks = (total + CHUNK_SIZE - 1) / CHUNK_SIZE;

        let found_password = (0..num_chunks).into_par_iter().find_map_any(|chunk_idx| {
            if found.load(Ordering::Relaxed) {
                return None;
            }

            let start_idx = chunk_idx * CHUNK_SIZE;
            let end_idx = (start_idx + CHUNK_SIZE).min(total);
            let mut pwd_buffer = vec![0u8; length];
            let mut local_attempts = 0u64;

            index_to_password(start_idx, charset_bytes, &mut pwd_buffer);

            for _ in start_idx..end_idx {
                // Periodic checks for pause and completion
                if (local_attempts & CHECK_INTERVAL) == 0 {
                    if found.load(Ordering::Relaxed) {
                        return None;
                    }
                    wait_if_paused();
                }

                // Fast path validation
                if validate_password_header(header, &pwd_buffer) {
                    let candidate = String::from_utf8_lossy(&pwd_buffer).to_string();
                    // Slow path verification
                    if verify_password_integrity(file_bytes, &candidate) {
                        found.store(true, Ordering::Relaxed);
                        attempts.fetch_add(local_attempts, Ordering::Relaxed);
                        return Some(candidate);
                    }
                }

                advance_password(&mut pwd_buffer, charset_bytes);
                local_attempts += 1;

                if local_attempts % PROGRESS_UPDATE_INTERVAL == 0 {
                    attempts.fetch_add(PROGRESS_UPDATE_INTERVAL, Ordering::Relaxed);
                    if let Ok(mut s) = current_sample.write() {
                        *s = String::from_utf8_lossy(&pwd_buffer).to_string();
                    }
                }
            }

            let remainder = local_attempts % PROGRESS_UPDATE_INTERVAL;
            if remainder > 0 {
                attempts.fetch_add(remainder, Ordering::Relaxed);
            }

            None
        });

        if let Some(pwd) = found_password {
            let _ = progress_thread.join();
            send_success(progress_sink, &pwd, attempts, start_time);
            return Ok(());
        }
    }

    found.store(true, Ordering::Relaxed);
    let _ = progress_thread.join();
    Ok(())
}

/// Validates a password using the ZipCrypto header check algorithm.
///
/// Implements the fast path validation: computes the encryption keys and checks
/// them against the stored header. This has a ~1/256 false positive rate and must
/// be confirmed with full decompression.
/// 
/// Time complexity: O(n) where n is password length. No heap allocations.
#[inline(always)]
fn validate_password_header(header: &CryptoHeader, password: &[u8]) -> bool {
    // ZipCrypto initial key values
    let mut k0 = 0x12345678u32;
    let mut k1 = 0x23456789u32;
    let mut k2 = 0x34567890u32;

    // Update keys with password
    for &byte in password {
        update_crypto_keys(&mut k0, &mut k1, &mut k2, byte);
    }

    // Validate against stored header
    for i in 0..11 {
        let temp = (k2 | 2) & 0xFFFF;
        let key_byte = ((temp.wrapping_mul(temp ^ 1)) >> 8) as u8;
        let decrypted = header.header[i] ^ key_byte;
        update_crypto_keys(&mut k0, &mut k1, &mut k2, decrypted);
    }

    // Final check byte
    let temp = (k2 | 2) & 0xFFFF;
    let key_byte = ((temp.wrapping_mul(temp ^ 1)) >> 8) as u8;
    (header.header[11] ^ key_byte) == header.check_byte
}

/// Updates the ZipCrypto internal keys for one byte.
///
/// This is the core of the ZipCrypto algorithm. Keys are updated using CRC32
/// and 32-bit arithmetic operations.
#[inline(always)]
fn update_crypto_keys(k0: &mut u32, k1: &mut u32, k2: &mut u32, byte: u8) {
    let index0 = ((*k0 ^ byte as u32) & 0xFF) as usize;
    *k0 = (*k0 >> 8) ^ CRC32_TABLE[index0];
    *k1 = k1.wrapping_add(*k0 as u8 as u32);
    *k1 = k1.wrapping_mul(134775813).wrapping_add(1);
    let index2 = ((*k2 ^ (*k1 >> 24)) & 0xFF) as usize;
    *k2 = (*k2 >> 8) ^ CRC32_TABLE[index2];
}

/// Reports an error message to the progress stream.
fn report_progress_error(sink: &StreamSink<CrackProgress>, message: &str) {
    let _ = sink.add(CrackProgress {
        attempts: 0,
        current_password: message.to_string(),
        elapsed_seconds: 0,
        passwords_per_second: 0.0,
        phase: "Error".to_string(),
    });
}

/// Reports successful password discovery.
fn send_success(
    sink: &StreamSink<CrackProgress>,
    password: &str,
    attempts: &Arc<AtomicU64>,
    start: std::time::Instant,
) {
    let elapsed = start.elapsed().as_secs();
    let _ = sink.add(CrackProgress {
        attempts: attempts.load(Ordering::Relaxed),
        current_password: password.to_string(),
        elapsed_seconds: elapsed,
        passwords_per_second: 0.0,
        phase: "Done".to_string(),
    });
}

/// Spawns a background thread that periodically reports cracking progress.
fn spawn_progress_reporter(
    attempts: Arc<AtomicU64>,
    found: Arc<AtomicBool>,
    current_sample: Arc<std::sync::RwLock<String>>,
    progress_sink: StreamSink<CrackProgress>,
) -> std::thread::JoinHandle<()> {
    const REPORT_INTERVAL: std::time::Duration = std::time::Duration::from_millis(500);

    std::thread::spawn(move || {
        let start = std::time::Instant::now();
        loop {
            std::thread::sleep(REPORT_INTERVAL);
            if found.load(Ordering::Relaxed) {
                break;
            }

            let total_attempts = attempts.load(Ordering::Relaxed);
            let elapsed_secs = start.elapsed().as_secs_f64();
            let sample = current_sample
                .read()
                .ok()
                .map(|s| s.clone())
                .unwrap_or_default();

            let pps = if elapsed_secs > 0.0 {
                total_attempts as f64 / elapsed_secs
            } else {
                0.0
            };

            let _ = progress_sink.add(CrackProgress {
                attempts: total_attempts,
                current_password: sample,
                elapsed_seconds: elapsed_secs as u64,
                passwords_per_second: pps,
                phase: "Running".to_string(),
            });
        }
    })
}

/// Initializes a password buffer to a specific index in the character space.
///
/// Converts a linear index into a password by treating it as a base-n number
/// where n is the character set size.
#[inline(always)]
fn index_to_password(mut index: u64, charset: &[u8], buffer: &mut [u8]) {
    let base = charset.len() as u64;
    for i in (0..buffer.len()).rev() {
        buffer[i] = charset[(index % base) as usize];
        index /= base;
    }
}

/// Increments a password buffer to the next candidate.
///
/// Treats the buffer as a base-n number and increments it, where n is the
/// character set size. Wraps around to maintain the same length.
#[inline(always)]
fn advance_password(buffer: &mut [u8], charset: &[u8]) {
    let last_char = charset[charset.len() - 1];
    for i in (0..buffer.len()).rev() {
        if buffer[i] == last_char {
            buffer[i] = charset[0];
        } else {
            let pos = charset.iter().position(|&c| c == buffer[i]).unwrap_or(0);
            buffer[i] = charset[pos + 1];
            return;
        }
    }
}