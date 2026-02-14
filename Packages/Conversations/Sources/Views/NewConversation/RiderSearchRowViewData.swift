//
//  RiderSearchRowViewData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

struct RiderSearchRowViewData: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let avatarInitials: String
    let avatarURL: URL?
}
