# Auth Module

Moduł autoryzacji dla aplikacji ShredMate iOS. Zapewnia kompletną warstwę uwierzytelniania: przechowywanie tokenów, klienta HTTP z automatycznym odświeżaniem sesji oraz reaktywny stan dla UI.

## Architektura

```
Auth/
├── Models/           # Modele danych (User, Rider, AuthTokens, ...)
├── Storage/          # TokenStorage (Keychain)
├── Networking/       # AuthHTTPClient (interceptor 401 → refresh)
├── Services/         # AuthService, RiderService
├── State/            # AuthState (@Observable)
└── Tests/            # Testy jednostkowe
```

## Główne komponenty

### TokenStorage
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

### AuthHTTPClient
Centralny klient HTTP z automatycznym:
- Dodawaniem nagłówka `Authorization: Bearer <token>`
- Obsługą 401 → refresh → retry (single-flight)
- Powiadamianiem o wygaśnięciu sesji

```swift
let httpClient = AuthHTTPClient(
    baseURL: "https://api.shredmate.eu/api/v1",
    tokenStorage: storage
)

// Callback na wygaśnięcie sesji
httpClient.onSessionInvalidated = {
    await authState.handleSessionInvalidation()
}

// Użycie
let user: User = try await httpClient.get("/auth/me")
let response: AuthResponse = try await httpClient.post("/auth/login", body: loginRequest)
```

### AuthService
Operacje autoryzacyjne (login/register/logout/refresh/me).

```swift
let authService = AuthService(httpClient: httpClient, tokenStorage: storage)

// Login
let response = try await authService.login(email: "user@example.com", password: "secret")

// Register
let response = try await authService.register(email: "...", password: "...", name: "John")

// Logout
try await authService.logout()

// Sprawdzenie sesji
let isLoggedIn = await authService.isAuthenticated()
let token = await authService.getAccessToken()
```

### RiderService
Operacje na profilu Ridera.

```swift
let riderService = RiderService(httpClient: httpClient)

// Pobranie profilu
let rider = try await riderService.fetchMyRider()

// Aktualizacja
let updated = try await riderService.updateMyRider(
    UpdateRiderRequest(type: .mentor, description: "Expert")
)

// Usunięcie konta
try await riderService.deleteMyAccount()
```

### AuthState
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
1. `AuthHTTPClient` przechwytuje 401
2. Blokuje kolejne requesty (single-flight)
3. Wywołuje `POST /auth/refresh`
4. Sukces → zapisuje nowe tokeny, ponawia oryginalny request
5. Błąd → wywołuje `onSessionInvalidated`, czyści sesję

### 3. Powrót na foreground
```swift
// W ScenePhase.active
if await authState.tokensNeedRefresh() {
    await authState.restoreSession()
}
// Dopiero potem reconnect Socket.IO
```

## Integracja z DI Container

```swift
// W AppSetup.configure()
let storage = TokenStorage()
let httpClient = AuthHTTPClient(
    baseURL: AppConfiguration.apiBaseURL,
    tokenStorage: storage
)
let authService = AuthService(httpClient: httpClient, tokenStorage: storage)
let riderService = RiderService(httpClient: httpClient)
let authState = AuthState(
    authService: authService,
    riderService: riderService,
    tokenStorage: storage
)

// Callback na wygaśnięcie sesji
httpClient.onSessionInvalidated = { [weak authState] in
    await authState?.handleSessionInvalidation()
}

DIContainer.shared.register(AuthState.self) { authState }
DIContainer.shared.register(AuthHTTPClient.self) { httpClient }
```

## Testowanie

Moduł jest zaprojektowany z myślą o testowalności:

```swift
// Mock storage dla testów
actor MockTokenStorage: TokenStorageProtocol {
    private var tokens: AuthTokens?
    private var user: User?
    
    func saveTokens(_ tokens: AuthTokens) async throws { self.tokens = tokens }
    func loadTokens() async -> AuthTokens? { tokens }
    // ...
}

// Użycie w testach
let mockStorage = MockTokenStorage()
let service = AuthService(httpClient: httpClient, tokenStorage: mockStorage)
```

## Endpointy API

### Auth
| Metoda | Endpoint | Opis |
|--------|----------|------|
| POST | `/auth/login` | Logowanie |
| POST | `/auth/register` | Rejestracja |
| POST | `/auth/refresh` | Odświeżenie tokenów |
| POST | `/auth/logout` | Wylogowanie |
| GET | `/auth/me` | Pobranie aktualnego użytkownika |

### Riders
| Metoda | Endpoint | Opis |
|--------|----------|------|
| GET | `/riders/me` | Pobranie profilu ridera |
| PATCH | `/riders/me` | Aktualizacja profilu |
| DELETE | `/riders/me` | Usunięcie konta |

## Wymagania

- iOS 18.0+
- Swift 6.0+
- Xcode 16.0+
