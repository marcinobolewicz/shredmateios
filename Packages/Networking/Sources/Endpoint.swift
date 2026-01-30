//
//  Endpoint.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

public struct Endpoint<Response: Decodable & Sendable>: Sendable {
    public let method: HTTPMethod
    public let path: String
    public let query: [URLQueryItem]
    public let headers: [String: String]
    public let auth: AuthRequirement
    public let body: RequestBody

    public init(
        method: HTTPMethod,
        path: String,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        auth: AuthRequirement = .none,
        body: RequestBody = .none
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.auth = auth
        self.body = body
    }
}

// MARK: - Convenience Initializers

extension Endpoint {
    /// Creates a GET endpoint
    public static func get(
        _ path: String,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .get, path: path, query: query, headers: headers, auth: auth)
    }
    
    /// Creates a POST endpoint with JSON body
    public static func post<Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .post, path: path, headers: headers, auth: auth, body: .json(body))
    }
    
    /// Creates a POST endpoint without body
    public static func post(
        _ path: String,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .post, path: path, headers: headers, auth: auth)
    }
    
    /// Creates a PUT endpoint with JSON body
    public static func put<Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .put, path: path, headers: headers, auth: auth, body: .json(body))
    }
    
    /// Creates a PATCH endpoint with JSON body
    public static func patch<Body: Encodable & Sendable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .patch, path: path, headers: headers, auth: auth, body: .json(body))
    }
    
    /// Creates a DELETE endpoint
    public static func delete(
        _ path: String,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .delete, path: path, headers: headers, auth: auth)
    }
    
    /// Creates a POST endpoint with multipart form data
    public static func uploadMultipart(
        _ path: String,
        multipart: MultipartFormData,
        headers: [String: String] = [:],
        auth: AuthRequirement = .none
    ) -> Endpoint {
        Endpoint(method: .post, path: path, headers: headers, auth: auth, body: .multipart(multipart))
    }
}
