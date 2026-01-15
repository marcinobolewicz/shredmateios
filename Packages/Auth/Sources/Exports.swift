// Auth module - re-exports all public types
// This file ensures all types are visible when importing Auth module

// Models
public typealias UserModel = User
public typealias RiderModel = Rider

// This file exists to document the module's public API.
// All public types are automatically exported when importing the Auth module.
//
// Available types:
// - Models: User, Rider, RiderType, UpdateRiderRequest, AuthTokens, AuthResponse,
//           LoginRequest, RegisterRequest, RefreshRequest, LogoutRequest, AuthError
// - Storage: TokenStorageProtocol, TokenStorage
// - Networking: HTTPMethod, AuthHTTPClient, EmptyResponse
// - Services: AuthServiceProtocol, AuthService, RiderServiceProtocol, RiderService
// - State: AuthState

