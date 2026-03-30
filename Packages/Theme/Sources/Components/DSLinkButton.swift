import SwiftUI

/// Button that opens an external URL in Safari.
///
/// Uses `DSLinkButtonStyle` for consistent appearance.
/// ```swift
/// DSLinkButton("Terms of Service", systemImage: "doc.text", url: termsURL)
/// ```
public struct DSLinkButton: View {

    private let title: String
    private let systemImage: String?
    private let url: URL

    @Environment(\.openURL) private var openURL

    public init(_ title: String, systemImage: String? = nil, url: URL) {
        self.title = title
        self.systemImage = systemImage
        self.url = url
    }

    public var body: some View {
        Button { openURL(url) } label: {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .buttonStyle(.dsLink)
    }
}
