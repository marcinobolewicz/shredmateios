import Foundation

enum FeedStrings: String {
    case navigationTitle     = "feed.navigation_title"
    case createPostTitle     = "feed.create_post_title"
    case captionPlaceholder  = "feed.caption_placeholder"
    case postButton          = "feed.post_button"
    case placeLabel          = "feed.place_label"
    case placePlaceholder    = "feed.place_placeholder"
    case photoLabel          = "feed.photo_label"
    case addPhoto            = "feed.add_photo"
    case changePhoto         = "feed.change_photo"
    case removePhoto         = "feed.remove_photo"
    case uploadingPhoto      = "feed.uploading_photo"
    case ok                  = "feed.ok"
    case emptyTitle          = "feed.empty_title"
    case emptyDescription    = "feed.empty_description"
    case failedTitle         = "feed.failed_title"
    case failedDescription   = "feed.failed_description"
    case refreshButton       = "feed.refresh_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
