import Foundation

@MainActor
public struct OnboardingStorage: Sendable {
    private static let completedKey = "onboarding_completed"

    public static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    public static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    public static func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}
