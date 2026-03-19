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
        Color(red: 0.92, green: 0.88, blue: 0.99), // purple
        Color(red: 0.88, green: 0.94, blue: 1.00), // blue
        Color(red: 1.00, green: 0.88, blue: 0.92), // pink
        Color(red: 1.00, green: 0.97, blue: 0.75), // yellow
        Color(red: 0.88, green: 0.98, blue: 0.92), // green
        Color(red: 1.00, green: 0.90, blue: 0.80)  // orange
    ]

    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.65))
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
