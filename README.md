# 🔐 Bruteforce Doc Break - ZIP Password Cracker

**A high-performance Flutter + Rust application for recovering passwords from ZipCrypto-protected archives.**

## 🎯 Features

### ⚡ Advanced Password Cracking
- **Multi-phase validation**: Fast header check (~1/256 false positive rate) + full decompression verification
- **Parallel processing**: Leverages all CPU cores via Rayon for maximum throughput
- **Dictionary attack**: Tests RockYou.txt password list in parallel chunks
- **Brute force attack**: Systematically generates and tests passwords of increasing length
- **Configurable charset**: Numbers, lowercase, uppercase, special symbols
- **Pause/Resume**: Atomic-based pause control without blocking worker threads
- **Real-time progress**: Separate reporter thread updates UI every 500ms

### 🚀 Performance
- **20,000 - 50,000+ passwords/second** (depends on device CPU cores)
- **Optimized CRC32**: Inlined operations for maximum throughput
- **Zero heap allocations**: Fixed-size character sets and password buffers
- **Chunk-based parallelism**: Maintains cache locality across cores

### 🎨 Modern UI
- Dark theme with technical aesthetic (Rust orange + Matrix green)
- Real-time dashboard: speed, attempts, elapsed time
- Console-style password log
- Responsive state management with Provider

## 🏗️ Architecture

```
bruteforce_doc_break/
├── rust/                           # High-performance backend
│   ├── src/api/password_cracker.rs # Core cracking algorithm
│   ├── Cargo.toml                  # Dependencies: rayon, zip, anyhow
│   └── target/                     # Compiled binaries
│
├── lib/                            # Flutter frontend
│   ├── features/password_cracker/
│   │   ├── domain/
│   │   │   ├── entities/           # Data models (CrackConfig, CrackProgress)
│   │   │   └── services/           # Rust bridge service
│   │   └── presentation/
│   │       ├── screens/            # Import → Config → Execution → Result
│   │       ├── widgets/            # Reusable UI components
│   │       └── state/              # Provider state management
│   ├── core/
│   │   ├── theme/                  # Colors, typography, material theme
│   │   ├── utils/                  # Formatters, validators
│   │   ├── extensions/             # Dart extensions
│   │   └── domain/entities/        # Shared models
│   └── services/                   # File picker, native services
│
└── android/, ios/, web/, linux/   # Platform-specific code
```

## 🔧 Installation

### Prerequisites
- Flutter SDK 3.x+
- Rust toolchain 1.70+
- Cargo
- flutter_rust_bridge CLI

### Setup

```bash
# Clone repository
git clone <repo_url>
cd bruteforce_doc_break

# Install dependencies
flutter pub get

# Install Rust dependencies (if not already done)
rustup target add aarch64-apple-darwin x86_64-apple-darwin

# Generate Rust bindings
flutter_rust_bridge_codegen generate

# Run app
flutter run -d macos
```

## 📖 Usage

### Basic Workflow

1. **Import File**: Select a `.zip` file protected with ZipCrypto encryption
2. **Configure Attack**: Set character set and password length constraints
3. **Execute**: Watch real-time progress on the dashboard
4. **Result**: View recovered password or error status

### Configuration Options

```dart
CrackConfig(
  minLength: 1,      // Minimum password length
  maxLength: 8,      // Maximum password length
  useLowercase: true,    // Include a-z
  useUppercase: false,   // Include A-Z
  useNumbers: true,      // Include 0-9
  useSymbols: false,     // Include !@#$%^&*()-_=+...
  useDictionary: true,   // Test common passwords first
  customWords: [],       // Additional custom words
)
```

## 🧪 Testing

### Create a test ZIP file

```bash
# Create test file
echo "Secret content" > test.txt

# Create encrypted ZIP (password: 'abc')
zip -e test_password.zip test.txt
# Enter password when prompted

# Verify encryption
unzip -l test_password.zip
```

### Run with Test File

1. Launch app: `flutter run -d macos`
2. Select the test ZIP file
3. Configure: min=3, max=3, lowercase+numbers enabled
4. Start attack → Should find password in seconds

## 📊 Performance Benchmarks

### iPhone 14 Pro (6 cores)

| Config | Charset | Combinations | Time |
|--------|---------|-------------|------|
| 3 digits | 0-9 | 1,000 | ~50ms |
| 4 lowercase | a-z | 456,976 | ~10s |
| 4 alphanumeric | a-z,0-9 | 1,679,616 | ~30s |
| 5 alphanumeric | a-z,0-9 | 60,466,176 | ~30min |

## 🏛️ Design Principles

### Clean Architecture
- **Separation of Concerns**: Platform layer → Feature layer → Domain layer
- **Single Responsibility**: Each class has one reason to change
- **Testability**: Dependency injection via Provider

### SOLID Principles
- **S**: Formatters, validators, services each do one thing
- **O**: Widget composition for extensibility
- **L**: Providers implement common interface patterns
- **I**: Lean, focused service contracts
- **D**: Depend on abstractions (Provider) not concrete implementations

### Performance Optimizations
- Compile release builds: `flutter run --release`
- Rayon parallelization across all CPU cores
- Atomic operations with relaxed ordering
- CRC32 table pre-computed at compile time
- No runtime allocations in hot paths

## 🔒 Security Notes

- **ZipCrypto limitation**: Only supports traditional ZIP encryption (not AES)
- **Dictionary attack**: Pre-loaded with common passwords (RockYou.txt)
- **False positives**: ~1/256 rate from fast path, eliminated by full verification
- **No logging**: Passwords are never stored or logged

## 🚀 Future Enhancements

- [ ] AES encryption support
- [ ] GPU acceleration (Metal/Vulkan)
- [ ] Cloud-based wordlist integration
- [ ] Batch processing multiple files
- [ ] Attack session persistence
- [ ] Custom wordlist import
- [ ] Progress export/resume

## 📚 Resources

- [ZipCrypto Algorithm](https://en.wikipedia.org/wiki/Zip_(file_format)#Encryption)
- [Rayon Documentation](https://docs.rs/rayon/)
- [Flutter Best Practices](https://flutter.dev/docs)
- [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/)

## 📝 License

MIT License - See LICENSE file for details

---

**Developed with ❤️ using Flutter + Rust**
