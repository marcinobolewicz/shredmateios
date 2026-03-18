import SwiftUI
import Theme

/// Single onboarding slide: full-bleed background image with a scrim and
/// centred title / subtitle / CTA overlaid on top — similar to a web hero section.
struct SlideView: View {
    let slide: GuestSlide
    var onCTATap: (() -> Void)?

    @Environment(\.pageSafeAreaInsets) private var safeAreaInsets

    var body: some View {
        ZStack {
            // MARK: Background
            AsyncImage(url: slide.imageURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure:            Color(.systemGray5)
                default:                  Color(.systemGray6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            // MARK: Scrim
            LinearGradient(
                colors: [.black.opacity(0.15), .black.opacity(0.60)],
                startPoint: .top,
                endPoint: .bottom
            )

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
            .padding(.top, safeAreaInsets.top)
            .padding(.bottom, safeAreaInsets.bottom)
        }
    }
}
