//
//  SocketIOChatClient.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import SocketIO
import Networking
import os.log

private let logger = Logger(subsystem: "com.shredmate.chat", category: "SocketIO")

/// Concrete ``ChatRealtimeProviding`` implementation backed by Socket.IO.
///
/// All Socket.IO objects (`SocketManager`, `SocketIOClient`) are confined to
/// `socketQueue` — they are not `Sendable` and must never escape that queue.
/// The public API is safe to call from any thread/actor.
///
/// ## Configuration
/// - URL: `https://api.shredmate.eu` with namespace `/chat`
/// - Auth: `handshake.auth.token = <accessToken>`
/// - Reconnection: up to 10 attempts, max 5 s delay, 10 s timeout
/// - Transport: polling → websocket upgrade (default, not forced)
public final class SocketIOChatClient: ChatRealtimeProviding, @unchecked Sendable {

    // MARK: - Configuration

    private let socketURL: URL
    private let namespace: String

    // MARK: - Socket.IO objects (access ONLY on socketQueue)

    private let socketQueue = DispatchQueue(label: "com.shredmate.chat.socket", qos: .userInitiated)
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    // MARK: - Shared state (protected by lock)

    private let lock = NSLock()
    private var _currentToken: String?
    private var _isConnected = false

    // MARK: - Event stream

    /// Lock-protected continuation; replaced on each `connect` / `disconnect`.
    private var streamContinuation: AsyncStream<ChatRealtimeEvent>.Continuation?
    private var _events: AsyncStream<ChatRealtimeEvent>?

    // MARK: - JSON decoding

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // MARK: - Init

    /// Creates a client pointing at the given origin and namespace.
    ///
    /// - Parameters:
    ///   - url: Socket.IO server origin (e.g. `https://api.shredmate.eu`).
    ///   - namespace: Socket.IO namespace (e.g. `/chat`).
    public init(
        url: URL = URL(string: "https://api.shredmate.eu")!,
        namespace: String = "/chat"
    ) {
        self.socketURL = url
        self.namespace = namespace
        buildStream()
    }

    deinit {
        lock.lock()
        streamContinuation?.finish()
        lock.unlock()
    }

    // MARK: - ChatRealtimeProviding

    public var isConnected: Bool {
        lock.withLock { _isConnected }
    }

    public var events: AsyncStream<ChatRealtimeEvent> {
        lock.withLock { _events! }
    }

    public func connect(token: String) {
        lock.withLock { _currentToken = token }

        socketQueue.async { [weak self] in
            self?.performConnect(token: token)
        }
    }

    public func disconnect() {
        socketQueue.async { [weak self] in
            self?.performDisconnect()
        }
    }

    public func reconnectIfNeeded(newToken: String) {
        let tokenChanged: Bool = lock.withLock {
            let changed = newToken != _currentToken
            _currentToken = newToken
            return changed
        }

        let connected = isConnected

        if tokenChanged || !connected {
            logger.info("Reconnect needed — tokenChanged: \(tokenChanged), connected: \(connected)")
            socketQueue.async { [weak self] in
                self?.performDisconnect()
                self?.performConnect(token: newToken)
            }
        }
    }

    // MARK: - Stream Management

    /// Replaces the current event stream + continuation.
    /// Previous stream consumers will receive `.finished`.
    private func buildStream() {
        lock.lock()
        streamContinuation?.finish()
        let (stream, continuation) = AsyncStream<ChatRealtimeEvent>.makeStream()
        _events = stream
        streamContinuation = continuation
        lock.unlock()
    }

    private func emit(_ event: ChatRealtimeEvent) {
        lock.withLock { streamContinuation?.yield(event) }
    }

    // MARK: - Socket.IO Operations (socketQueue only)

