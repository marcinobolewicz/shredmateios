import SwiftUI
import Theme

/// Reusable circular avatar: remote image, local asset, or initials fallback.
public struct AvatarView: View {
    @Environment(AppTheme.self) private var theme

    private let source: Source
    private let initials: String
    let size: CGFloat

    // MARK: - Init

    /// URL-based init (feed, conversations).
    public init(url: URL?, initials: String, size: CGFloat = 48) {
        self.source = .remote(url)
        self.initials = initials
        self.size = size
    }

    /// Avatar enum init (places list, place details).
    public init(avatar: Avatar, initials: String = "", size: CGFloat = 48) {
        switch avatar {
        case .imageRemote(let url):
            self.source = .remote(url)
            self.initials = initials
        case .initials(let text):
            self.source = .remote(nil)
            self.initials = text
        case .image(let name):
            self.source = .local(name)
            self.initials = initials
        }
        self.size = size
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch source {
            case .remote(let url):
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image): image.resizable().scaledToFill()
                        default: fallback
                        }
                    }
                } else {
                    fallback
                }
            case .local(let name):
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // MARK: - Private

    private var fallback: some View {
        ZStack {
            Circle().fill(theme.colors.surfaceTertiary)
            Text(initials)
                .font(.system(size: size * 0.3, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private enum Source {
        case remote(URL?)
        case local(String)
    }
}
