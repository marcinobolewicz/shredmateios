//
//  DeepLink.swift
//  ShredMate
//

import Foundation
import Onboarding

/// Every place in the app a deep link can land.
///
/// One enum, one source of truth — used by:
/// - the onboarding success step (translates a CTA tap into a destination),
/// - push notification handlers (parses APNs payloads into a destination),
/// - in-app notifications (chat banner taps),
/// - future URL handlers (universal links / custom schemes).
///
/// Adding a new destination is a single case here plus a single switch
/// arm in `AppRouter.handle(_:)`. Call sites never reach into a feature
/// router directly.
enum DeepLink: Sendable, Equatable {
    case home
    case editProfile
    case explorePlaces
    case findMentor
    case addSlots
    case conversation(id: String, participantName: String)
}

// MARK: - Bridges from feature-local intent enums

extension OnboardingDestination {
    /// Maps the onboarding success CTAs onto the app-wide deep link
    /// vocabulary. Kept here (not in `Onboarding`) so the onboarding
    /// module stays unaware of how the host app names its destinations.
    var deepLink: DeepLink {
        switch self {
        case .editProfile: return .editProfile
        case .explorePlaces: return .explorePlaces
        case .findMentor: return .findMentor
        case .addSlots: return .addSlots
        }
    }
}