    private func performConnect(token: String) {
        dispatchPrecondition(condition: .onQueue(socketQueue))

        // Tear down any existing connection
        performDisconnect()

        logger.info("Connecting to \(self.socketURL.absoluteString)\(self.namespace)")

        let config: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .reconnects(true),
            .reconnectAttempts(10),
            .reconnectWaitMax(5),
            .forceNew(true)
        ]

        let mgr = SocketManager(socketURL: socketURL, config: config)
        manager = mgr

        let sock = mgr.socket(forNamespace: namespace)
        socket = sock

        registerEventHandlers(on: sock)
        // Send token via auth payload (Socket.IO v4: handshake.auth.token)
        // instead of connectParams (which only sets handshake.query)
        sock.connect(withPayload: ["token": token])
    }

    private func performDisconnect() {
        dispatchPrecondition(condition: .onQueue(socketQueue))

        socket?.removeAllHandlers()
        socket?.disconnect()
        socket = nil
        manager?.disconnect()
        manager = nil

        lock.withLock { _isConnected = false }
    }

    // MARK: - Event Handlers (socketQueue only)

    private func registerEventHandlers(on socket: SocketIOClient) {
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self else { return }
            guard let sid = socket.sid else {
                logger.error("Failed to retrieve socket ID")
                return
            }
            lock.withLock { _isConnected = true }
            logger.info("✅ Socket connected — sid: \(sid)")
            emit(.connected(socketId: sid))
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            guard let self else { return }
            let reason = (data.first as? String) ?? "unknown"
            lock.withLock { _isConnected = false }
            logger.info("🔌 Socket disconnected — reason: \(reason)")
            emit(.disconnected(reason: reason))
        }

        socket.on(clientEvent: .error) { [weak self] data, _ in
            guard let self else { return }
            let message = (data.first as? String) ?? String(describing: data)
            logger.error("❌ Socket error: \(message)")
            emit(.connectionError(message: message))
        }

        socket.on("message:new") { [weak self] data, _ in
            self?.handlePayload(data, as: MessageNewPayload.self) { payload in
                logger.debug("📩 message:new — id: \(payload.id), conv: \(payload.conversationId)")
                return .messageNew(payload)
            }
        }

        socket.on("conversation:updated") { [weak self] data, _ in
            self?.handlePayload(data, as: ConversationUpdatedPayload.self) { payload in
                logger.debug("🔄 conversation:updated — id: \(payload.conversationId)")
                return .conversationUpdated(payload)
            }
        }

        socket.on("conversation:read") { [weak self] data, _ in
            self?.handlePayload(data, as: ConversationReadPayload.self) { payload in
                logger.debug("👁 conversation:read — id: \(payload.conversationId), reader: \(payload.readerId)")
                return .conversationRead(payload)
            }
        }

        socket.on("message:ack") { [weak self] data, _ in
            self?.handlePayload(data, as: MessageAckPayload.self) { payload in
                logger.debug("✓ message:ack — id: \(payload.messageId)")
                return .messageAck(payload)
            }
        }
    }

    // MARK: - Payload Decoding

    /// Decodes the first element of `data` into `T` and emits the mapped event.
    private func handlePayload<T: Decodable>(
        _ data: [Any],
        as type: T.Type,
        map: (T) -> ChatRealtimeEvent
    ) {
        let typeName = String(describing: T.self)

        guard let raw = data.first else {
            logger.warning("Empty payload for \(typeName)")
            return
        }

        do {
            let jsonData: Data
            if let dict = raw as? [String: Any] {
                jsonData = try JSONSerialization.data(withJSONObject: dict)
            } else if let array = raw as? [Any] {
                jsonData = try JSONSerialization.data(withJSONObject: array)
            } else {
                let rawType = String(describing: Swift.type(of: raw))
                logger.error("Unexpected payload type for \(typeName): \(rawType)")
                return
            }

            let payload = try decoder.decode(T.self, from: jsonData)
            emit(map(payload))
        } catch {
            logger.error("Failed to decode \(typeName): \(error.localizedDescription)")
        }
    }
}
