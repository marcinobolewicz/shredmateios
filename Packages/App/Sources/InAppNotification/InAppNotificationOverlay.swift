import SwiftUI

/// Attaches a notification banner overlay at the top of any view hierarchy.
///
/// Usage:
/// ```swift
/// RootView()
///     .inAppNotificationOverlay(center: notificationCenter)
/// ```
struct InAppNotificationOverlay: ViewModifier {
    let center: InAppNotificationCenter

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let notification = center.current {
                InAppNotificationBanner(
                    notification: notification,
                    onDismiss: { center.dismiss() }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 8)
            }
        }
        .animation(.spring(duration: 0.35), value: center.current?.id)
    }
}

extension View {
    func inAppNotificationOverlay(center: InAppNotificationCenter) -> some View {
        modifier(InAppNotificationOverlay(center: center))
    }
}
