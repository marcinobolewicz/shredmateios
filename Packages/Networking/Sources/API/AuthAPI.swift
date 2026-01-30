//
//  AuthAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Authentication API endpoints
public enum AuthAPI {
    
    /// Login with email and password
    public static func login(email: String, password: String) -> Endpoint<AuthResponse> {
        .post(
            "/auth/login",
            body: LoginRequest(email: email, password: password),
            auth: .none
        )
    }
    
    /// Register a new user
    public static func register(email: String, password: String, name: String) -> Endpoint<AuthResponse> {
        .post(
            "/auth/register",
            body: RegisterRequest(email: email, password: password, name: name),
            auth: .none
        )
    }
    
    /// Logout current session
    public static func logout(refreshToken: String) -> Endpoint<EmptyResponse> {
        .post(
            "/auth/logout",
            body: LogoutRequest(refreshToken: refreshToken),
            auth: .bearerToken
        )
    }
    
    /// Refresh access token
    public static func refresh(refreshToken: String) -> Endpoint<AuthResponse> {
        .post(
            "/auth/refresh",
            body: RefreshRequest(refreshToken: refreshToken),
            auth: .none
        )
    }
    
    /// Get current authenticated user
    public static func me() -> Endpoint<User> {
        .get("/auth/me", auth: .bearerToken)
    }
}
