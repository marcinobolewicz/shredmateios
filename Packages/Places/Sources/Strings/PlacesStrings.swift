//
//  PlacesStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking

enum PlacesStrings: String {
    // Moderation (report / block)
    case moderationMenu = "places.moderation_menu"
    case moderationReportUser = "places.moderation_report_user"
    case moderationBlockUserFormat = "places.moderation_block_user_format"
    case moderationUnblockUserFormat = "places.moderation_unblock_user_format"
    case moderationReportTitle = "places.moderation_report_title"
    case moderationReasonSpam = "places.moderation_reason_spam"
    case moderationReasonHarassment = "places.moderation_reason_harassment"
    case moderationReasonInappropriate = "places.moderation_reason_inappropriate"
    case moderationReasonFakeProfile = "places.moderation_reason_fake_profile"
    case moderationReasonSafety = "places.moderation_reason_safety"
    case moderationReasonOther = "places.moderation_reason_other"
    case moderationReportSuccess = "places.moderation_report_success"
    case moderationBlockSuccessFormat = "places.moderation_block_success_format"
    case moderationActionFailed = "places.moderation_action_failed"

    case pickerTitle = "places.picker_title"
    case rootNavigationTitle = "places.root_navigation_title"
    case listNavigationTitle = "places.list_navigation_title"
    case detailsTitle = "places.details_title"

    case pickerDisplayMode = "places.picker_display_mode"
    case displayModeList = "places.display_mode_list"
    case displayModeMap = "places.display_mode_map"
    case searchPlaceholder = "places.search_placeholder"

    case emptyTitle = "places.empty_title"
    case emptyDescription = "places.empty_description"

    case failedTitle = "places.failed_title"
    case failedDescription = "places.failed_description"
    case refreshButton = "places.refresh_button"

    case sportSnowboard = "places.sport_snowboard"
    case sportSki = "places.sport_ski"
    case sportKitesurfing = "places.sport_kitesurfing"
    case sportWakeboard = "places.sport_wakeboard"

    case ridersLabel = "places.riders_label"
    case mentorsLabel = "places.mentors_label"
    case mapLabel = "places.map_label"

    // MARK: - Guest Gate
    case detailsGuestGateTitle = "places.details_guest_gate_title"
    case detailsGuestGateDescription = "places.details_guest_gate_description"
    case detailsGuestGateSignIn = "places.details_guest_gate_sign_in"

    case detailsRatingLabel = "places.details_rating_label"
    case detailsRidersEmptyTitle = "places.details_riders_empty_title"
    case detailsRidersEmptyDescription = "places.details_riders_empty_description"
    case detailsMentorsEmptyTitle = "places.details_mentors_empty_title"
    case detailsMentorsEmptyDescription = "places.details_mentors_empty_description"
    case mapDetailsButton = "places.map_details_button"

    case spotSubtitlePlaceholder = "places.spot_subtitle_placeholder"

    // MARK: - Rider Card
    case followButton = "places.follow_button"
    case unfollowButton = "places.unfollow_button"
    case messageButton = "places.message_button"

    // MARK: - Mentor Stats
    case mentorSessionsFormat = "places.mentor_sessions_format"
    case mentorRecommendationsFormat = "places.mentor_recommendations_format"

    // MARK: - Mentor Slots
    case mentorSlotsTitle = "places.mentor_slots_title"
    case mentorSlotsEmpty = "places.mentor_slots_empty"
    case slotDeleteTitle = "places.slot_delete_title"
    case slotDeleteConfirm = "places.slot_delete_confirm"
    case slotBookTitle = "places.slot_book_title"
    case slotBookConfirm = "places.slot_book_confirm"
    case slotBookTooSoonTitle = "places.slot_book_too_soon_title"
    case slotBookTooSoonMessage = "places.slot_book_too_soon_message"
    case slotActionErrorTitle = "places.slot_action_error_title"
    case slotPaymentProcessing = "places.slot_payment_processing"
    case slotPaymentSuccessTitle = "places.slot_payment_success_title"
    case slotPaymentSuccessMessage = "places.slot_payment_success_message"
    case slotPaymentSuccessMessageFormat = "places.slot_payment_success_message_format"
    case slotPaymentErrorTitle = "places.slot_payment_error_title"
    case slotMarketplaceDisclaimer = "places.slot_marketplace_disclaimer"
    case slotBookSellerFormat = "places.slot_book_seller_format"
    case slotBookOperator = "places.slot_book_operator"

