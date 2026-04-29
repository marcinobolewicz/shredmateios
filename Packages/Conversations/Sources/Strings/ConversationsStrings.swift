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
    case chatOpenRiderProfile = "conversations.chat_open_rider_profile"

    case deleteActionTitle = "conversations.delete_action_title"
    case deleteConfirmTitle = "conversations.delete_confirm_title"
    case deleteConfirmMessage = "conversations.delete_confirm_message"
    case deleteConfirmButton = "conversations.delete_confirm_button"
    case deleteCancelButton = "conversations.delete_cancel_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
