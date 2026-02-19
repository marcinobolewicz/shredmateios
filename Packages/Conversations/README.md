# Conversations Module

Real-time 1-on-1 chat built on REST + Socket.IO. This document covers the full data flow — from the network layer in the `Networking` package up to the SwiftUI views.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                                │
│  ConversationsRootView → ConversationsListView / ChatView       │
│  ViewModels: ConversationsListViewModel, ChatViewModel          │
└───────────────────────┬─────────────────────────────────────────┘
                        │ @Observable observation
┌───────────────────────▼─────────────────────────────────────────┐
│  ChatRepository  (@MainActor, @Observable)                      │
│  Single source of truth for conversations & messages caches     │
└──────┬────────────────────────────────────┬─────────────────────┘
       │ REST (async/await)                 │ Socket events
┌──────▼──────────────┐          ┌──────────▼─────────────────────┐
│  ChatService        │          │  ChatEventHandler              │
│  (Networking pkg)   │          │  iterates AsyncStream           │
└──────┬──────────────┘          └──────────┬─────────────────────┘
       │                                    │
┌──────▼──────────────┐          ┌──────────▼─────────────────────┐
│  ChatAPI (Endpoint)  │          │  ChatRealtimeProviding         │
│  APIClienting        │          │  (protocol)                    │
└─────────────────────┘          └──────────┬─────────────────────┘
                                            │
                                 ┌──────────▼─────────────────────┐
                                 │  SocketIOChatClient             │
                                 │  (Socket.IO SDK)                │
                                 └──────────┬─────────────────────┘
                                            │
                                 ┌──────────▼─────────────────────┐
                                 │  ChatLifecycleManager          │
                                 │  auth + foreground/background   │
                                 └────────────────────────────────┘
```

---

## REST Layer (Networking Package)

### Endpoints — `ChatAPI`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/chat/conversations?take=&cursor=` | Paginated list of conversations (newest first) |
| `POST` | `/chat/conversations/with/:otherUserId` | Open existing or create new conversation |
| `GET` | `/chat/conversations/:id/messages?take=&cursor=` | Paginated messages (newest first from API) |
| `POST` | `/chat/conversations/:id/messages` | Send message (`{ "type": "TEXT", "text": "..." }`) |

All endpoints require `Authorization: Bearer <accessToken>`. Auth injection and 401→refresh→retry are handled transparently by `APIClienting` / `AuthenticatingHTTPClient`.

### Pagination — `PaginationParams`

Cursor-based: `take` (page size, 1–100, default 20), `cursor` (ID of last item from previous page, `nil` for first page). The API returns items sorted descending; caller reverses for chronological display.

### Models

| Model | Key fields |
|-------|-----------|
| `ChatConversation` | `id`, `otherUser: ChatUser`, `lastMessage: ChatMessage?`, `lastMessageAt` |
| `ChatMessage` | `id`, `conversationId`, `senderId`, `type` (TEXT/IMAGE), `content`, `createdAt`, `sender: MessageSender?` |
| `ChatUser` | `id`, `name`, `avatarUrl`, `email` |
| `MessageSender` | `id`, `email`, `rider: RiderInfo` (nested profile) |

### Service — `ChatServiceProtocol` / `ChatService`

Thin wrapper over `APIClienting`. Unwraps `FlexibleArray` responses into plain arrays. The protocol enables mocking for unit tests.

---

## Socket Layer — Abstraction Levels

The socket layer has **four levels of abstraction**, from lowest to highest:

### Level 1: `SocketIOChatClient` (Transport)

Concrete implementation of `ChatRealtimeProviding`. Wraps the Socket.IO SDK.

**Thread safety:** All Socket.IO objects (`SocketManager`, `SocketIOClient`) are confined to a dedicated `socketQueue` (serial `DispatchQueue`). Shared state (`_currentToken`, `_isConnected`, `streamContinuation`) is protected by `NSLock`. The class is `@unchecked Sendable` — safe to call from any actor.

**Connection config:**
- URL: `https://api.shredmate.eu`, namespace: `/chat`
- Auth: JWT sent as `handshake.auth.token` (Socket.IO v4 auth payload, not query params)
- Reconnection: up to 10 attempts, max 5s delay, 10s timeout
- Transport: long-polling with automatic websocket upgrade

