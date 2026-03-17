//
//  ShakeGesture.swift
//  ShredMate
//
//  Debug-only shake gesture for showing the Pulse network console.
//

#if DEBUG
import SwiftUI
import UIKit

// MARK: - UIWindow shake detection

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}

extension Notification.Name {
    static let deviceDidShake = Notification.Name("DeviceDidShake")
}

// MARK: - SwiftUI modifier

private struct OnShakeModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(OnShakeModifier(action: action))
    }
}
#endif
