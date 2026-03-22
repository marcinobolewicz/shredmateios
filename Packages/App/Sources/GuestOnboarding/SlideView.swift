import SwiftUI
import Theme

/// Single onboarding slide: full-bleed background image with a scrim and
/// centred title / subtitle / CTA overlaid on top — similar to a web hero section.
struct SlideView: View {
    let slide: GuestSlide
    var onCTATap: (() -> Void)?

    var body: some View {
        ZStack {
            // MARK: Background
            Image(slide.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()

            // MARK: Scrim
            LinearGradient(
                colors: [.black.opacity(0.15), .black.opacity(0.60)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // MARK: Content
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Button(slide.ctaTitle) { onCTATap?() }
                    .buttonStyle(.dsPrimary)
            }
            .padding(.horizontal, 24)
            .safeAreaPadding()
        }
        .ignoresSafeArea()
    }
}
