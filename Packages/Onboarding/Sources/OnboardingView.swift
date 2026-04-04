import SwiftUI

public struct OnboardingView: View {
    private let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Onboarding")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Button("Continue") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
