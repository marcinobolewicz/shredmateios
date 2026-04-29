import SwiftUI
import StripePaymentSheet

/// A SwiftUI view modifier that presents a Stripe `PaymentSheet`
/// and delivers the result via a callback.
///
/// Usage:
/// ```swift
/// SomeView()
///     .paymentSheet(
///         isPresented: $showSheet,
///         paymentSheet: sheet,
///         onResult: { result in … }
///     )
/// ```
public struct PaymentSheetModifier: ViewModifier {

    @Binding var isPresented: Bool
    let paymentSheet: PaymentSheet?
    let onResult: (PaymentResult) -> Void

    public func body(content: Content) -> some View {
        content.paymentSheet(
            isPresented: $isPresented,
            paymentSheet: paymentSheet ?? makePlaceholderSheet(),
            onCompletion: { sheetResult in
                let result: PaymentResult = switch sheetResult {
                case .completed: .completed
                case .canceled: .canceled
                case .failed(let error): .failed(error.localizedDescription)
                }
                onResult(result)
            }
        )
    }

    /// Provides a non-nil sheet for the modifier signature.
    /// This sheet is never actually presented when `paymentSheet` is nil
    /// because `isPresented` should remain `false` in that case.
    private func makePlaceholderSheet() -> PaymentSheet {
        PaymentSheet(
            paymentIntentClientSecret: "",
            configuration: PaymentSheet.Configuration()
        )
    }
}

extension View {

    /// Presents a Stripe `PaymentSheet` when `isPresented` becomes `true`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls sheet presentation.
    ///   - paymentSheet: The configured `PaymentSheet` to display.
    ///   - onResult: Callback with the payment outcome.
    public func stripePaymentSheet(
        isPresented: Binding<Bool>,
        paymentSheet: PaymentSheet?,
        onResult: @escaping (PaymentResult) -> Void
    ) -> some View {
        modifier(PaymentSheetModifier(
            isPresented: isPresented,
            paymentSheet: paymentSheet,
            onResult: onResult
        ))
    }
}
