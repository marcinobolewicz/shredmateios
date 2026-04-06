import Foundation
import Testing
@testable import Onboarding

@Suite("Onboarding Tests")
@MainActor
struct OnboardingTests {

    // MARK: - OnboardingStorage

    @Test("welcome flag defaults to false on a fresh install")
    func welcomeFlagDefaultsToFalse() {
        OnboardingStorage.reset()
        #expect(OnboardingStorage.isWelcomeShown == false)
    }

    @Test("markWelcomeShown flips the welcome flag to true")
    func markWelcomeShownFlipsFlag() {
        OnboardingStorage.reset()
        OnboardingStorage.markWelcomeShown()
        #expect(OnboardingStorage.isWelcomeShown == true)
    }

    @Test("reset clears both completed and welcome flags")
    func resetClearsBothFlags() {
        OnboardingStorage.markCompleted()
        OnboardingStorage.markWelcomeShown()
        OnboardingStorage.reset()
        #expect(OnboardingStorage.isCompleted == false)
        #expect(OnboardingStorage.isWelcomeShown == false)
    }

    // MARK: - WelcomeAction

    @Test("WelcomeAction cases are distinct")
    func welcomeActionEquality() {
        #expect(WelcomeAction.signUp != .signIn)
        #expect(WelcomeAction.signIn != .later)
        #expect(WelcomeAction.signUp != .later)
    }
}
