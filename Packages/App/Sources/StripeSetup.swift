import Payment
import Foundation

enum StripeSetup {

    /// Reads the publishable key from `Info.plist` and initializes
    /// the Stripe SDK via `StripePaymentService`.
    ///
    /// Returns the service instance so it can be stored in `AppDependencies`.
    @MainActor
    static func configure() -> StripePaymentService {
        let key = Bundle.main.infoDictionary?["STRIPE_PUBLISHABLE_KEY"] as? String ?? ""
        return StripePaymentService(publishableKey: key)
    }
}