**Key operations:**
- `connect(token:)` — tears down existing connection, rebuilds the `AsyncStream`, creates new `SocketManager` + `SocketIOClient`, registers event handlers, connects with auth payload.
- `disconnect()` — removes handlers, disconnects socket + manager, sets `_isConnected = false`.
- `reconnectIfNeeded(newToken:)` — only reconnects if token changed or socket is disconnected. This avoids unnecessary disruption on foreground resume.

**Event handling:** Registers handlers for three Socket.IO client events (`connect`, `disconnect`, `error`) and three custom server events (`message:new`, `conversation:updated`, `message:ack`). Raw payloads (dictionaries) are serialized to `Data` via `JSONSerialization`, then decoded into strongly-typed payload structs. Decoded events are emitted into the `AsyncStream<ChatRealtimeEvent>`.

**Stream lifecycle:** Each `connect()` call creates a fresh `AsyncStream` (via `buildStream()`). The previous continuation is finished, so old consumers terminate cleanly. Only one consumer should iterate at a time.

### Level 2: `ChatRealtimeProviding` (Protocol)

Abstraction consumed by higher layers. Decouples the rest of the app from Socket.IO:

```swift
protocol ChatRealtimeProviding: Sendable {
    var isConnected: Bool { get }
    func connect(token: String)
    func disconnect()
    func reconnectIfNeeded(newToken: String)
    var events: AsyncStream<ChatRealtimeEvent> { get }
}
```

Inject this protocol (not the concrete client) into managers and repositories to enable mocking.

### Level 3: `ChatEventHandler` (Event Bridge)

Bridges the `AsyncStream<ChatRealtimeEvent>` into `ChatRepository` mutations:

```
Socket event         → ChatEventHandler dispatches to:
─────────────────────────────────────────────────────
message:new          → repository.handleMessageNew(payload)
conversation:updated → repository.handleConversationUpdated(payload)
message:ack          → logged only (future: delivery confirmation UI)
connected/disconnected/error → logged for diagnostics
```

**Lifecycle:** `startListening()` spawns a `Task` that iterates the stream. `stopListening()` cancels it. Calling `startListening()` again automatically cancels the previous listener (idempotent).

### Level 4: `ChatLifecycleManager` (Auth + App Lifecycle)

Orchestrates **when** the socket connects/disconnects based on:

1. **Authentication state** — `onAuthenticated()` fetches `accessToken` from `AuthState` and calls `connect(token:)`. `onLogout()` calls `disconnect()`.
2. **Foreground resume** — Observes `UIApplication.willEnterForegroundNotification`. On resume: checks if still logged in, proactively triggers token refresh if expired, then calls `reconnectIfNeeded(newToken:)`.

This class is `@MainActor`-isolated (same as `AuthState`).

### Socket Events — Payload Types

Defined in `Networking/Models/ChatSocketPayloads.swift`:

| Event | Payload struct | Key fields |
|-------|---------------|------------|
| `message:new` | `MessageNewPayload` | `id`, `conversationId`, `senderId`, `createdAt`, `type`, `text?`, `imageUrl?` |
| `conversation:updated` | `ConversationUpdatedPayload` | `conversationId`, `otherUserId`, `lastMessageAt?`, `lastMessage?` |
| `message:ack` | `MessageAckPayload` | `messageId`, `conversationId`, `createdAt` |

