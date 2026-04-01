//
//  JSONCoding.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Protocol for JSON encoding/decoding configuration
public protocol JSONCoding: Sendable {
    func makeEncoder() -> JSONEncoder
    func makeDecoder() -> JSONDecoder
}

/// Default JSON coding with snake_case conversion and ISO8601 dates.
///
/// Supports fractional seconds (`"2026-03-31T14:00:00.000Z"`) that the backend
/// always includes. Falls back to non-fractional ISO 8601 for robustness.
public struct DefaultJSONCoding: JSONCoding, Sendable {
    public init() {}

    public func makeEncoder() -> JSONEncoder {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
        return encoder
    }

    public func makeDecoder() -> JSONDecoder {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = fractional.date(from: string) { return date }
            if let date = plain.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected ISO 8601 date string, got: \(string)"
            )
        }
        return decoder
    }
}
