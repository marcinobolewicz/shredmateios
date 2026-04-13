import Foundation

public enum PaymentStrings: String {
    case paymentSuccessTitle = "payment.success_title"
    case paymentSuccessMessage = "payment.success_message"
    case paymentCanceledTitle = "payment.canceled_title"
    case paymentCanceledMessage = "payment.canceled_message"
    case paymentFailedTitle = "payment.failed_title"
    case paymentFailedMessageFormat = "payment.failed_message_format"
    case payButton = "payment.pay_button"
    case processingPayment = "payment.processing"

    public var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    public static func paymentFailedMessage(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                PaymentStrings.paymentFailedMessageFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }
}
