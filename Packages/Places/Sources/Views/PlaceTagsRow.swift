//
//  PlaceTagsRow.swift
//  ShredMate
//

import SwiftUI
import Theme

// MARK: - Tag Pill Style Modifier

private struct TagPillModifier: ViewModifier {
    @Environment(AppTheme.self) private var theme
    let index: Int

    static let palette: [Color] = [
        Color(red: 0.72, green: 0.62, blue: 0.96), // purple
        Color(red: 0.58, green: 0.78, blue: 0.98), // blue
        Color(red: 0.98, green: 0.62, blue: 0.78), // pink
        Color(red: 0.99, green: 0.88, blue: 0.38), // yelow
        Color(red: 0.58, green: 0.92, blue: 0.68), // green
        Color(red: 0.99, green: 0.72, blue: 0.50)  // orange
    ]

    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.xs + 2)
            .padding(.vertical, theme.spacing.xxs + 2)
            .background(
                Capsule().fill(Self.palette[index % Self.palette.count])
            )
    }
}

extension View {
    func tagPillStyle(index: Int) -> some View {
        modifier(TagPillModifier(index: index))
    }
}

// MARK: - PlaceTagPill

struct PlaceTagPill: View {
    let text: String
    let index: Int

    var body: some View {
        Text(text).tagPillStyle(index: index)
    }
}

// MARK: - PlaceTagsRow

struct PlaceTagsRow: View {
    @Environment(AppTheme.self) private var theme
    let tags: [String]
    var horizontalContentPadding: CGFloat = 0

    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        PlaceTagPill(text: tag, index: index)
                    }
                }
                .padding(.horizontal, horizontalContentPadding)
            }
        }
    }
}
