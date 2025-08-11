# VieShare Remote Desktop

VieShare is a cross-platform remote desktop application built with Rust and Flutter. It provides secure, high-performance remote access with features like file transfer, audio streaming, terminal access, and multi-platform support.

## Features

- **Remote Desktop Control**: Full desktop access with keyboard and mouse control
- **File Transfer**: Secure file transfer between connected devices
- **Audio Streaming**: Real-time audio transmission during remote sessions
- **Terminal Access**: Built-in terminal for command-line operations
- **Cross-Platform**: Supports Windows, macOS, Linux, Android, and iOS
- **Security**: End-to-end encryption with customizable security settings
- **Hardware Acceleration**: Optional hardware video encoding/decoding support
- **Gaming Optimizations**: Specialized features for gaming and low-latency scenarios

## Architecture

### Core Components
- **Rust Backend** (`src/`): Core application logic, networking, and system integration
- **Flutter UI** (`flutter/`): Modern cross-platform user interface
- **Native Libraries** (`libs/`): Platform-specific implementations for screen capture, input handling, and codecs

### Key Libraries
- `libs/hbb_common/`: Video codec, configuration, network protocols, and file transfer
- `libs/scrap/`: Screen capture functionality across platforms
- `libs/enigo/`: Cross-platform keyboard and mouse input simulation
- `libs/clipboard/`: Advanced clipboard management with file support

## Quick Start

### Prerequisites
- Rust 1.75+ 
- Flutter SDK 3.1+
- Platform-specific dependencies (see [Build Requirements](#build-requirements))

### Desktop Application
```bash
# Build and run desktop application
cargo run

# Or build with Flutter UI
python3 build.py --flutter

# Release build
cargo build --release
```

### Mobile Applications
```bash
# Android
cd flutter && flutter build android

# iOS  
cd flutter && flutter build ios

# Run in development mode
cd flutter && flutter run
```

## Build Requirements

### All Platforms
- **vcpkg**: Set `VCPKG_ROOT` environment variable
- **Dependencies**: `libvpx`, `libyuv`, `opus`, `aom` (via vcpkg)

### Windows
- Visual Studio Build Tools
- Windows SDK
- Virtual display drivers for advanced features

### macOS
- Xcode Command Line Tools
- Proper code signing for distribution

### Linux
- Development packages for X11/Wayland
- PulseAudio development libraries
- GTK development packages

## Build Options

### Feature Flags
- `--flutter`: Enable Flutter UI (recommended)
- `--hwcodec`: Hardware video encoding/decoding
- `--vram`: VRAM optimization (Windows only)
- `--release`: Optimized release build

### Platform Scripts
- `flutter/build_android.sh`: Android build automation
- `flutter/build_ios.sh`: iOS build automation  
- `flutter/build_fdroid.sh`: F-Droid compatible build

## Testing

```bash
# Rust tests
cargo test

# Flutter tests
cd flutter && flutter test
```

## Project Structure

```
src/                    # Rust application core
├── server/            # Audio/video/input services
├── client.rs          # Peer connection handling
└── platform/          # Platform-specific code
flutter/               # Flutter UI application
├── lib/desktop/       # Desktop-specific UI
├── lib/mobile/        # Mobile-specific UI
└── lib/common/        # Shared UI components
libs/                  # Core native libraries
├── hbb_common/        # Common protocols & utilities
├── scrap/             # Screen capture
├── enigo/             # Input simulation
└── clipboard/         # Clipboard management
res/                   # Resources & build scripts
```

## Security

VieShare implements multiple security layers:
- End-to-end encryption for all communications
- 2FA support via TOTP
- Configurable security policies
- Secure file transfer with integrity verification
- Platform-specific security integrations

## Supported Platforms

| Platform | Status | Features |
|----------|--------|----------|
| Windows 10/11 | Full Support | All features including hardware acceleration |
| macOS 10.14+ | Full Support | Native integration with ScreenCaptureKit |
| Linux (X11) | Full Support | Wayland support available |
| Linux (Wayland) | Full Support | Via PipeWire/Portal |
| Android 7.0+ | Full Support | Mobile-optimized interface |
| iOS 12.0+ | Full Support | Native iOS integration |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `cargo test && cd flutter && flutter test`
5. Submit a pull request

## License

Licensed under the AGPL-3.0 License. See [LICENSE](LICENCE) for details.

## Support

- Issues: [GitHub Issues](https://github.com/vieshare/vieshare/issues)
- Documentation: [docs/](docs/)
- Community: [Discussions](https://github.com/vieshare/vieshare/discussions)