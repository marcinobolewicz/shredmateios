//
//  AuthScreenLayout.swift
//  Login
//

import SwiftUI
import Theme

/// Shared scaffolding for every auth screen (login, register, reset password).
///
/// Wraps the caller's content in a frosted glass card, vertically centred
/// over the shared photo background, inside a `ScrollView` so the keyboard
/// never clips fields. `containerRelativeFrame(.vertical)` sizes the scroll
/// content to the viewport height and centres the card within it; on small
/// devices or when the keyboard appears, the card remains scrollable.
struct AuthScreenLayout<Content: View>: View {

    @Environment(AppTheme.self) private var theme
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .dsFrostedCard()
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.lg)
                .frame(maxWidth: .infinity)
                .containerRelativeFrame(.vertical, alignment: .center)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .dsImageBackground("slide_1")
    }
}