`MessageNewPayload.toChatMessage()` converts a socket payload into a `ChatMessage` with a placeholder `sender` (socket doesn't provide full sender data). The subsequent REST re-fetch fills in complete sender info.

---

## Data Layer — `ChatRepository`

Central `@MainActor @Observable` state manager. Both REST responses and socket events flow through it.

### State

```swift
// Conversations (sorted newest-first)
conversations: [ChatConversation]
isLoadingConversations: Bool
hasMoreConversations: Bool

// Messages keyed by conversationId (sorted oldest-first for UI)
messagesByConversation: [String: [ChatMessage]]
isLoadingMessages: [String: Bool]
hasMoreMessages: [String: Bool]
```

### Core Principle: REST is Source of Truth

Socket events provide **instant optimistic updates** — the payload is inserted into the cache immediately for snappy UI. But every socket event also triggers a **REST re-fetch** (`loadConversations(refresh: true)`, `loadMessages(for:, refresh: true)`) to ensure eventual consistency. This means:

- `handleMessageNew(payload)` → optimistic append → Task: re-fetch messages + conversations
- `handleConversationUpdated(payload)` → move conversation to top → Task: re-fetch conversations + messages

### Deduplication

All insert operations (`appendConversations`, `prependMessages`, `appendMessageIfNew`) check for existing IDs before inserting. This prevents duplicates when both the socket event and the subsequent REST refresh return the same item.

### Pagination

- **Conversations:** cursor-based, load pages via `loadConversations(refresh:)` / `loadNextConversationsPage()`.
- **Messages:** cursor-based per conversation. API returns newest-first; repository reverses to oldest-first. Older pages are prepended. `loadOlderMessages(for:)` implements infinite scroll up.

---

## View Layer

### Navigation — `ConversationsRouter`

`@Observable` router with a `NavigationPath`. Routes defined in `ConversationsRoute`:

```swift
enum ConversationsRoute: Hashable {
    case chat(conversationId: String, participantName: String)
}
```

`ConversationsNavigationDestinations` (ViewModifier) maps routes to destination views.

### Screen: Conversations List

`ConversationsRootView` → `ConversationsListView` + `ConversationsListViewModel`

- Loads conversations on appear via `ChatRepository.loadConversations()`.
- Infinite scroll: `onRowAppear` on last row triggers `loadNextPage()`.
- Pull-to-refresh: `loadConversations(refresh: true)`.
- `ConversationRowPresenter` maps `ChatConversation` → `ConversationRowViewData` (display model).
- Observes `repository.conversations` via `withObservationTracking` for live socket updates.
- Tap → navigates to `ConversationsRoute.chat(...)`.

### Screen: Chat

`ChatView` + `ChatViewModel`

- Loads messages on appear via `repository.loadMessages(for:, refresh: true)`.
- Infinite scroll **up**: `ProgressView` at top triggers `loadOlderMessages()` with scroll anchor preservation.
- Auto-scroll to bottom on new messages via `ScrollViewReader`.
- Observes `repository.messages(for:)` — automatically syncs when socket events modify the cache.
- Send: `repository.sendMessage(conversationId:, text:)` with optimistic input clearing. On failure, text is restored.
- `MessageBubbleView`: current user messages on right (primary color), other user on left (surface color).

### Screen: New Conversation

`NewConversationView` + `NewConversationViewModel`

- Fetches available riders via `RiderServiceProtocol`.
- Search/filter UI.
- `startConversation(with:)` → `repository.openOrCreateConversation(otherUserId:)` → navigates to chat.
- Presented as `.fullScreenCover` from `ConversationsRootView`.

---

## Data Flow: Receiving a Message (End-to-End)

```
1. Server emits Socket.IO event "message:new" with JSON payload
2. SocketIOChatClient handler decodes it into MessageNewPayload
3. Emits ChatRealtimeEvent.messageNew(payload) into AsyncStream
4. ChatEventHandler receives event, calls repository.handleMessageNew(payload)
5. ChatRepository:
   a. Converts payload → ChatMessage (placeholder sender)
   b. Appends to messagesByConversation[conversationId] (deduplicated)
   c. Spawns Task: re-fetch messages + conversations via REST
6. ChatViewModel observes repository.messages(for:) change via withObservationTracking
7. Calls syncMessages() → remaps ChatMessage[] to MessageViewData[]
8. SwiftUI re-renders ChatView with new bubble
```

## Data Flow: Sending a Message (End-to-End)

```
1. User taps Send in ChatInputView
2. ChatViewModel.send() clears input, calls repository.sendMessage()
3. ChatRepository calls chatService.sendMessage() (REST POST)
4. On success: appends returned ChatMessage to cache, re-fetches conversations
5. syncMessages() updates the view
6. Meanwhile, server broadcasts "message:new" to the other participant via socket
7. If sender also receives the socket event, it's deduplicated by message ID
```

---

## Threading Summary

| Component | Isolation | Why |
|-----------|-----------|-----|
| `ChatRepository` | `@MainActor` | Observable state drives SwiftUI |
| `ChatEventHandler` | `@MainActor` | Accesses repository |
| `ChatLifecycleManager` | `@MainActor` | Observes `AuthState` + UIKit notifications |
| `SocketIOChatClient` | `socketQueue` + `NSLock` | Socket.IO objects aren't Sendable |
| ViewModels | `@MainActor` | SwiftUI observation |
| `ChatService` | `Sendable` (stateless) | Safe from any context |

## Key Dependencies

- **SocketIO** (SPM) — [socketio/socket.io-client-swift](https://github.com/socketio/socket.io-client-swift)
- **Networking** package — `APIClienting`, `AuthState`, `ChatService`, models
- **Theme** package — design system tokens (`AppTheme`, `dsTextStyle`, etc.)
- **Common** package — shared UI components (`DSSearchBar`, `LoadState`, localization)
