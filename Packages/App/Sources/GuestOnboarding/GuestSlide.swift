import Foundation

/// Data model for a single full-screen guest onboarding slide.
struct GuestSlide: Identifiable {
    let id: String
    let imageURL: URL
    let title: String
    let subtitle: String
    let ctaTitle: String
}

extension GuestSlide {
    /// All onboarding slides in display order.
    static let all: [GuestSlide] = [
        GuestSlide(
            id: "instructor",
            imageURL: URL(string: "https://images.unsplash.com/photo-1498146831523-fbe41acdc5ad?w=840&h=1920&fit=crop")!,
            title: AppStrings.guestSlide1Title.localized,
            subtitle: AppStrings.guestSlide1Subtitle.localized,
            ctaTitle: AppStrings.guestSlide1Cta.localized
        ),
        GuestSlide(
            id: "buddy",
            imageURL: URL(string: "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=840&h=1920&fit=crop")!,
            title: AppStrings.guestSlide2Title.localized,
            subtitle: AppStrings.guestSlide2Subtitle.localized,
            ctaTitle: AppStrings.guestSlide2Cta.localized
        ),
        GuestSlide(
            id: "sessions",
            imageURL: URL(string: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=840&h=1920&fit=crop")!,
            title: AppStrings.guestSlide3Title.localized,
            subtitle: AppStrings.guestSlide3Subtitle.localized,
            ctaTitle: AppStrings.guestSlide3Cta.localized
        )
    ]
}
