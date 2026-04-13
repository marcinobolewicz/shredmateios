import Foundation

@MainActor
public struct OnboardingStorage: Sendable {
    private static let welcomeShownKey = "welcome_screen_shown"
    private static let pendingKey = "onboarding_pending"

    /// `true` once the first-run welcome screen has been seen on this install.
    public static var isWelcomeShown: Bool {
        UserDefaults.standard.bool(forKey: welcomeShownKey)
    }

    /// `true` when a user has registered but has not yet completed
    /// the onboarding flow. Persists across app launches so a transient
    /// sports-catalog fetch failure can't silently skip onboarding.
    public static var isPending: Bool {
        UserDefaults.standard.bool(forKey: pendingKey)
    }

    public static func markPending() {
        UserDefaults.standard.set(true, forKey: pendingKey)
    }

    public static func clearPending() {
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }

    public static func markWelcomeShown() {
        UserDefaults.standard.set(true, forKey: welcomeShownKey)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: welcomeShownKey)
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }
}
