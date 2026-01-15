# Login Module

Moduł feature odpowiedzialny za flow autoryzacji w aplikacji ShredMate. Zawiera widoki i ViewModele dla logowania, rejestracji i resetowania hasła.

## Architektura

```
Login/
├── Sources/
│   ├── ViewModels/
│   │   ├── LoginViewModel.swift
│   │   ├── RegisterViewModel.swift
│   │   └── ForgotPasswordViewModel.swift
│   └── Views/
│       ├── AuthFlowView.swift      # Coordinator z NavigationStack
│       ├── LoginView.swift
│       ├── RegisterView.swift
│       └── ForgotPasswordView.swift
└── Tests/
    └── ViewModelTests.swift
```

## Główne komponenty

### AuthFlowView
Coordinator view zarządzający nawigacją przez `NavigationStack(path:)`. Tworzy ViewModele dla poszczególnych ekranów.

```swift
// Użycie w RootView
AuthFlowView(authState: authState)
```

### ViewModele
Każdy widok ma dedykowany ViewModel zgodny ze wzorcem MVVM:

- **LoginViewModel** — logowanie, nawigacja do Register/ForgotPassword
- **RegisterViewModel** — rejestracja nowego użytkownika
- **ForgotPasswordViewModel** — reset hasła

### Flow nawigacji

```
AuthFlowView (NavigationStack)
├── LoginView (root)
│   ├── → RegisterView (push)
│   └── → ForgotPasswordView (push)
```

## Zależności

- **Core** — `AuthRouter`, `AuthRoute`
- **Auth** — `AuthState`, `AuthService`

## Użycie

```swift
// W RootView (App module)
if authState.isLoggedIn {
    HomeView(authState: authState)
} else {
    AuthFlowView(authState: authState)
}
```

## Testowanie

ViewModele są testowalne przez dependency injection:

```swift
// Test nawigacji
func testNavigateToRegister() {
    let router = AuthRouter()
    let viewModel = LoginViewModel(authState: authState, router: router)
    
    viewModel.navigateToRegister()
    
    XCTAssertEqual(router.path.first, .register)
}
```

## Walidacja formularzy

- **Login**: email (zawiera @) + password (niepuste)
- **Register**: name + email + password (min 8 znaków) + confirmPassword (musi się zgadzać)
- **ForgotPassword**: email (zawiera @)
