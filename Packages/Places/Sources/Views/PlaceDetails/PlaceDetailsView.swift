//
//  PlaceDetailsView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Theme

struct PlaceDetailsView: View {
    @Environment(AppTheme.self) private var theme

    var body: some View {
        VStack {
            Text(PlacesStrings.detailsTitle.localized)
                .dsTextStyle(.title)
                .padding(theme.spacing.md)
        }
    }
}
