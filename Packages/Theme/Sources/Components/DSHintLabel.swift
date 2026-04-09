//
//  DSHintLabel.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Subtle hint text displayed below form fields (e.g. password requirements).
///
/// Defaults to `textSecondary` for hints sitting on the app background, but
/// callers can point at another token (e.g. `primaryForeground`) together
/// with an opacity when the label lives on a darkened surface like the
/// frosted auth card, where secondary gray is unreadable.
public struct DSHintLabel: View {

    @Environment(AppTheme.self) private var theme

    private let message: String
    private let color: KeyPath<ColorTokens, Color>
    private let opacity: Double

    public init(
        _ message: String,
        color: KeyPath<ColorTokens, Color> = \.textSecondary,
        opacity: Double = 1
    ) {
        self.message = message
        self.color = color
        self.opacity = opacity
    }

    public var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(theme.colors[keyPath: color].opacity(opacity))
    }
}
