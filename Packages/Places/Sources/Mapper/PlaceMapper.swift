//
//  PlaceMapper.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation
import Networking

public enum PlaceMapper {
    public static func map(_ dto: PlaceDto) -> Place {
        Place(
            id: dto.id,
            name: dto.name,
            description: dto.description ?? "",
            avatarURL: dto.avatarUrl,
            location: dto.location.map { GeoPoint(lat: $0.lat, lng: $0.lng) }
        )
    }
}
