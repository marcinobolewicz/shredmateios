import Payment
import Foundation

enum StripeSetup {

    /// Reads the publishable key + Apple Pay merchant info from `Info.plist`
    /// and initializes the Stripe SDK via `StripePaymentService`.
    ///
    /// Returns the service instance so it can be stored in `AppDependencies`.
    @MainActor
    static func configure() -> StripePaymentService {
        let info = Bundle.main.infoDictionary
        let key = info?["STRIPE_PUBLISHABLE_KEY"] as? String ?? ""
        let merchantId = info?["STRIPE_APPLE_MERCHANT_ID"] as? String
        let merchantCountry = info?["STRIPE_APPLE_MERCHANT_COUNTRY"] as? String ?? "PL"
        return StripePaymentService(
            publishableKey: key,
            applePayMerchantId: merchantId,
            applePayMerchantCountryCode: merchantCountry
        )
    }
}
