//
//  PlaceDetailsGuestGate.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 08/04/2026.
//

import SwiftUI
import Theme

/// Locked-content placeholder shown on the place details screen when the
/// viewer is not signed in. Replaces the riders/mentors/map sections with a
/// short explanation and a sign-in CTA.
struct PlaceDetailsGuestGate: View {
    @Environment(AppTheme.self) private var theme
    let onSignInTap: (() -> Void)?

    var body: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(theme.colors.textTertiary)

            Text(PlacesStrings.detailsGuestGateTitle.localized)
                .dsTextStyle(.heading)
                .multilineTextAlignment(.center)

            Text(PlacesStrings.detailsGuestGateDescription.localized)
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)

            if let onSignInTap {
                Button(PlacesStrings.detailsGuestGateSignIn.localized, action: onSignInTap)
                    .buttonStyle(.dsPrimary)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity)
        .background(theme.colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }
}
