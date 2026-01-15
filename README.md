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

## Komunikacja z backendem

Poniższy opis dotyczy kontraktów (URL-e, ścieżki, eventy) oraz podziału odpowiedzialności między warstwami aplikacji. Implementacja pozostaje ukryta — REST jest źródłem prawdy, a realtime służy do best-effort odświeżania UI.

### Backend URL (DEV = PROD)

Obie konfiguracje (Dev i Prod) wskazują aktualnie na ten sam backend:

- **REST base URL**: `https://api.shredmate.eu/api/v1`
- **Socket.IO origin**: `https://api.shredmate.eu`
- **Socket namespace**: `/chat`
- **Socket transport path**: `/socket.io/*` (polling + websocket)

### Organizacja warstw (bez kodu)

- **API Client**: centralny klient HTTP; odpowiada za base URL, wspólne nagłówki, oraz ustandaryzowaną obsługę błędów i retry po autoryzacji.
- **Auth Session / Token Store**: pojedyncze „source of truth” dla tokenów; bezpieczne przechowywanie `accessToken`, `refreshToken` i `expiresAt`.
- **Auth Service**: operacje sesji użytkownika w REST: login/register/logout, `me` oraz refresh tokenów.
- **Chat Service**: REST-owe operacje domeny czatu: lista konwersacji, tworzenie konwersacji, pobieranie wiadomości (paginacja), wysyłka wiadomości.
- **Chat Realtime**: zarządza połączeniem Socket.IO w namespace `/chat`; podpina token w handshake, obsługuje reconnect (w tym po odświeżeniu tokenu) i propaguje eventy do warstwy UI/cache.

### Autoryzacja

#### 1) Przechowywanie sesji

- Aplikacja przechowuje `accessToken`, `refreshToken` i `expiresAt` w bezpiecznym storage.
- Cała aplikacja korzysta z jednego centralnego „source of truth” dla tokenów.

#### 2) Autoryzacja requestów REST

- Każdy request REST przechodzi przez wspólny klient HTTP.
- Dla endpointów wymagających autoryzacji klient automatycznie dodaje nagłówek: `Authorization: Bearer <accessToken>`.

#### 3) Odświeżanie tokenów (401 → refresh → retry)

- Jeśli API zwróci `401` dla requestu autoryzowanego (z wyjątkiem: login/register/logout/refresh), uruchamiany jest refresh przez `POST /auth/refresh`.
- Refresh jest **single-flight**: równoległe requesty nie uruchamiają wielu refreshy — czekają na wynik jednego odświeżenia.
- Po sukcesie: zapisywane są nowe tokeny i wykonywany jest retry oryginalnych requestów.
- Jeśli refresh zwróci `401` lub brakuje `refreshToken`: sesja jest czyszczona i wymagane jest ponowne logowanie.

#### 4) Init aplikacji / „długi brak aktywności”

- Na starcie aplikacja wykonuje `GET /auth/me`:
    - `200` → sesja OK
    - `401` → automatycznie `POST /auth/refresh` i retry `GET /auth/me`
- Po powrocie aplikacji na foreground, gdy `expiresAt` sugeruje wygaśnięcie tokenu:
    - najpierw wykonywane jest `GET /auth/me` (które może uruchomić refresh),
    - dopiero potem (re)łączony jest socket.

### Messages / Chat endpoints

Kontrakt REST dla czatu jest liczony względem **REST base URL**. Endpointy autoryzowane wymagają nagłówka `Authorization: Bearer <accessToken>`.

#### Auth

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me` (safe ping; może zwrócić `401` i wtedy uruchamia się refresh)

#### Messages / Chat

- `GET /chat/conversations`
- `POST /chat/conversations/with/:otherUserId`
- `GET /chat/conversations/:id/messages` (paginacja)
- `POST /chat/conversations/:id/messages` z payload `{ type: 'TEXT', text }`

Założenie MVP: obsługiwane są wyłącznie wiadomości typu `TEXT` (bez obrazów i załączników).

### Realtime (Socket.IO)

Połączenie realtime jest **best-effort** i służy do szybkiego odświeżania UI; REST pozostaje źródłem prawdy.

- **Auth**: JWT przekazywany w `handshake.auth.token`.
- **Namespace**: `/chat`.
- **Eventy**:
    - `conversation:updated` (aktualizacja ostatniej wiadomości / `lastMessageAt`)
    - `message:new` (nowa wiadomość)
- **Zasada synchronizacji**: eventy mogą aktualizować cache/UI optymistycznie, ale docelowo po nich powinien następować re-fetch lub invalidation danych przez REST.

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