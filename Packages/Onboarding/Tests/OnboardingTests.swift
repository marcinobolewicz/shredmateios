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

    @Test("pending flag defaults to false")
    func pendingFlagDefaultsToFalse() {
        OnboardingStorage.reset()
        #expect(OnboardingStorage.isPending == false)
    }

    @Test("markPending sets the flag, clearPending removes it")
    func markAndClearPending() {
        OnboardingStorage.reset()
        OnboardingStorage.markPending()
        #expect(OnboardingStorage.isPending == true)
        OnboardingStorage.clearPending()
        #expect(OnboardingStorage.isPending == false)
    }

    @Test("reset clears all flags")
    func resetClearsAllFlags() {
        OnboardingStorage.markWelcomeShown()
        OnboardingStorage.markPending()
        OnboardingStorage.reset()
        #expect(OnboardingStorage.isWelcomeShown == false)
        #expect(OnboardingStorage.isPending == false)
    }

    // MARK: - WelcomeAction

    @Test("WelcomeAction cases are distinct")
    func welcomeActionEquality() {
        #expect(WelcomeAction.signUp != .signIn)
        #expect(WelcomeAction.signIn != .later)
        #expect(WelcomeAction.signUp != .later)
    }
}