    // MARK: - Mentors Search
    case mentorsSearchTitle = "places.mentors_search_title"
    case mentorsSearchDescription = "places.mentors_search_description"
    case mentorsAllSports = "places.mentors_all_sports"
    case mentorsAllSpots = "places.mentors_all_spots"

    // MARK: - Check-In
    case checkInButton = "places.check_in_button"
    case checkOutButton = "places.check_out_button"
    case checkInRoleTitle = "places.check_in_role_title"
    case checkInRoleMessage = "places.check_in_role_message"
    case roleRider = "places.role_rider"
    case roleMentor = "places.role_mentor"
    case cancelButton = "places.cancel_button"
    case checkInErrorTitle = "places.check_in_error_title"
    case checkedInTitle = "places.checked_in_title"
    case checkedInRoleFormat = "places.checked_in_role_format"
    case changeRoleButton = "places.change_role_button"
    case joinSpotTitle = "places.join_spot_title"
    case joinSpotDescription = "places.join_spot_description"
    case ridersCountFormat = "places.riders_count_format"
    case mentorsCountFormat = "places.mentors_count_format"
    case checkedInAsFormat = "places.checked_in_as_format"
    case checkedInElsewhereFormat = "places.checked_in_elsewhere_format"
    case failedCheckInFormat = "places.failed_check_in_format"
    case failedCheckOutFormat = "places.failed_check_out_format"

    // MARK: - Location Update Prompt
    case locationUpdatePromptTitle = "places.location_update_prompt_title"
    case locationUpdatePromptMessage = "places.location_update_prompt_message"
    case locationUpdateConfirm = "places.location_update_confirm"
    case locationUpdateOnMap = "places.location_update_on_map"
    case failedUpdateBaseLocationFormat = "places.failed_update_base_location_format"

    case riderProfileUnavailableTitle = "places.rider_profile_unavailable_title"
    case riderProfileUnavailableDescription = "places.rider_profile_unavailable_description"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    static func checkedInAs(_ role: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.checkedInAsFormat.rawValue, bundle: .module, comment: ""), role)
    }

    static func checkedInElsewhere(_ placeName: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.checkedInElsewhereFormat.rawValue, bundle: .module, comment: ""), placeName)
    }

    static func failedCheckIn(_ error: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.failedCheckInFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedCheckOut(_ error: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.failedCheckOutFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedUpdateBaseLocation(_ error: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.failedUpdateBaseLocationFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func mentorSessions(_ count: Int) -> String {
        String(format: NSLocalizedString(PlacesStrings.mentorSessionsFormat.rawValue, bundle: .module, comment: ""), count)
    }

    static func mentorRecommendations(_ count: Int) -> String {
        String(format: NSLocalizedString(PlacesStrings.mentorRecommendationsFormat.rawValue, bundle: .module, comment: ""), count)
    }

    static func slotBookSeller(_ name: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.slotBookSellerFormat.rawValue, bundle: .module, comment: ""), name)
    }

    static func slotPaymentSuccessMessage(mentor name: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.slotPaymentSuccessMessageFormat.rawValue, bundle: .module, comment: ""), name)
    }

    static func checkedInRole(_ role: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.checkedInRoleFormat.rawValue, bundle: .module, comment: ""), role)
    }

    static func ridersCount(_ count: Int) -> String {
        String(format: NSLocalizedString(PlacesStrings.ridersCountFormat.rawValue, bundle: .module, comment: ""), count)
    }

    static func mentorsCount(_ count: Int) -> String {
        String(format: NSLocalizedString(PlacesStrings.mentorsCountFormat.rawValue, bundle: .module, comment: ""), count)
    }

    static func moderationBlockUser(_ name: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.moderationBlockUserFormat.rawValue, bundle: .module, comment: ""), name)
    }

    static func moderationUnblockUser(_ name: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.moderationUnblockUserFormat.rawValue, bundle: .module, comment: ""), name)
    }

    static func moderationBlockSuccess(_ name: String) -> String {
        String(format: NSLocalizedString(PlacesStrings.moderationBlockSuccessFormat.rawValue, bundle: .module, comment: ""), name)
    }
}

extension ReportReason {
    var localizedLabel: String {
        switch self {
        case .spam: return PlacesStrings.moderationReasonSpam.localized
        case .harassment: return PlacesStrings.moderationReasonHarassment.localized
        case .inappropriateContent: return PlacesStrings.moderationReasonInappropriate.localized
        case .fakeProfile: return PlacesStrings.moderationReasonFakeProfile.localized
        case .safety: return PlacesStrings.moderationReasonSafety.localized
        case .other: return PlacesStrings.moderationReasonOther.localized
        }
    }
}
