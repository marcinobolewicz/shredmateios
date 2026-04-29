//
//  ChatRequests.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

// MARK: - Send Message Input

/// Tagged union for sending messages.
///
/// Encodes to JSON as:
/// ```json
/// { "type": "TEXT", "text": "message content" }
/// ```
public enum SendMessageInput: Sendable, Equatable {
    case text(String)
}

extension SendMessageInput: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let value):
            try container.encode(MessageType.text, forKey: .type)
            try container.encode(value, forKey: .text)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case text
    }
}

// MARK: - Mark as Read Response

/// Response body for `POST /chat/conversations/:conversationId/read`.
public struct MarkAsReadResponse: Decodable, Sendable, Equatable {
    public let lastReadAt: String

    public init(lastReadAt: String) {
        self.lastReadAt = lastReadAt
    }
}

// MARK: - Pagination

/// Cursor-based pagination parameters for chat endpoints.
///
/// - `take`: page size, clamped to range 1...100 (default 20)
/// - `cursor`: ID of the last element from the previous page, `nil` for first page
public struct PaginationParams: Sendable, Equatable {
    public let take: Int
    public let cursor: String?

    public init(take: Int = 20, cursor: String? = nil) {
        self.take = min(max(take, 1), 100)
        self.cursor = cursor
    }

    /// Whether this represents a request for the first page
    public var isFirstPage: Bool { cursor == nil }
}
