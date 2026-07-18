import Foundation

enum AppStrings: String {
    case guestWelcomeTitle = "app.guest_welcome_title"

    case guestTabHome = "app.guest_tab_home"
    case guestTabExplore = "app.guest_tab_explore"
    case guestTabLogin = "app.guest_tab_login"

    case userTabHome = "app.user_tab_home"
    case userTabSpots = "app.user_tab_spots"
    case userTabChat = "app.user_tab_chat"
    case userTabMentors = "app.user_tab_mentors"
    case userTabProfile = "app.user_tab_profile"

    case homeNavigationTitle = "app.home_navigation_title"
    case homeWelcomeTitle = "app.home_welcome_title"
    case homeSignOut = "app.home_sign_out"

    case guestSlide1Title    = "app.guest_slide1_title"
    case guestSlide1Subtitle = "app.guest_slide1_subtitle"
    case guestSlide1Cta      = "app.guest_slide1_cta"

    case guestSlide2Title    = "app.guest_slide2_title"
    case guestSlide2Subtitle = "app.guest_slide2_subtitle"
    case guestSlide2Cta      = "app.guest_slide2_cta"

    case guestSlide3Title    = "app.guest_slide3_title"
    case guestSlide3Subtitle = "app.guest_slide3_subtitle"
    case guestSlide3Cta      = "app.guest_slide3_cta"

    case guestSlide4Title    = "app.guest_slide4_title"
    case guestSlide4Subtitle = "app.guest_slide4_subtitle"
    case guestSlide4Cta      = "app.guest_slide4_cta"

    case legalUpdateTitle    = "app.legal_update_title"
    case legalUpdateMessage  = "app.legal_update_message"
    case legalDocTerms       = "app.legal_doc_terms"
    case legalDocMentorTerms = "app.legal_doc_mentor_terms"
    case legalDocPrivacy     = "app.legal_doc_privacy"
    case legalDocUnknown     = "app.legal_doc_unknown"
    case legalAcceptButton   = "app.legal_accept_button"
    case legalDeclineButton  = "app.legal_decline_button"
    case legalAcceptError    = "app.legal_accept_error"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
