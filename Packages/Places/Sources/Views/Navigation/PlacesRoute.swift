//
//  PlacesRoute.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import Foundation

public enum PlacesRoute: Hashable {
    case placeDetails(PlaceDetailsViewData)
    case riderCard(RiderCardViewData)
}
