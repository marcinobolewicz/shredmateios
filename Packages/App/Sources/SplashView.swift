import SwiftUI
import Theme

/// Boot-time splash rendered before the auth session has been restored.
///
/// Layout mirrors `LaunchScreen.storyboard` exactly: the image is pinned
/// edge-to-edge and scaled aspect-fill, so the handover from the native
/// launch image to the first SwiftUI frame is pixel-aligned.
struct SplashView: View {

    var body: some View {
        Image("slide_0")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay { ProgressView() }
            .transition(.opacity)
    }
}
