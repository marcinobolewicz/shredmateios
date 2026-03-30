import SwiftUI
import Theme

/// Displays a legal document (Terms of Service / Privacy Policy) with rich text sections.
public struct LegalDocumentView: View {
    @Environment(AppTheme.self) private var theme

    let title: String
    let sections: [Section]

    public struct Section: Identifiable {
        public let id = UUID()
        public let heading: String
        public let body: String

        public init(heading: String, body: String) {
            self.heading = heading
            self.body = body
        }
    }

    public init(title: String, sections: [Section]) {
        self.title = title
        self.sections = sections
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(section.heading)
                            .dsTextStyle(.heading)

                        Text(section.body)
                            .dsTextStyle(.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
