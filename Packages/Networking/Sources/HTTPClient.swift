//
//  HTTPClient.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

public protocol NetworkSessioning: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSessioning {}

public protocol HTTPClient: Sendable {
    func send<T: Decodable & Sendable>(
        _ endpoint: Endpoint<T>,
        baseURL: URL
    ) async throws -> T
}

public final class DefaultHTTPClient: HTTPClient, Sendable {
    private let session: NetworkSessioning
    private let coding: JSONCoding
    private let requestBuilder: RequestBuilding

    public init(
        session: NetworkSessioning = URLSession.shared,
        coding: JSONCoding = DefaultJSONCoding(),
        requestBuilder: RequestBuilding? = nil
    ) {
        self.session = session
        self.coding = coding
        self.requestBuilder = requestBuilder ?? DefaultRequestBuilder(coding: coding)
    }

    public func send<T: Decodable & Sendable>(
        _ endpoint: Endpoint<T>,
        baseURL: URL
    ) async throws -> T {
        let request = try requestBuilder.makeRequest(baseURL: baseURL, endpoint: endpoint)
        return try await perform(request)
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }

        // Handle empty responses
        if T.self == EmptyResponse.self || data.isEmpty {
            if let emptyResponse = EmptyResponse() as? T {
                return emptyResponse
            }
            throw NetworkError.noData
        }

        do {
            return try coding.makeDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

/// Helper type for endpoints that return empty response
public struct EmptyResponse: Decodable, Sendable {
    public init() {}
}
