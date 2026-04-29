import Foundation

/// Outcome of a payment sheet presentation.
public enum PaymentResult: Sendable, Equatable {
    case completed
    case canceled
    case failed(String)
}
