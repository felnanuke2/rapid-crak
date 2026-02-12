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

## ⚠️ Platform Compatibility

**This project is primarily developed and tested on macOS and iOS.**

While the codebase includes platform-specific directories for Android, Linux, and Windows, **only macOS and iOS have been tested and validated**. If you run this application on other platforms, you may encounter:

- Build or compilation issues
- Runtime errors or crashes
- Performance degradation
- Missing platform-specific features or integrations

**Tested Platforms:**
- ✅ **macOS** - Fully tested and working
- ✅ **iOS Simulator** - Tested and working

**Recommendations:**
- For the best experience, use **macOS or iOS**
- Other platforms (Android, Linux, Windows) may require additional configuration or debugging
- Community contributions for other platform support are welcome!

## 🏗️ Architecture

```
rapid_crak/
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
- **macOS or iOS** (tested platforms)

### Setup

```bash
# Clone repository
git clone <repo_url>
cd rapid_crak

# Install dependencies
flutter pub get

# Install Rust dependencies for macOS
rustup target add aarch64-apple-darwin x86_64-apple-darwin

# Generate Rust bindings
flutter_rust_bridge_codegen generate

# Run app on macOS
flutter run -d macos
```

> **Note:** While setup instructions for other platforms exist below, only macOS and iOS have been tested. Proceed with caution on Android, Linux, and Windows.

## � How to Run

### Requirements

Before running the project, ensure you have the following installed:

1. **Rust Toolchain**
   - [Install Rust](https://rustup.rs/) from rustup.rs
   - Verify installation: `rustc --version` and `cargo --version`

2. **Flutter SDK**
   - [Install Flutter](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter doctor`

3. **flutter_rust_bridge CLI**
   ```bash
   cargo install flutter_rust_bridge_codegen
   ```

### Running with VS Code (Recommended)

The project is configured with `.vscode/launch.json` and `.vscode/tasks.json` to ensure safe and automated execution:

#### Step 1: Build Rust Bindings
Before launching for the first time, generate Rust bindings:

```bash
flutter_rust_bridge_codegen generate
```

Or use the configured VS Code task:
- Press `Cmd+Shift+B` (macOS) or `Ctrl+Shift+B` (Linux/Windows)
- Select **flutter_rust_bridge codegen**

#### Step 2: Launch the App
- Press `F5` to start debugging in VS Code
- Or use **Run → Start Debugging** from the menu

**What happens automatically:**
- ✅ `flutter_rust_bridge codegen` task runs (pre-launch task)
- ✅ Rust bindings are generated
- ✅ Flutter app compiles with the compiled Rust native library
- ✅ App launches on connected device/emulator

#### Step 3: Select Target Platform
When launching, choose your target platform:
- `macos` - **macOS (✅ Tested)**
- `ios` - **iOS device or simulator (✅ Tested)**
- `android` - Android device or emulator ⚠️ *Not tested*
- `web` - Web browser ⚠️ *Not tested*
- `linux` - Linux desktop ⚠️ *Not tested*
- `windows` - Windows desktop ⚠️ *Not tested*

> **Important:** Only macOS and iOS have been tested. Other platforms may have compatibility issues.

#### Example: Run on macOS (Tested)
```bash
flutter run -d macos
```

#### Example: Run on iOS Simulator (Tested)
```bash
flutter run -d "iPhone 15"
```

### Running from Terminal

#### Full Setup (First Time - macOS/iOS)
```bash
# 1. Install Rust dependencies for Apple platforms
rustup target add aarch64-apple-darwin x86_64-apple-darwin  # macOS
rustup target add aarch64-apple-ios x86_64-apple-ios        # iOS

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate Rust bindings
flutter_rust_bridge_codegen generate

# 4. Run the app
flutter run -d macos      # macOS
# or
flutter run -d "iPhone 15"  # iOS Simulator
```

#### For Other Platforms (⚠️ Not Tested)
```bash
# Linux (use at your own risk)
rustup target add aarch64-linux-gnu
flutter run -d linux

# Windows (use at your own risk)
rustup target add x86_64-pc-windows-msvc
flutter run -d windows
```

#### Quick Run (After Initial Setup)
```bash
flutter run -d macos
```

### How It Works Safely

1. **Build System Integration**
   - `flutter_rust_bridge_codegen generate` automatically compiles Rust code to native libraries
   - Builds are cached to avoid unnecessary recompilation
   - Each platform gets its native binary (Mach-O for macOS, ELF for Linux, PE for Windows, etc.)

2. **Pre-launch Task in VS Code**
   - The debugger automatically runs `flutter_rust_bridge codegen` before launching
   - Ensures bindings are always up-to-date with Rust source changes
   - Prevents "missing library" errors

3. **Error Handling**
   - If the Rust build fails, the error message clearly indicates the issue
   - Check the terminal output for specific compilation errors
   - Rebuild bindings if you modify any Rust code

### Troubleshooting

**"Rust tool not found"**
```bash
rustup update
cargo install flutter_rust_bridge_codegen
```

**"flutter_rust_bridge_codegen: command not found"**
```bash
# Add Cargo bin to PATH
export PATH="$HOME/.cargo/bin:$PATH"
```

**"Native library not found" or crash on startup**
```bash
# Regenerate bindings and rebuild
flutter clean
flutter_rust_bridge_codegen generate
flutter pub get
flutter run -d macos
```

**Slow first build**
- Initial builds take longer due to Rust compilation
- Subsequent builds are faster (incremental compilation)
- Use `--release` for optimized builds: `flutter run --release -d macos`

## �📖 Usage

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

> **Note:** Benchmarks below are estimates based on testing on **macOS and iOS**. Other platforms may show different results.

### Example Apple Silicon Mac (M1/M2)

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

- **Showcase only**: This project is for educational/demo purposes. Only use it on ZIP files you own or have explicit permission to test.
- **ZipCrypto limitation**: Only supports traditional ZIP encryption (not AES)
- **Dictionary attack**: Pre-loaded with common passwords (RockYou.txt)
- **False positives**: ~1/256 rate from fast path, eliminated by full verification
- **No logging**: Passwords are never stored or logged

## 🚀 Future Enhancements

- [ ] AES encryption support
- [ ] GPU acceleration (Metal/Vulkan) — planned, not implemented yet
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
