import SwiftUI
import Networking
import Common
import Theme

struct GenerateSlotsView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GenerateSlotsViewModel

    init(
        mentorSlotsService: any MentorSlotsServiceProtocol,
        placesService: any PlacesServiceProtocol,
        riderSports: [RiderSport]
    ) {
        _viewModel = State(wrappedValue: GenerateSlotsViewModel(
            mentorSlotsService: mentorSlotsService,
            placesService: placesService,
            riderSports: riderSports
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                sportSection
                placeSection
                dateRangeSection
                weekdaysSection
                timeSection
                durationSection
                priceSection

                if let error = viewModel.validationError {
                    Text(error)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.error)
                }

                generateButton
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(ProfileStrings.generateSlotsTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadPlaces() }
        .alert(item: $viewModel.actionError) { err in
            Alert(
                title: Text(err.title),
                message: Text(err.message),
                dismissButton: .default(Text(CommonStrings.okButton.localized))
            )
        }
        .alert(
            ProfileStrings.generateResultTitle.localized,
            isPresented: .init(
                get: { viewModel.result != nil },
                set: { if !$0 { dismiss() } }
            )
        ) {
            Button(CommonStrings.okButton.localized) { dismiss() }
        } message: {
            if let result = viewModel.result {
                Text(resultMessage(result))
            }
        }
    }

    // MARK: - Sport

    private var sportSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generateSportLabel.localized, required: true)
            Picker(ProfileStrings.generateSportLabel.localized, selection: $viewModel.selectedSport) {
                Text(ProfileStrings.generateSportPlaceholder.localized)
                    .tag(Sport?.none)
                ForEach(viewModel.mentorSports) { sport in
                    Text(sport.name).tag(Sport?.some(sport))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        }
    }

    // MARK: - Place

    private var placeSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generatePlaceLabel.localized, required: false)
            Picker(ProfileStrings.generatePlaceLabel.localized, selection: $viewModel.selectedPlace) {
                Text(ProfileStrings.generatePlacePlaceholder.localized)
                    .tag(PlaceDto?.none)
                ForEach(viewModel.places) { place in
                    Text(place.name).tag(PlaceDto?.some(place))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        }
    }

    // MARK: - Date Range

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generateDateRangeLabel.localized, required: false)
            HStack(spacing: theme.spacing.xs) {
                ForEach(DateRangePreset.allCases) { preset in
                    DSChip(
                        title: preset.label,
                        isSelected: viewModel.datePreset == preset
                    ) {
                        viewModel.datePreset = preset
                    }
                }
            }
        }
    }

    // MARK: - Weekdays

    private var weekdaysSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generateWeekdaysLabel.localized, required: true)

            HStack(spacing: theme.spacing.xs) {
                ForEach(GenerateSlotsViewModel.weekdays) { day in
                    weekdayButton(day)
                }
            }

            HStack(spacing: theme.spacing.sm) {
                Button(ProfileStrings.generateWorkdays.localized) {
                    viewModel.selectWorkdays()
                }
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.primary)

                Text("·")
                    .foregroundStyle(theme.colors.textSecondary)

                Button(ProfileStrings.generateAllDays.localized) {
                    viewModel.selectAllDays()
                }
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.primary)
            }
        }
    }

    private func weekdayButton(_ day: Weekday) -> some View {
        let selected = viewModel.selectedWeekdays.contains(day.id)
        return Button { viewModel.toggleWeekday(day.id) } label: {
            Text(day.label)
                .font(.subheadline.weight(selected ? .bold : .regular))
                .frame(width: 40, height: 40)
                .foregroundStyle(selected ? theme.colors.primaryForeground : theme.colors.textPrimary)
                .background(
                    Circle()
                        .fill(selected ? theme.colors.primary : theme.colors.surfaceTertiary)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generateTimeLabel.localized, required: true)
            HStack(spacing: theme.spacing.sm) {
                timePicker($viewModel.timeFromDate)
                Text("—")
                    .foregroundStyle(theme.colors.textSecondary)
                timePicker($viewModel.timeToDate)
            }
        }
    }

    private func timePicker(_ date: Binding<Date>) -> some View {
        DatePicker("", selection: date, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generateDurationLabel.localized, required: true)
            HStack(spacing: theme.spacing.xs) {
                ForEach(SlotDuration.allCases) { dur in
                    DSChip(
                        title: dur.label,
                        isSelected: viewModel.duration == dur
                    ) {
                        viewModel.duration = dur
                    }
                }
            }
        }
    }

    // MARK: - Price

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            sectionLabel(ProfileStrings.generatePriceLabel.localized, required: true)
            HStack(spacing: theme.spacing.sm) {
                TextField("0", text: $viewModel.priceText)
                    .keyboardType(.numberPad)
                    .padding(theme.spacing.sm)
                    .background(theme.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
                Text("PLN")
                    .dsTextStyle(.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            Task { await viewModel.generate() }
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(theme.colors.primaryForeground)
                }
                Text(ProfileStrings.generateSlotsButton.localized)
            }
        }
        .buttonStyle(.dsPrimary)
        .disabled(viewModel.isSubmitting)
        .padding(.top, theme.spacing.sm)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String, required: Bool) -> some View {
        HStack(spacing: 2) {
            Text(text.uppercased())
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)
            if required {
                Text("*")
                    .dsTextStyle(.caption)
                    .foregroundStyle(theme.colors.error)
            }
        }
    }

    private func resultMessage(_ result: GenerateSlotsResponse) -> String {
        if result.generated == 0 && result.skipped > 0 {
            return ProfileStrings.generateAllSkipped.localized
        } else if result.skipped > 0 {
            return ProfileStrings.generatePartialResult(result.generated, result.skipped)
        } else {
            return ProfileStrings.generateSuccessResult(result.generated)
        }
    }
}
