import Core
import Networking
import UIKit
import UserNotifications

@MainActor
public enum PushNotificationsBridge {
    public static func requestAuthorizationAfterLogin() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } catch {
                return
            }

        case .authorized, .provisional, .ephemeral:
            UIApplication.shared.registerForRemoteNotifications()

        case .denied:
            return

        @unknown default:
            return
        }
    }

    public static func didReceiveAPNSToken(_ token: String) {
        guard let pushDeviceService = DIContainer.shared.resolve(PushDeviceServiceProtocol.self) else {
            return
        }

        Task {
            await pushDeviceService.setAPNSToken(token)
        }
    }

    /// Translates a tapped APNs payload into an in-app deep link and
    /// dispatches it through `AppRouter`.
    ///
    /// Both cold-start (push opens the app) and warm-tap (push tapped
    /// while app is foreground/background) funnel through here. Call
    /// from the `UNUserNotificationCenterDelegate` callback once a tap
    /// is received.
    public static func handleTappedNotification(userInfo: [AnyHashable: Any]) {
        guard let deepLink = DeepLinkPayloadParser.parse(userInfo) else { return }
        guard let appRouter = DIContainer.shared.resolve(AppRouter.self) else { return }
        appRouter.handle(deepLink)
    }
}

// MARK: - Payload parsing

/// Pulls a `DeepLink` out of the raw APNs `userInfo` dictionary.
///
/// Kept as a free, side-effect-free helper so the parsing rules can be
/// covered by tests without standing up the rest of the push stack. The
/// payload contract lives here — adding a new server-driven destination
/// is a single case below plus a single case in `DeepLink`.
private enum DeepLinkPayloadParser {
    static func parse(_ userInfo: [AnyHashable: Any]) -> DeepLink? {
        guard let type = userInfo["type"] as? String else { return nil }
        switch type {
        case "conversation":
            guard let id = userInfo["conversationId"] as? String else { return nil }
            let participantName = userInfo["participantName"] as? String ?? ""
            return .conversation(id: id, participantName: participantName)
        default:
            return nil
        }
    }
}
