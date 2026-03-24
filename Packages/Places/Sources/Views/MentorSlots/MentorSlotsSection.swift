import SwiftUI
import Theme

public struct MentorSlotsSection: View {
    @Environment(AppTheme.self) private var theme

    let dayGroups: [MentorSlotDayGroup]

    public init(dayGroups: [MentorSlotDayGroup]) {
        self.dayGroups = dayGroups
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(PlacesStrings.mentorSlotsTitle.localized)
                .dsTextStyle(.heading)

            ForEach(dayGroups) { group in
                daySection(group)
            }
        }
    }

    private func daySection(_ group: MentorSlotDayGroup) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(group.dayHeader)
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)

            FlowLayout(spacing: theme.spacing.sm) {
                ForEach(group.slots) { slot in
                    MentorSlotCard(viewData: slot)
                }
            }
        }
    }
}

// MARK: - FlowLayout

/// Horizontal wrapping layout for slot cards.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() where index < subviews.count {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private struct ArrangeResult {
        var size: CGSize
        var origins: [CGPoint]
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalSize: CGSize = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalSize.width = max(totalSize.width, currentX - spacing)
            totalSize.height = max(totalSize.height, currentY + rowHeight)
        }

        return ArrangeResult(size: totalSize, origins: origins)
    }
}
