import Foundation

enum ConversationsStrings: String {
    case rootNavigationTitle = "conversations.root_navigation_title"

    case listEmptyTitle = "conversations.list_empty_title"
    case listEmptyDescription = "conversations.list_empty_description"
    case listFailedTitle = "conversations.list_failed_title"
    case listFailedDescription = "conversations.list_failed_description"

    case newConversationTitle = "conversations.new_conversation_title"
    case searchRiderPlaceholder = "conversations.search_rider_placeholder"

    case chatInputPlaceholder = "conversations.chat_input_placeholder"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
