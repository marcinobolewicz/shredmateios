# Quick Start Guide

## Prerequisites
- macOS 14.0 or later
- Xcode 16.0 or later
- Swift 6.0 or later

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/marcinobolewicz/shredmateios.git
cd shredmateios
```

### 2. Open in Xcode
```bash
open ShredMate.xcodeproj
```

### 3. Select a Scheme
Choose between two available schemes:
- **ShredMate-dev**: Development environment
- **ShredMate-prod**: Production environment

### 4. Build and Run
Press `⌘R` or click the Run button.

## Development Workflow

### Building
```bash
# Build all SPM packages
swift build

# Build for specific scheme
xcodebuild build -project ShredMate.xcodeproj -scheme ShredMate-dev
```

### Testing
```bash
# Run all tests
swift test

# Run specific test
swift test --filter CoreTests
```

### Linting
```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Run SwiftLint
swiftlint lint

# Auto-fix issues
swiftlint --fix
```

## Project Structure

```
├── Packages/               # Swift Package Manager modules
│   ├── Core/              # Foundation layer (DI, networking, config)
│   ├── Networking/        # Network services
│   ├── Login/             # Authentication module
│   └── App/               # App layer (views, routing)
├── ShredMate/             # Main app target
├── Configurations/        # Build configurations (Dev/Prod)
└── .github/workflows/     # CI/CD pipelines
```

## Available Configurations

### Development (ShredMate-dev)
- Bundle ID: `com.shredmate.app.dev`
- Display Name: "ShredMate Dev"
- API URL: `https://api-dev.shredmate.app`
- Compilation Flag: `DEV`

### Production (ShredMate-prod)
- Bundle ID: `com.shredmate.app`
- Display Name: "ShredMate"
- API URL: `https://api.shredmate.app`
- Compilation Flag: `PROD`

## Key Features

✅ Swift 6 with strict concurrency
✅ SwiftUI for all UI components
✅ Async/await for asynchronous operations
✅ Actor-based networking client
✅ Dependency injection container
✅ Modular architecture with SPM
✅ Separate DEV/PROD configurations
✅ Comprehensive test coverage
✅ SwiftLint integration
✅ CI/CD with GitHub Actions

## App Flow

1. **Startup**: `ShredMateApp.swift` initializes the app
2. **Configuration**: `AppSetup.configure()` sets up DI container
3. **Routing**: `RootView` handles navigation between Login and Home
4. **Authentication**: Login flow updates state to show Home view

## Adding New Features

### 1. Create a New Package Module
```bash
mkdir -p Packages/NewModule/{Sources,Tests}
```

### 2. Add Module to Package.swift
```swift
.target(
    name: "NewModule",
    dependencies: ["Core"],
    path: "Packages/NewModule/Sources",
    swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency")
    ]
)
```

### 3. Add Tests
```swift
.testTarget(
    name: "NewModuleTests",
    dependencies: ["NewModule"],
    path: "Packages/NewModule/Tests"
)
```

## Troubleshooting

### Build Fails
1. Clean build folder: `⌘⇧K`
2. Reset package cache: `File > Packages > Reset Package Caches`
3. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Tests Fail
1. Ensure all packages are up to date
2. Check that test targets are properly configured
3. Verify Swift version: `swift --version`

### SwiftLint Warnings
1. Check `.swiftlint.yml` for configuration
2. Run `swiftlint --fix` to auto-fix issues
3. Disable specific rules if needed in `.swiftlint.yml`

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Swift Package Manager](https://swift.org/package-manager/)

## Support

For issues or questions:
1. Check [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed architecture
2. Review [README.md](README.md) for comprehensive documentation
3. Open an issue on GitHub

---
Happy coding! 🚀
