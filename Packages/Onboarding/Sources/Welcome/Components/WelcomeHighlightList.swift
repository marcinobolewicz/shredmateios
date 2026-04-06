//
//  WelcomeHighlightList.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Vertical list of scannable bullet points describing the product promise.
struct WelcomeHighlightList: View {

    @Environment(AppTheme.self) private var theme
    let highlights: [WelcomeHighlight]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(highlights) { highlight in
                WelcomeHighlightRow(text: highlight.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Row

private struct WelcomeHighlightRow: View {

    @Environment(AppTheme.self) private var theme
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            bullet
            Text(text)
                .dsTextStyle(.body, color: \.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var bullet: some View {
        Circle()
            .fill(theme.colors.primary)
            .frame(width: Self.bulletSize, height: Self.bulletSize)
            .alignmentGuide(.firstTextBaseline) { dim in dim[.bottom] - Self.bulletBaselineNudge }
    }

    private static let bulletSize: CGFloat = 6
    private static let bulletBaselineNudge: CGFloat = 2
}
