import Foundation

enum AppStrings: String {
    case guestWelcomeTitle = "app.guest_welcome_title"

    case guestTabHome = "app.guest_tab_home"
    case guestTabExplore = "app.guest_tab_explore"
    case guestTabLogin = "app.guest_tab_login"

    case userTabHome = "app.user_tab_home"
    case userTabSpots = "app.user_tab_spots"
    case userTabChat = "app.user_tab_chat"
    case userTabProfile = "app.user_tab_profile"

    case homeNavigationTitle = "app.home_navigation_title"
    case homeWelcomeTitle = "app.home_welcome_title"
    case homeSignOut = "app.home_sign_out"

    case feedNavigationTitle = "app.feed_navigation_title"

    case guestSlide1Title    = "app.guest_slide1_title"
    case guestSlide1Subtitle = "app.guest_slide1_subtitle"
    case guestSlide1Cta      = "app.guest_slide1_cta"

    case guestSlide2Title    = "app.guest_slide2_title"
    case guestSlide2Subtitle = "app.guest_slide2_subtitle"
    case guestSlide2Cta      = "app.guest_slide2_cta"

    case guestSlide3Title    = "app.guest_slide3_title"
    case guestSlide3Subtitle = "app.guest_slide3_subtitle"
    case guestSlide3Cta      = "app.guest_slide3_cta"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
