import Testing
@testable import Payment

@Suite("PaymentResult")
struct PaymentResultTests {

    @Test("equality holds for completed")
    func completedEquality() {
        #expect(PaymentResult.completed == PaymentResult.completed)
    }

    @Test("equality holds for canceled")
    func canceledEquality() {
        #expect(PaymentResult.canceled == PaymentResult.canceled)
    }

    @Test("failed carries error message")
    func failedMessage() {
        let result = PaymentResult.failed("Insufficient funds")
        if case .failed(let message) = result {
            #expect(message == "Insufficient funds")
        } else {
            Issue.record("Expected .failed")
        }
    }

    @Test("completed and canceled are not equal")
    func differentCases() {
        #expect(PaymentResult.completed != PaymentResult.canceled)
    }
}
