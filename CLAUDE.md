# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Build all SPM packages
swift build

# Run all tests
swift test

# Run tests for a specific package
swift test --filter CoreTests
swift test --filter NetworkingTests
swift test --filter ConversationsTests

# Build specific Xcode scheme (requires simulator)
xcodebuild build -project ShredMate.xcodeproj -scheme ShredMate-dev -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.0'
xcodebuild build -project ShredMate.xcodeproj -scheme ShredMate-prod -configuration Release -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.0'

# Run SwiftLint
swiftlint lint --strict
```

## Architecture Overview

Modular **Swift Package Manager** architecture under `/Packages/`. Each feature lives in its own package with `Sources/` and `Tests/` directories.

### Package Map

| Package | Responsibility |
|---|---|
| `Core` | DIContainer, URLSessionClient, AppConfiguration, routing primitives |
| `Networking` | AuthenticatingHTTPClient, all REST services, token storage, models |
| `Auth` | AuthState (Observable), AuthService, DefaultTokenProvider |
| `Login` | Login/register UI and view models |
| `App` | RootView, AppSetup, AppDependencies, navigation, Firebase setup |
| `Conversations` | Chat UI, ChatRepository, Socket.IO client, ChatLifecycleManager |
| `Places` | Places/locations feature, mentor slot booking with Stripe payment flow |
| `Profile` | User profile management, Stripe Connect mentor onboarding |
| `Payment` | Stripe SDK wrapper: StripePaymentService, PaymentSheetPresenter, PaymentResult |
| `Theme` | Design system: DS* button/text styles, components |
| `Common` | Shared utilities |

### Key Architectural Patterns

**Dependency Injection**: `DIContainer` (MainActor-based, type-safe) in Core. `AppSetup.configure()` wires everything together at startup.

**State-Based Routing**: `RootFlow` enum (`guest` / `auth` / `user`) drives top-level navigation via `RootRouter`. `RootView` observes `AuthState` and switches flows accordingly.

**App Initialization Flow**: `ShredMateApp` → `AppDelegate` (Firebase, push notifications) → `AppSetup.configure()` (creates all dependencies) → `RootView`.

**Observable Pattern**: `@Observable` macro for reactive state (`AuthState`, `ChatRepository`, `AppDependencies`). All UI state lives on MainActor.

**Networking**: `AuthenticatingHTTPClient` (actor) handles Bearer token injection, automatic token refresh on 401 using a single-flight pattern (concurrent 401s share one refresh request via `CheckedContinuation`), then retries.

**Realtime Chat**: `ChatRealtimeProviding` protocol abstracts Socket.IO transport. `SocketIOChatClient` implements it. `ChatRepository` is the source of truth; socket events update it via `ChatEventHandler`. REST is always authoritative over socket state.

**Concurrency**: Swift 6 strict concurrency throughout. Actors for shared mutable state (`AuthenticatingHTTPClient`, `AppConfiguration`). `@MainActor` for all Observable view models and repositories.

### Build Configurations

- **Dev**: bundle ID `pl.shredmate.app.dev`, compilation flag `DEV`
- **Prod**: bundle ID `pl.shredmate.app`, compilation flag `PROD`
- Both point to `https://api.shredmate.eu` as API base URL (`shredmate.pl` is the marketing site / universal-link host)

**Stripe Payment Flow**: `MentorSlotsViewModel` orchestrates: `POST /payment-intent` → `PaymentSheet` presentation → `POST /confirm-payment`. `StripePaymentService` is `@Observable` and injected via SwiftUI Environment. Backend reserves slot for 15 min during payment. See `Packages/Payment/STRIPE.md` for full details.

### External Dependencies

- `socket.io-client-swift` — realtime chat transport
- `firebase-ios-sdk` — Crashlytics, Messaging
- `stripe-ios` — Stripe PaymentSheet for slot booking payments
- `Pulse` — network debugging (debug builds)

### SwiftLint Thresholds

Line length warning/error: 120/150. File length: 500/1000. Type body: 300/400. Function body: 50/100. Cyclomatic complexity: 10/20.

## CI

GitHub Actions (`.github/workflows/ios-ci.yml`): SwiftLint strict → `swift build` → `swift test` → build dev scheme → build prod scheme. Runs on push/PR to `main` and `develop`.
