//
//  FlexibleArray.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

/// Decodes an array from two possible JSON shapes:
///
/// - **Bare array**: `[element, element, ...]`
/// - **Wrapped object**: `{ "data": [element, element, ...] }`
///
/// Use as the `Response` type in `Endpoint` when the API may return
/// either format. Access the decoded elements via the `items` property.
///
/// ```swift
/// let endpoint: Endpoint<FlexibleArray<ChatConversation>> = ...
/// let response = try await client.send(endpoint)
/// let conversations: [ChatConversation] = response.items
/// ```
public struct FlexibleArray<Element: Decodable & Sendable>: Decodable, Sendable {
    public let items: [Element]

    public init(items: [Element]) {
        self.items = items
    }

    public init(from decoder: Decoder) throws {
        // Try bare array first (most common path)
        if let container = try? decoder.singleValueContainer(),
           let array = try? container.decode([Element].self) {
            self.items = array
            return
        }

        // Fall back to `{ "data": [...] }` wrapper
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Element].self, forKey: .data)
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }
}
