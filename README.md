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
- **Backend**: DEV uses the same backend as PROD (see "Backend URL (DEV = PROD)")
- **Compilation Flag**: DEV

### Production (Prod)
- **Scheme**: `ShredMate-prod`
- **Bundle ID**: `com.shredmate.app`
- **Display Name**: ShredMate
- **Backend**: PROD uses the same backend as DEV (see "Backend URL (DEV = PROD)")
- **Compilation Flag**: PROD

## Backend Communication

The following description covers contracts (URLs, paths, events) and the division of responsibilities between application layers. Implementation remains hidden — REST is the source of truth, and realtime serves for best-effort UI refreshing.

### Backend URL (DEV = PROD)

Both configurations (Dev and Prod) currently point to the same backend:

- **REST base URL**: `https://api.shredmate.eu/api/v1`
- **Socket.IO origin**: `https://api.shredmate.eu`
- **Socket namespace**: `/chat`
- **Socket transport path**: `/socket.io/*` (polling + websocket)

### Layer Organization (without code)

- **API Client**: central HTTP client; responsible for base URL, common headers, standardized error handling and retry after authorization.
- **Auth Session / Token Store**: single "source of truth" for tokens; secure storage of `accessToken`, `refreshToken` and `expiresAt`.
- **Auth Service**: user session operations in REST: login/register/logout, `me` and token refresh.
- **Chat Service**: REST operations for chat domain: conversation list, conversation creation, message fetching (pagination), message sending.
- **Chat Realtime**: manages Socket.IO connection in `/chat` namespace; attaches token in handshake, handles reconnect (including after token refresh) and propagates events to UI/cache layer.

### Authorization

#### 1) Session Storage

- The application stores `accessToken`, `refreshToken` and `expiresAt` in secure storage.
- The entire application uses a single central "source of truth" for tokens.

#### 2) REST Request Authorization

- Every REST request goes through a common HTTP client.
- For endpoints requiring authorization, the client automatically adds the header: `Authorization: Bearer <accessToken>`.

#### 3) Token Refresh (401 → refresh → retry)

- If the API returns `401` for an authorized request (except: login/register/logout/refresh), a refresh is triggered via `POST /auth/refresh`.
- Refresh is **single-flight**: parallel requests don't trigger multiple refreshes — they wait for the result of a single refresh.
- On success: new tokens are saved and original requests are retried.
- If refresh returns `401` or `refreshToken` is missing: the session is cleared and re-login is required.

#### 4) App Init / "long inactivity"

- On app start, `GET /auth/me` is executed:
    - `200` → session OK
    - `401` → automatically `POST /auth/refresh` and retry `GET /auth/me`
- When the app returns to foreground and `expiresAt` suggests token expiration:
    - first `GET /auth/me` is executed (which may trigger refresh),
    - only then the socket is (re)connected.

### Messages / Chat endpoints

REST contract for chat is relative to **REST base URL**. Authorized endpoints require the `Authorization: Bearer <accessToken>` header.

#### Auth

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me` (safe ping; may return `401` which triggers refresh)

#### Messages / Chat

- `GET /chat/conversations`
- `POST /chat/conversations/with/:otherUserId`
- `GET /chat/conversations/:id/messages` (pagination)
- `POST /chat/conversations/:id/messages` with payload `{ type: 'TEXT', text }`

MVP assumption: only `TEXT` type messages are supported (no images or attachments).

### Realtime (Socket.IO)

Realtime connection is **best-effort** and serves for fast UI refreshing; REST remains the source of truth.

- **Auth**: JWT passed in `handshake.auth.token`.
- **Namespace**: `/chat`.
- **Events**:
    - `conversation:updated` (last message update / `lastMessageAt`)
    - `message:new` (new message)
- **Sync rule**: events can update cache/UI optimistically, but eventually should be followed by re-fetch or data invalidation via REST.

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