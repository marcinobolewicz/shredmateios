//
//  RequestBuilding.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

public protocol RequestBuilding: Sendable {
    func makeRequest<Response: Decodable & Sendable>(
        baseURL: URL,
        endpoint: Endpoint<Response>
    ) throws -> URLRequest
}

struct DefaultRequestBuilder: RequestBuilding {
    private let coding: JSONCoding
    
    init(coding: JSONCoding = DefaultJSONCoding()) {
        self.coding = coding
    }
    
    func makeRequest<Response: Decodable & Sendable>(
        baseURL: URL,
        endpoint: Endpoint<Response>
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        let extraPath = endpoint.path.hasPrefix("/") ? endpoint.path : "/" + endpoint.path
        components.path += extraPath
        if !endpoint.query.isEmpty { components.queryItems = endpoint.query }

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Apply headers from endpoint
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Apply body and content type
        try applyBody(endpoint.body, to: &request)

        return request
    }
    
    private func applyBody(_ body: RequestBody, to request: inout URLRequest) throws {
        switch body {
        case .none:
            break
            
        case .json(let encodable):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try coding.makeEncoder().encode(AnyEncodable(encodable))
            } catch {
                throw NetworkError.encodingFailed
            }
            
        case .raw(let data, let contentType):
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
        case .multipart(let formData):
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = formData.buildBody(boundary: boundary)
        }
    }
}

// MARK: - Type Erasure for Encodable

/// Type-erased wrapper for Encodable values
private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init(_ value: any Encodable) {
        self.encode = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

