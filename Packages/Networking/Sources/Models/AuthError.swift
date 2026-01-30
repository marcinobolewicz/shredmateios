import Foundation

/// Authentication-related errors
public enum AuthError: Error, Sendable, Equatable {
    case invalidCredentials
    case unauthorized
    case sessionExpired
    case refreshFailed
    case networkError(String)
    case serverError(statusCode: Int)
    case decodingError
    case noRefreshToken
    case tokenStorageError(String)
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .sessionExpired:
            return "Your session has expired. Please log in again"
        case .refreshFailed:
            return "Failed to refresh session"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .decodingError:
            return "Failed to process server response"
        case .noRefreshToken:
            return "No refresh token available"
        case .tokenStorageError(let message):
            return "Token storage error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
