//
//  ChatRealtimeEvent.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking

/// Events emitted by the chat realtime layer.
///
/// Consumers iterate over an `AsyncStream<ChatRealtimeEvent>` to react
/// to socket-level changes in a concurrency-safe way.
public enum ChatRealtimeEvent: Sendable {
    /// Socket successfully connected (includes socket ID for diagnostics)
    case connected(socketId: String)

    /// Socket disconnected (includes human-readable reason)
    case disconnected(reason: String)

    /// Socket connection error (best-effort, never crashes the app)
    case connectionError(message: String)

    /// A new message arrived via `message:new`
    case messageNew(MessageNewPayload)

    /// A conversation was updated via `conversation:updated`
    case conversationUpdated(ConversationUpdatedPayload)

    /// A sent message was acknowledged via `message:ack`
    case messageAck(MessageAckPayload)
}
