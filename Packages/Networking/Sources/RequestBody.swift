//
//  RequestBody.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// JSON key encoding strategy for request bodies.
public enum JSONKeyStrategy: Sendable, Equatable {
    /// Converts camelCase keys to snake_case (default, follows `DefaultJSONCoding`)
    case snakeCase
    /// Preserves keys as-is (camelCase)
    case camelCase
}

/// Represents the body of an HTTP request
public enum RequestBody: Sendable {
    /// No body
    case none

    /// JSON-encoded body from an Encodable value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - keys: Key encoding strategy. Defaults to `.snakeCase` to match `DefaultJSONCoding`.
    ///           Pass `.camelCase` when the server expects camelCase keys.
    case json(any Encodable & Sendable, keys: JSONKeyStrategy = .snakeCase)

    /// Raw data with custom content type
    case raw(Data, contentType: String)
    
    /// Multipart form data for file uploads
    case multipart(MultipartFormData)
}

/// Multipart form data for file uploads
public struct MultipartFormData: Sendable {
    public let fileData: Data
    public let fileName: String
    public let mimeType: String
    public let fieldName: String
    
    public init(
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String = "file"
    ) {
        self.fileData = fileData
        self.fileName = fileName
        self.mimeType = mimeType
        self.fieldName = fieldName
    }
    
    /// Builds the multipart body data with the given boundary
    public func buildBody(boundary: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")
        
        return body
    }
}

// MARK: - Data Extension for Multipart Building

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
