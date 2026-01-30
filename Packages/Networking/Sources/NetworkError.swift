//
//  NetworkError.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Network layer errors
public enum NetworkError: Error, Sendable, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case unauthorized
    case noData
    case decodingFailed
    case encodingFailed
    case unknown(String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .unauthorized:
            return "Unauthorized - no valid access token"
        case .noData:
            return "No data received"
        case .decodingFailed:
            return "Failed to decode response"
        case .encodingFailed:
            return "Failed to encode request body"
        case .unknown(let message):
            return message
        }
    }
}
