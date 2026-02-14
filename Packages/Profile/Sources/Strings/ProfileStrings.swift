import Foundation

enum ProfileStrings: String {
    case navigationTitle = "profile.navigation_title"

    case errorAlertTitle = "profile.error_alert_title"
    case successAlertTitle = "profile.success_alert_title"
    case okButton = "profile.ok_button"

    case deleteAccountDialogTitle = "profile.delete_account_dialog_title"
    case deleteAccountButton = "profile.delete_account_button"
    case cancelButton = "profile.cancel_button"
    case deleteAccountDialogMessage = "profile.delete_account_dialog_message"

    case loadingProfile = "profile.loading_profile"

    case sectionProfileInformation = "profile.section_profile_information"
    case displayNamePlaceholder = "profile.display_name_placeholder"
    case typePickerTitle = "profile.type_picker_title"
    case descriptionLabel = "profile.description_label"
    case saveProfileButton = "profile.save_profile_button"

    case sectionAvatar = "profile.section_avatar"
    case avatarUploadComingSoon = "profile.avatar_upload_coming_soon"

    case sectionBaseLocation = "profile.section_base_location"
    case locationNamePlaceholder = "profile.location_name_placeholder"
    case latitudePlaceholder = "profile.latitude_placeholder"
    case longitudePlaceholder = "profile.longitude_placeholder"
    case saveLocationButton = "profile.save_location_button"

    case sectionSports = "profile.section_sports"
    case loadingSports = "profile.loading_sports"

    case sectionDangerZone = "profile.section_danger_zone"

    case levelPickerTitle = "profile.level_picker_title"
    case availableAsMentorToggle = "profile.available_as_mentor_toggle"
    case saveButton = "profile.save_button"
    case removeButton = "profile.remove_button"

    case failedLoadProfileFormat = "profile.failed_load_profile_format"
    case profileUpdatedSuccess = "profile.profile_updated_success"
    case failedUpdateProfileFormat = "profile.failed_update_profile_format"

    case noImageSelected = "profile.no_image_selected"
    case avatarUploadedSuccess = "profile.avatar_uploaded_success"
    case failedUploadAvatarFormat = "profile.failed_upload_avatar_format"

    case invalidCoordinates = "profile.invalid_coordinates"
    case locationSavedSuccess = "profile.location_saved_success"
    case failedSaveLocationFormat = "profile.failed_save_location_format"

    case failedUpdateSportFormat = "profile.failed_update_sport_format"
    case failedRemoveSportFormat = "profile.failed_remove_sport_format"
    case failedDeleteAccountFormat = "profile.failed_delete_account_format"

    case displayNameRequired = "profile.display_name_required"
    case displayNameMaxLengthFormat = "profile.display_name_max_length_format"
    case descriptionMaxLengthFormat = "profile.description_max_length_format"
    case enterValidCoordinates = "profile.enter_valid_coordinates"
    case latitudeRangeError = "profile.latitude_range_error"
    case longitudeRangeError = "profile.longitude_range_error"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    static func failedLoadProfile(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedLoadProfileFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedUpdateProfile(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedUpdateProfileFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedUploadAvatar(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedUploadAvatarFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedSaveLocation(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedSaveLocationFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedUpdateSport(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedUpdateSportFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedRemoveSport(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedRemoveSportFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func failedDeleteAccount(_ error: String) -> String {
        String(format: NSLocalizedString(ProfileStrings.failedDeleteAccountFormat.rawValue, bundle: .module, comment: ""), error)
    }

    static func displayNameMaxLength(_ max: Int) -> String {
        String(format: NSLocalizedString(ProfileStrings.displayNameMaxLengthFormat.rawValue, bundle: .module, comment: ""), max)
    }

    static func descriptionMaxLength(_ max: Int) -> String {
        String(format: NSLocalizedString(ProfileStrings.descriptionMaxLengthFormat.rawValue, bundle: .module, comment: ""), max)
    }
}
