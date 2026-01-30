# Auth Module

Moduł autoryzacji dla aplikacji ShredMate iOS. Zapewnia kompletną warstwę uwierzytelniania: przechowywanie tokenów, klienta HTTP z automatycznym odświeżaniem sesji oraz reaktywny stan dla UI.

## Architektura

```
Auth/
├── Models/              # Modele danych (User, Rider, AuthTokens, ...)
├── Storage/             # TokenStorage (Keychain)
├── New Networking/      # Nowa warstwa sieciowa (zalecana)
│   ├── Core/            # Endpoint, HTTPClient, RequestBody, ...
│   ├── API/             # AuthAPI, RiderAPI, SportsAPI
│   └── Services/        # AuthService, RiderService, DefaultTokenProvider
├── Networking/          # [DEPRECATED] Stary AuthHTTPClient
├── Services/            # [DEPRECATED] Stare serwisy
├── State/               # AuthState (@Observable)
└── Tests/               # Testy jednostkowe
```

## Nowa warstwa sieciowa (zalecana)

### Endpoint-based API

Deklaratywne, type-safe definicje endpointów:

```swift
// Statyczne definicje w enumach
AuthAPI.login(email: "user@example.com", password: "secret")  // → Endpoint<AuthResponse>
AuthAPI.me()                                                   // → Endpoint<User>
RiderAPI.me()                                                  // → Endpoint<Rider>
RiderAPI.uploadAvatar(imageData: data)                        // → Endpoint<AvatarUploadResponse>
SportsAPI.all()                                               // → Endpoint<[Sport]>
```

### Setup

```swift
// 1. Token storage
let tokenStorage = TokenStorage()

// 2. Token provider (obsługuje refresh)
let tokenProvider = DefaultTokenProvider(
    tokenStorage: tokenStorage,
    baseURL: URL(string: "https://api.shredmate.eu/api/v1")!
)

// 3. HTTP client z auto-auth (Bearer token, 401→refresh→retry)
let client = AuthenticatingHTTPClient(
    baseURL: URL(string: "https://api.shredmate.eu/api/v1")!,
    tokenProvider: tokenProvider
)

// 4. Serwisy
let authService = AuthService(client: client, tokenStorage: tokenStorage)
let riderService = RiderService(client: client)
```

### AuthService

```swift
// Login
let response = try await authService.login(email: "user@example.com", password: "secret")

// Register
let response = try await authService.register(email: "...", password: "...", name: "John")

// Logout
try await authService.logout()

// Sprawdzenie sesji
let isLoggedIn = await authService.isAuthenticated()
```

### RiderService

```swift
// Pobranie profilu
let rider = try await riderService.fetchMyRider()

// Aktualizacja
let updated = try await riderService.updateMyRider(
    UpdateRiderRequest(type: .mentor, description: "Expert")
)

// Upload avatara
let result = try await riderService.uploadAvatar(imageData)

// Sporty
let sports = try await riderService.fetchAllSports()
let mySports = try await riderService.fetchMyRiderSports()
```

### Tworzenie własnych endpointów

```swift
// Prosty GET z auth
let endpoint = Endpoint<MyResponse>.get("/my/endpoint", auth: .bearerToken)

// POST z body
let endpoint = Endpoint<MyResponse>.post(
    "/my/endpoint",
    body: MyRequest(data: "value"),
    auth: .bearerToken
)

// Multipart upload
let endpoint = Endpoint<UploadResponse>.uploadMultipart(
    "/upload",
    multipart: MultipartFormData(
        fileData: imageData,
        fileName: "photo.jpg",
        mimeType: "image/jpeg"
    ),
    auth: .bearerToken
)

// Wykonanie
let response = try await client.send(endpoint)
```

## Komponenty warstwy sieciowej

