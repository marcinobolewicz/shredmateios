import XCTest
@testable import Auth

final class AuthTokensTests: XCTestCase {
    
    func testIsExpiredReturnsFalseWhenNoExpiresAt() {
        let tokens = AuthTokens(accessToken: "a", refreshToken: "r", expiresAt: nil)
        XCTAssertFalse(tokens.isExpired)
    }
    
    func testIsExpiredReturnsFalseWhenNotExpired() {
        let futureDate = Date().addingTimeInterval(3600)
        let tokens = AuthTokens(accessToken: "a", refreshToken: "r", expiresAt: futureDate)
        XCTAssertFalse(tokens.isExpired)
    }
    
    func testIsExpiredReturnsTrueWhenExpired() {
        let pastDate = Date().addingTimeInterval(-3600)
        let tokens = AuthTokens(accessToken: "a", refreshToken: "r", expiresAt: pastDate)
        XCTAssertTrue(tokens.isExpired)
    }
    
    func testIsExpiredReturnsTrueWhenExactlyAtExpiry() {
        let now = Date()
        let tokens = AuthTokens(accessToken: "a", refreshToken: "r", expiresAt: now)
        XCTAssertTrue(tokens.isExpired)
    }
}

final class AuthErrorTests: XCTestCase {
    
    func testLocalizedDescriptionsAreNotEmpty() {
        let errors: [AuthError] = [
            .invalidCredentials,
            .unauthorized,
            .sessionExpired,
            .refreshFailed,
            .networkError("test"),
            .serverError(statusCode: 500),
            .decodingError,
            .noRefreshToken,
            .tokenStorageError("test"),
            .unknown("test")
        ]
        
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "\(error) has empty description")
        }
    }
}

