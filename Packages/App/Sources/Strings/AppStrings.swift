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

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
