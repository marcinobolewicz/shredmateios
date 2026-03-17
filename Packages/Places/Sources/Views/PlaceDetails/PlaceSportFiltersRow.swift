import SwiftUI
import Theme

struct PlaceSportFiltersRow: View {
    @Environment(AppTheme.self) private var theme

    let filters: [PlaceDetailsViewData.SportFilter]
    let selectedSportSlug: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                ForEach(filters) { sport in
                    if filters.count == 1 {
                        DSChip(
                            title: sport.title,
                            isSelected: selectedSportSlug == sport.slug
                        ) {}
                        .allowsHitTesting(false)
                        .opacity(0.95)
                    } else {
                        DSChip(
                            title: sport.title,
                            isSelected: selectedSportSlug == sport.slug
                        ) {
                            onSelect(sport.slug)
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.xs)
        }
    }
}
