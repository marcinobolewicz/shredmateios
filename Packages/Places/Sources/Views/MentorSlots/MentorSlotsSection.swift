import SwiftUI
import Theme
import Common
import Payment

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
        .overlay { processingOverlay }
        .stripePaymentSheet(
            isPresented: $viewModel.showPaymentSheet,
            paymentSheet: viewModel.paymentSheet,
            onResult: viewModel.handlePaymentResult
        )
        .deleteSlotAlert(viewModel: viewModel)
        .bookSlotAlert(viewModel: viewModel)
        .bookingTooSoonAlert(viewModel: viewModel)
        .actionErrorAlert(viewModel: viewModel)
        .paymentSuccessAlert(viewModel: viewModel)
        .paymentErrorAlert(viewModel: viewModel)
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

    @ViewBuilder
    private var processingOverlay: some View {
        if viewModel.isProcessingPayment {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack(spacing: theme.spacing.sm) {
                    ProgressView()
                    Text(PlacesStrings.slotPaymentProcessing.localized)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textInverse)
                }
                .padding(theme.spacing.lg)
                .background(theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
            }
        }
    }
}

// MARK: - Alert Modifiers

private extension View {

    func deleteSlotAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
            PlacesStrings.slotDeleteTitle.localized,
            isPresented: Bindable(viewModel).showDeleteConfirmation,
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
    }

    func bookSlotAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
            PlacesStrings.slotBookTitle.localized,
            isPresented: Bindable(viewModel).showBookConfirmation,
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
    }

    func bookingTooSoonAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
            PlacesStrings.slotBookTooSoonTitle.localized,
            isPresented: Bindable(viewModel).showBookingTooSoon
        ) {
            Button("OK") { viewModel.dismissAction() }
        } message: {
            Text(PlacesStrings.slotBookTooSoonMessage.localized)
        }
    }

    func actionErrorAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
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

    func paymentSuccessAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
            PlacesStrings.slotPaymentSuccessTitle.localized,
            isPresented: Bindable(viewModel).showPaymentSuccess
        ) {
            Button("OK") { viewModel.dismissPaymentSuccess() }
        } message: {
            Text(PlacesStrings.slotPaymentSuccessMessage.localized)
        }
    }

    func paymentErrorAlert(viewModel: MentorSlotsViewModel) -> some View {
        alert(
            PlacesStrings.slotPaymentErrorTitle.localized,
            isPresented: Bindable(viewModel).showPaymentError
        ) {
            Button("OK") { viewModel.dismissPaymentError() }
        } message: {
            if let msg = viewModel.paymentErrorMessage {
                Text(msg)
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
