//
//  DSChip.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Capsule-shaped toggle chip for filter selections (e.g. sport categories).
///
/// Accessibility:
/// - Adds `.isSelected` trait when active so VoiceOver announces selection state.
public struct DSChip: View {

    @Environment(AppTheme.self) private var theme

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(
                    isSelected ? theme.colors.primaryForeground : theme.colors.textPrimary
                )
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.colors.primary : theme.colors.surfaceTertiary)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
