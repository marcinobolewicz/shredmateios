//
//  MessageViewData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

struct MessageViewData: Identifiable, Equatable, Sendable {
    let id: String
    let text: String
    let timeText: String
    let isFromCurrentUser: Bool
    /// For messages sent by the current user: whether the other participant has seen them.
    /// `false` for incoming messages — the sender-side double-tick is always hidden there.
    let isRead: Bool
}
