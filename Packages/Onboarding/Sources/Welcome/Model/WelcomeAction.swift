//
//  WelcomeAction.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import Foundation

/// Actions the first-run welcome screen can emit to the host.
///
/// The view is intentionally decoupled from routing — it only describes
/// what the user wants to do next; the host decides how to handle it
/// (open the auth flow, switch to the guest tabs, etc.).
public enum WelcomeAction: Equatable, Sendable {
    case signUp
    case signIn
    case later
}
