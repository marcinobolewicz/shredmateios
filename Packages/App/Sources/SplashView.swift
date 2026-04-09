import SwiftUI
import Theme

/// Boot-time splash rendered before the auth session has been restored.
///
/// Visually mirrors the native iOS launch screen (`UILaunchScreen` in
/// `Info.plist`) so the handover from the launch image to the first SwiftUI
/// frame is seamless: same brand primary background, same outline mark,
/// same centred layout. That eliminates the guest-to-user "blink" that
/// used to happen while `AuthState.restoreSession()` was in flight.
struct SplashView: View {

    @Environment(AppTheme.self) private var theme

    var body: some View {
        ZStack {
            ProgressView()
        }
        .dsImageBackground("slide_0")
        .transition(.opacity)
    }

    // MARK: - Layout

    private static let logoSize: CGFloat = 120
}
