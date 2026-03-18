import Foundation

enum FeedStrings: String {
    case navigationTitle     = "feed.navigation_title"
    case createPostTitle     = "feed.create_post_title"
    case captionPlaceholder  = "feed.caption_placeholder"
    case postButton          = "feed.post_button"
    case placeLabel          = "feed.place_label"
    case placePlaceholder    = "feed.place_placeholder"
    case ok                  = "feed.ok"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
