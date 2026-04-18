import SwiftUI
import Networking
import Common
import Theme

struct MySlotsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var viewModel: MySlotsViewModel
    @State private var expandedDays: Set<String> = []

    init(service: any MentorSlotsServiceProtocol) {
        _viewModel = State(wrappedValue: MySlotsViewModel(service: service))
    }

    var body: some View {
        VStack(spacing: 0) {
            filterPicker
            content
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(ProfileStrings.mySlotsTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.colors.backgroundSecondary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.loadOnAppear() }
        .alert(
            ProfileStrings.slotDeleteTitle.localized,
            isPresented: $viewModel.showDeleteConfirmation,
            presenting: viewModel.selectedSlot
        ) { _ in
            Button(CommonStrings.cancelButton.localized, role: .cancel) {
                viewModel.dismissAction()
            }
            Button(ProfileStrings.slotDeleteConfirm.localized, role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: { slot in
            Text(slotSummary(slot))
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
        .onChange(of: viewModel.dayGroups) { _, groups in
            if expandedDays.isEmpty {
                expandedDays = Set(groups.map(\.id))
            }
        }
    }

    // MARK: - Filter

    private var filterPicker: some View {
        ChipFilterPicker(
            selection: $viewModel.filter,
            allLabel: ProfileStrings.slotFilterAll.localized
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack { Spacer(); ProgressView(); Spacer() }
                .frame(maxWidth: .infinity)

        case .loaded:
            if viewModel.isEmpty {
                ContentUnavailableView(
                    ProfileStrings.mySlotsEmpty.localized,
                    systemImage: "calendar",
                    description: Text(ProfileStrings.mySlotsEmptyDescription.localized)
                )
            } else {
                groupedList
            }

        case .failed:
            ContentUnavailableView(
                ProfileStrings.mySlotsFailed.localized,
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    private var groupedList: some View {
        List {
            ForEach(viewModel.dayGroups) { group in
                Section(isExpanded: binding(for: group.id)) {
                    ForEach(group.slots) { slot in
                        MentorSlotRow(
                            slot: slot,
                            onDelete: { viewModel.deleteTapped(slot) }
                        )
                        .listRowInsets(EdgeInsets(
                            top: theme.spacing.sm,
                            leading: theme.spacing.md,
                            bottom: theme.spacing.sm,
                            trailing: theme.spacing.md
                        ))
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(group.dayHeader)
                        .dsTextStyle(.heading)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .refreshable { viewModel.refresh() }
    }

    // MARK: - Helpers

    private func binding(for dayId: String) -> Binding<Bool> {
        Binding(
            get: { expandedDays.contains(dayId) },
            set: { isExpanded in
                if isExpanded {
                    expandedDays.insert(dayId)
                } else {
                    expandedDays.remove(dayId)
                }
            }
        )
    }

    private func slotSummary(_ slot: MentorSlot) -> String {
        let fmt = DateFormatting.shared
        let day = fmt.dayHeader(from: slot.startTime)
        let time = "\(fmt.localizedTime(from: slot.startTime))–\(fmt.localizedTime(from: slot.endTime))"
        return "\(day)\n\(time) · \(slot.duration) min"
    }
}

// MARK: - Mentor Slot Row

private struct MentorSlotRow: View {
    @Environment(AppTheme.self) private var theme
    let slot: MentorSlot
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Text("\(DateFormatting.shared.localizedTime(from: slot.startTime))–\(DateFormatting.shared.localizedTime(from: slot.endTime))")
                    .dsTextStyle(.heading)
                Spacer()
                statusBadge
            }

            Text("\(slot.duration) min")
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)

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

            Text(formatPrice(slot.price, currency: slot.currency))
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.primary)

            if let student = slot.studentRider {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(theme.colors.primary)
                    Text(student.displayName)
                        .dsTextStyle(.body)
                        .foregroundStyle(theme.colors.primary)
                }
            }

            if slot.status == .available {
                Button(ProfileStrings.slotDeleteButton.localized, role: .destructive, action: onDelete)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
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
        case .available: return (ProfileStrings.statusAvailable.localized, .green)
        case .booked: return (ProfileStrings.statusBooked.localized, .blue)
        case .completed: return (ProfileStrings.statusCompleted.localized, .gray)
        case .cancelled: return (ProfileStrings.statusCancelled.localized, .red)
        case .reservationPending: return (ProfileStrings.statusReservationPending.localized, .pink)
        case .rejected: return (ProfileStrings.statusRejected.localized, .red)
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