| Komponent | Opis |
|-----------|------|
| `Endpoint<T>` | Type-safe definicja endpointu z metodą, ścieżką, body, auth |
| `RequestBody` | Enum: `.none`, `.json(Encodable)`, `.multipart(...)`, `.raw(Data)` |
| `AuthRequirement` | Enum: `.none`, `.bearerToken` |
| `HTTPClient` | Protokół wykonujący requesty |
| `AuthenticatingHTTPClient` | HTTP client z auto-wstrzykiwaniem tokenu i 401→refresh |
| `TokenProvider` | Protokół dostarczający i odświeżający tokeny |
| `APIClienting` | Protokół dla serwisów (`send(_:)`) |

## TokenStorage

Bezpieczne przechowywanie tokenów w iOS Keychain.

```swift
let storage = TokenStorage()

// Zapis
try await storage.saveTokens(tokens)
try await storage.saveUser(user)

// Odczyt
let tokens = await storage.loadTokens()
let user = await storage.loadUser()

// Czyszczenie
try await storage.clearAll()
```

## AuthState

Reaktywny stan UI (`@Observable`). Użyj w SwiftUI poprzez `@Environment` lub `@State`.

```swift
let authState = AuthState(
    authService: authService,
    riderService: riderService,
    tokenStorage: storage
)

// W SwiftUI View:
struct ContentView: View {
    @State private var authState: AuthState
    
    var body: some View {
        if authState.isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

// Akcje
await authState.restoreSession()  // Na starcie aplikacji
await authState.login(email: "...", password: "...")
await authState.logout()

// Stan
authState.isLoading    // Bool
authState.isLoggedIn   // Bool
authState.user         // User?
authState.rider        // Rider?
authState.error        // AuthError?
```

## Przepływ autoryzacji

### 1. Start aplikacji
```swift
// W App.init lub onAppear
Task {
    await authState.restoreSession()
}
```

### 2. Request z 401
1. `AuthenticatingHTTPClient` przechwytuje 401
2. Blokuje kolejne requesty (single-flight)
3. Wywołuje refresh przez `TokenProvider`
4. Sukces → zapisuje nowe tokeny, ponawia oryginalny request
5. Błąd → wywołuje `onSessionInvalidated`, czyści sesję

### 3. Powrót na foreground
```swift
// W ScenePhase.active
if await authState.tokensNeedRefresh() {
    await authState.restoreSession()
}
```

## Testowanie

Moduł jest zaprojektowany z myślą o testowalności:

```swift
// Mock client dla testów
final class MockAPIClient: APIClienting, @unchecked Sendable {
    var responses: [String: Any] = [:]
    
    func send<T: Decodable & Sendable>(_ endpoint: Endpoint<T>) async throws -> T {
        // Return mocked response based on endpoint.path
    }
}

// Użycie w testach
let mockClient = MockAPIClient()
let service = RiderService(client: mockClient)
```

## Endpointy API

### Auth
| Metoda | Endpoint | Auth | Opis |
|--------|----------|------|------|
| POST | `/auth/login` | ❌ | Logowanie |
| POST | `/auth/register` | ❌ | Rejestracja |
| POST | `/auth/refresh` | ❌ | Odświeżenie tokenów |
| POST | `/auth/logout` | ✅ | Wylogowanie |
| GET | `/auth/me` | ✅ | Pobranie aktualnego użytkownika |

### Riders
| Metoda | Endpoint | Auth | Opis |
|--------|----------|------|------|
| GET | `/riders/me` | ✅ | Pobranie profilu ridera |
| PATCH | `/riders/me` | ✅ | Aktualizacja profilu |
| DELETE | `/riders/me` | ✅ | Usunięcie konta |
| POST | `/riders/me/avatar` | ✅ | Upload avatara |
| GET | `/riders/me/base-location` | ✅ | Pobranie lokalizacji |
| PUT | `/riders/me/base-location` | ✅ | Aktualizacja lokalizacji |
| GET | `/riders/me/sports` | ✅ | Pobranie sportów ridera |
| POST | `/riders/me/sports/:id` | ✅ | Dodanie/aktualizacja sportu |
| DELETE | `/riders/me/sports/:id` | ✅ | Usunięcie sportu |

### Sports
| Metoda | Endpoint | Auth | Opis |
|--------|----------|------|------|
| GET | `/sports` | ✅ | Lista wszystkich sportów |

## Wymagania

- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+
