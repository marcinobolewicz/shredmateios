import SwiftUI

/// Reusable screen header with consistent styling across all tabs.
///
/// Usage:
/// ```swift
/// DSScreenHeader(title: "Spots")
/// DSScreenHeader(label: "MENTORS", title: "Find a mentor", subtitle: "Browse instructors…")
/// ```
public struct DSScreenHeader: View {
    @Environment(AppTheme.self) private var theme

    private let label: String?
    private let title: String
    private let subtitle: String?

    public init(
        label: String? = nil,
        title: String,
        subtitle: String? = nil
    ) {
        self.label = label
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let label {
                Text(label.uppercased())
                    .dsTextStyle(.caption, color: \.primary)
                    .tracking(1.5)
            }

            Text(title)
                .dsTextStyle(.largeTitle)

            if let subtitle {
                Text(subtitle)
                    .dsTextStyle(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.sm)
    }
}
