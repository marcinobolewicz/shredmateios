# ShredMate iOS

Modern iOS application built with SwiftUI, Swift 6, and modular architecture using Swift Package Manager.

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Architecture

The project uses a modular architecture with Swift Package Manager:

### Packages

- **Core**: Foundation layer with DI container, async/await actors, URLSession client
- **Networking**: Network layer using Core's client
- **Login**: Authentication module with views and services
- **App**: Main app layer with RootView, routing, and app setup

### Key Features

- ✅ Swift 6 with strict concurrency
- ✅ Async/await and actors for concurrency
- ✅ Actor-based URLSession client (stub implementation)
- ✅ Dependency Injection container
- ✅ Simple routing (Login/Home)
- ✅ Separate DEV/PROD configurations
- ✅ SwiftLint integration
- ✅ Test targets for all packages
- ✅ CI/CD with GitHub Actions

## Configuration

The app supports two build configurations:

### Development (Dev)
- **Scheme**: `ShredMate-dev`
- **Bundle ID**: `com.shredmate.app.dev`
- **Display Name**: ShredMate Dev
- **API Base URL**: https://api-dev.shredmate.app
- **Compilation Flag**: DEV

### Production (Prod)
- **Scheme**: `ShredMate-prod`
- **Bundle ID**: `com.shredmate.app`
- **Display Name**: ShredMate
- **API Base URL**: https://api.shredmate.app
- **Compilation Flag**: PROD

## Building

### Using Swift Package Manager

```bash
# Build packages
swift build

# Run tests
swift test
```

### Using Xcode

```bash
# Build Dev scheme
xcodebuild build -project ShredMate.xcodeproj -scheme ShredMate-dev -configuration Debug

# Build Prod scheme
xcodebuild build -project ShredMate.xcodeproj -scheme ShredMate-prod -configuration Release
```

## Testing

All packages have test targets:

- CoreTests
- NetworkingTests
- LoginTests
- AppTests

Run tests using:
```bash
swift test
```

## Linting

The project uses SwiftLint with configuration in `.swiftlint.yml`.

```bash
swiftlint lint
```

## CI/CD

GitHub Actions workflow runs on push/PR to main/develop:
- Lint code with SwiftLint
- Build all packages
- Run tests
- Build both Dev and Prod schemes

## Project Structure

```
shredmateios/
├── Package.swift                 # SPM package manifest
├── ShredMate/                    # Main app target
│   ├── ShredMateApp.swift       # App entry point
│   └── Info.plist               # App configuration
├── Packages/                     # SPM packages
│   ├── App/
│   │   ├── Sources/
│   │   │   ├── RootView.swift
│   │   │   ├── HomeView.swift
│   │   │   └── AppSetup.swift
│   │   └── Tests/
│   ├── Core/
│   │   ├── Sources/
│   │   │   ├── DIContainer.swift
│   │   │   ├── URLSessionClient.swift
│   │   │   └── AppConfiguration.swift
│   │   └── Tests/
│   ├── Networking/
│   │   ├── Sources/
│   │   │   └── NetworkingService.swift
│   │   └── Tests/
│   └── Login/
│       ├── Sources/
│       │   ├── LoginView.swift
│       │   └── LoginService.swift
│       └── Tests/
├── Configurations/               # Build configurations
│   ├── Dev.xcconfig
│   └── Prod.xcconfig
├── ShredMate.xcodeproj/          # Xcode project
└── .github/workflows/            # CI configuration
    └── ios-ci.yml
```

## License

© 2026 ShredMate. All rights reserved.