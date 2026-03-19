//
//  PlacesStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum PlacesStrings: String {
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

    // MARK: - Check-In
    case checkInButton = "places.check_in_button"
    case checkOutButton = "places.check_out_button"
    case checkInRoleTitle = "places.check_in_role_title"
    case checkInRoleMessage = "places.check_in_role_message"
    case roleRider = "places.role_rider"
    case roleMentor = "places.role_mentor"
    case cancelButton = "places.cancel_button"
    case checkInErrorTitle = "places.check_in_error_title"
    case checkedInAsFormat = "places.checked_in_as_format"
    case checkedInElsewhereFormat = "places.checked_in_elsewhere_format"
    case failedCheckInFormat = "places.failed_check_in_format"
    case failedCheckOutFormat = "places.failed_check_out_format"

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
}
