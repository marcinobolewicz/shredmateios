//
//  PlacesStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum PlacesStrings: String {
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

    case spotSubtitlePlaceholder = "places.spot_subtitle_placeholder"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
