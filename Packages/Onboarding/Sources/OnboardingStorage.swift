import Foundation

@MainActor
public struct OnboardingStorage: Sendable {
    private static let completedKey = "onboarding_completed"
    private static let welcomeShownKey = "welcome_screen_shown"

    public static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    /// `true` once the first-run welcome screen has been seen on this install.
    public static var isWelcomeShown: Bool {
        UserDefaults.standard.bool(forKey: welcomeShownKey)
    }

    public static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    public static func markWelcomeShown() {
        UserDefaults.standard.set(true, forKey: welcomeShownKey)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
        UserDefaults.standard.removeObject(forKey: welcomeShownKey)
    }
}
