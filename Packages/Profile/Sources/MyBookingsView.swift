import SwiftUI
import Networking
import Common
import Theme

struct MyBookingsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var viewModel: MyBookingsViewModel

    init(service: any MentorSlotsServiceProtocol) {
        _viewModel = State(wrappedValue: MyBookingsViewModel(service: service))
    }

    var body: some View {
        content
            .navigationTitle(ProfileStrings.myBookingsTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.loadOnAppear() }
            .refreshable { viewModel.refresh() }
            .alert(
                ProfileStrings.bookingCancelTitle.localized,
                isPresented: $viewModel.showCancelConfirmation,
                presenting: viewModel.selectedSlot
            ) { _ in
                Button(CommonStrings.cancelButton.localized, role: .cancel) {
                    viewModel.dismissAction()
                }
                Button(ProfileStrings.bookingCancelConfirm.localized, role: .destructive) {
                    Task { await viewModel.confirmCancel() }
                }
            } message: { slot in
                Text(slotSummary(slot))
            }
            .confirmationDialog(
                ProfileStrings.bookingCompleteTitle.localized,
                isPresented: $viewModel.showCompleteConfirmation,
                titleVisibility: .visible,
                presenting: viewModel.selectedSlot
            ) { _ in
                Button(ProfileStrings.bookingRecommend.localized) {
                    Task { await viewModel.confirmComplete(recommend: true) }
                }
                Button(ProfileStrings.bookingNoRecommend.localized) {
                    Task { await viewModel.confirmComplete(recommend: false) }
                }
                Button(CommonStrings.cancelButton.localized, role: .cancel) {
                    viewModel.dismissAction()
                }
            } message: { slot in
                Text(ProfileStrings.bookingCompleteMessage(slot.mentorRider.displayName))
            }
            .alert(item: $viewModel.actionError) { err in
                Alert(
                    title: Text(err.title),
                    message: Text(err.message),
                    dismissButton: .default(Text(ProfileStrings.ok.localized)) {
                        viewModel.actionError = nil
                    }
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack { Spacer(); ProgressView(); Spacer() }
                .frame(maxWidth: .infinity)

        case .loaded:
            if viewModel.slots.isEmpty {
                ContentUnavailableView(
                    ProfileStrings.myBookingsEmpty.localized,
                    systemImage: "calendar",
                    description: Text(ProfileStrings.myBookingsEmptyDescription.localized)
                )
            } else {
                slotsList
            }

        case .failed:
            ContentUnavailableView(
                ProfileStrings.myBookingsFailed.localized,
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    private var slotsList: some View {
        List {
            ForEach(viewModel.slots) { slot in
                BookingRow(
                    slot: slot,
                    action: viewModel.action(for: slot),
                    onCancel: { viewModel.cancelTapped(slot) },
                    onComplete: { viewModel.completeTapped(slot) }
                )
                .listRowInsets(EdgeInsets(
                    top: theme.spacing.sm,
                    leading: theme.spacing.md,
                    bottom: theme.spacing.sm,
                    trailing: theme.spacing.md
                ))
                .listRowSeparator(.visible)
                .listRowSeparatorTint(theme.colors.border.opacity(0.4))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.colors.backgroundSecondary)
    }

    private func slotSummary(_ slot: MentorSlot) -> String {
        let day = slot.startTime.dayFormatted
        let time = "\(slot.startTime.timeFormatted)–\(slot.endTime.timeFormatted)"
        return "\(day)\n\(time) · \(slot.duration) min"
    }
}

// MARK: - Booking Row

private struct BookingRow: View {
    @Environment(AppTheme.self) private var theme
    let slot: MentorSlot
    let action: BookingAction?
    let onCancel: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Text(slot.startTime.dayFormatted)
                    .dsTextStyle(.heading)
                Spacer()
                statusBadge
            }

            Text("\(slot.startTime.timeFormatted)–\(slot.endTime.timeFormatted) · \(slot.duration) min")
                .dsTextStyle(.subheadline)

            HStack(spacing: theme.spacing.xs) {
                Text(slot.sport.name)
                    .dsTextStyle(.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                if let place = slot.place {
                    Text("·")
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(place.name)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }
            }

            Text(slot.mentorRider.displayName)
                .dsTextStyle(.body)
                .foregroundStyle(theme.colors.primary)

            Text(formatPrice(slot.price, currency: slot.currency))
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.primary)

            actionButtons
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        let (text, color) = statusInfo
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var statusInfo: (String, Color) {
        switch slot.status {
        case .booked: return (ProfileStrings.statusBooked.localized, .blue)
        case .completed: return (ProfileStrings.statusCompleted.localized, .green)
        case .cancelled: return (ProfileStrings.statusCancelled.localized, .red)
        case .available: return (ProfileStrings.statusAvailable.localized, .gray)
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        switch action {
        case .cancel:
            Button(ProfileStrings.bookingCancelButton.localized, role: .destructive, action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.small)

        case .tooLateToCancel:
            Text(ProfileStrings.bookingTooLateToCancel.localized)
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)

        case .complete:
            HStack(spacing: theme.spacing.sm) {
                Button(ProfileStrings.bookingConfirmSession.localized, action: onComplete)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                Button(ProfileStrings.bookingCancelButton.localized, role: .destructive, action: onCancel)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

        case .completed(let recommendation):
            if recommendation == .recommended {
                Label(ProfileStrings.bookingRecommended.localized, systemImage: "hand.thumbsup.fill")
                    .dsTextStyle(.caption)
                    .foregroundStyle(.green)
            }

        case nil:
            EmptyView()
        }
    }

    private func formatPrice(_ grosz: Int, currency: String) -> String {
        let value = Double(grosz) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) \(currency)"
    }
}

// MARK: - Date Formatting

private extension String {
    var dayFormatted: String {
        guard let date = isoDate else { return self }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEEEddMMMM")
        return formatter.string(from: date).localizedCapitalized
    }

    var timeFormatted: String {
        guard let date = isoDate else { return "--:--" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var isoDate: Date? {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: self) { return date }
        parser.formatOptions = [.withInternetDateTime]
        return parser.date(from: self)
    }
}
