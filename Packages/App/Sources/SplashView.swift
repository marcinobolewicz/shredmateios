import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Image("slide_0")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.15), .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}
