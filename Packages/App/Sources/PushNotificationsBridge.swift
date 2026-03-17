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
}
