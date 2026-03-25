import SwiftUI
import Theme

public struct MentorSlotsSection: View {
    @Environment(AppTheme.self) private var theme

    @Bindable var viewModel: MentorSlotsViewModel

    public init(viewModel: MentorSlotsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(PlacesStrings.mentorSlotsTitle.localized)
                .dsTextStyle(.heading)

            ForEach(viewModel.dayGroups) { group in
                daySection(group)
            }
        }
        .alert(
            PlacesStrings.slotDeleteTitle.localized,
            isPresented: $viewModel.showDeleteConfirmation,
            presenting: viewModel.selectedSlot
        ) { _ in
            Button(PlacesStrings.cancelButton.localized, role: .cancel) {
                viewModel.dismissAction()
            }
            Button(PlacesStrings.slotDeleteConfirm.localized, role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: { slot in
            Text("\(slot.dayHeader)\n\(slot.timeRange) · \(slot.duration)")
        }
        .alert(
            PlacesStrings.slotBookTitle.localized,
            isPresented: $viewModel.showBookConfirmation,
            presenting: viewModel.selectedSlot
        ) { _ in
            Button(PlacesStrings.cancelButton.localized, role: .cancel) {
                viewModel.dismissAction()
            }
            Button(PlacesStrings.slotBookConfirm.localized) {
                Task { await viewModel.confirmBook() }
            }
        } message: { slot in
            Text("\(slot.dayHeader)\n\(slot.timeRange) · \(slot.duration)\n\(slot.price)")
        }
        .alert(
            PlacesStrings.slotActionErrorTitle.localized,
            isPresented: .init(
                get: { viewModel.actionError != nil },
                set: { if !$0 { viewModel.actionError = nil } }
            )
        ) {
            Button("OK") { viewModel.actionError = nil }
        } message: {
            if let error = viewModel.actionError {
                Text(error)
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
                    MentorSlotCard(viewData: slot) {
                        viewModel.slotTapped(slot)
                    }
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
