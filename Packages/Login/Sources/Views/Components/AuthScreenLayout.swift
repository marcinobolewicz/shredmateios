//
//  AuthScreenLayout.swift
//  Login
//

import SwiftUI
import Theme

/// Shared scaffolding for every auth screen (login, register, reset password).
///
/// Wraps the caller's content in a `ScrollView` so the keyboard never clips
/// fields, then drops the content into a frosted glass card centred over the
/// shared photo background owned by `AuthFlowView`. Top padding leaves room
/// for the close-button overlay.
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
                .padding(.top, theme.spacing.xxl)
                .padding(.bottom, theme.spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .dsImageBackground("slide_1")
    }
}
