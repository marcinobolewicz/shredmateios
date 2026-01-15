import Foundation

/// Routes for authentication flow navigation
public enum AuthRoute: Hashable, Sendable {
    case login
    case register
    case forgotPassword
}
