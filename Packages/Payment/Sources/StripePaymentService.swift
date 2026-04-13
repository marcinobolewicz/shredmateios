import Foundation
import StripePaymentSheet

/// Configures the Stripe SDK and prepares `PaymentSheet` instances.
///
/// This service is the single point of contact with the Stripe iOS SDK.
/// It owns SDK initialization (publishable key) and builds payment sheet
/// configurations from a server-provided `clientSecret`.
@MainActor
public final class StripePaymentService {

    // MARK: - Init

    /// Initializes the Stripe SDK with the given publishable key.
    ///
    /// Call this once at app startup (e.g. in `AppSetup.configure()`).
    /// - Parameter publishableKey: Your Stripe publishable key (`pk_test_…` / `pk_live_…`).
    public init(publishableKey: String) {
        STPAPIClient.shared.publishableKey = publishableKey
    }

    // MARK: - Payment Sheet

    /// Creates a configured `PaymentSheet` ready to be presented.
    ///
    /// - Parameters:
    ///   - clientSecret: The `client_secret` from a PaymentIntent created on your backend.
    ///   - merchantDisplayName: Name shown on the payment sheet (e.g. "ShredMate").
    ///   - customerId: Optional Stripe Customer ID for saved payment methods.
    ///   - ephemeralKeySecret: Optional ephemeral key secret paired with `customerId`.
    /// - Returns: A `PaymentSheet` configured and ready to present.
    public func makePaymentSheet(
        clientSecret: String,
        merchantDisplayName: String = "ShredMate",
        customerId: String? = nil,
        ephemeralKeySecret: String? = nil
    ) -> PaymentSheet {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = merchantDisplayName
        configuration.allowsDelayedPaymentMethods = false

        if let customerId, let ephemeralKeySecret {
            configuration.customer = .init(
                id: customerId,
                ephemeralKeySecret: ephemeralKeySecret
            )
        }

        return PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
    }

    /// Maps the Stripe SDK's `PaymentSheetResult` to the app's `PaymentResult`.
    public func mapResult(_ sheetResult: PaymentSheetResult) -> PaymentResult {
        switch sheetResult {
        case .completed:
            return .completed
        case .canceled:
            return .canceled
        case .failed(let error):
            return .failed(error.localizedDescription)
        }
    }
}
