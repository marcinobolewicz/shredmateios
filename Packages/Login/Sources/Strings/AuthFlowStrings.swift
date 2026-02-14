//
//  AuthFlowStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum AuthFlowStrings: String {
    case closeAccessibilityLabel = "auth_flow.close_accessibility_label"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
