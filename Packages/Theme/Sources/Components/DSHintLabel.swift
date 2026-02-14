//
//  DSHintLabel.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Subtle hint text displayed below form fields (e.g. password requirements).
public struct DSHintLabel: View {

    @Environment(AppTheme.self) private var theme

    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(theme.colors.textSecondary)
    }
}
