import Foundation

/// Vertical placement of content overlay on a slide.
enum SlideContentAlignment {
    case top, center, bottom
}

/// Data model for a single full-screen guest onboarding slide.
struct GuestSlide: Identifiable {
    let id: String
    let imageName: String
    let title: String
    let subtitle: String
    let ctaTitle: String
    var contentAlignment: SlideContentAlignment = .center
    var targetTab: GuestTab = .login
}

extension GuestSlide {
    /// All onboarding slides in display order.
    static let all: [GuestSlide] = [
        GuestSlide(
            id: "slide_0",
            imageName: "slide_0",
            title: AppStrings.guestSlide1Title.localized,
            subtitle: AppStrings.guestSlide1Subtitle.localized,
            ctaTitle: AppStrings.guestSlide1Cta.localized,
            contentAlignment: .top
        ),
        GuestSlide(
            id: "slide_1",
            imageName: "slide_1",
            title: AppStrings.guestSlide2Title.localized,
            subtitle: AppStrings.guestSlide2Subtitle.localized,
            ctaTitle: AppStrings.guestSlide2Cta.localized,
            contentAlignment: .bottom
        ),
        GuestSlide(
            id: "slide_2",
            imageName: "slide_2",
            title: AppStrings.guestSlide3Title.localized,
            subtitle: AppStrings.guestSlide3Subtitle.localized,
            ctaTitle: AppStrings.guestSlide3Cta.localized,
            contentAlignment: .bottom,
            targetTab: .explore
        ),
        GuestSlide(
            id: "slide_3",
            imageName: "slide_3",
            title: AppStrings.guestSlide4Title.localized,
            subtitle: AppStrings.guestSlide4Subtitle.localized,
            ctaTitle: AppStrings.guestSlide4Cta.localized,
            contentAlignment: .bottom
        )
    ]
}
