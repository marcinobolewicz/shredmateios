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

/// Default JSON coding with snake_case conversion and ISO8601 dates
public struct DefaultJSONCoding: JSONCoding, Sendable {
    public init() {}
    
    public func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    public func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
