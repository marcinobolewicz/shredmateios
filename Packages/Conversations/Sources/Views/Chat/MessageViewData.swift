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
}
