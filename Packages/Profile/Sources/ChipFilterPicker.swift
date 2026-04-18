import SwiftUI
import Theme

protocol ChipFilterOption: CaseIterable, Identifiable, Hashable, Sendable {
    var label: String { get }
}

struct ChipFilterPicker<F: ChipFilterOption>: View {
    @Environment(AppTheme.self) private var theme
    @Binding var selection: F?
    let allLabel: String

    private var options: [F] { Array(F.allCases) }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                DSChip(title: allLabel, isSelected: selection == nil) {
                    withAnimation(.snappy(duration: 0.2)) {
                        selection = nil
                    }
                }
                ForEach(options, id: \.id) { option in
                    DSChip(
                        title: option.label,
                        isSelected: selection == option
                    ) {
                        withAnimation(.snappy(duration: 0.2)) {
                            selection = (selection == option) ? nil : option
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
        .frame(minHeight: 44)
        .background(theme.colors.backgroundSecondary)
    }
}
