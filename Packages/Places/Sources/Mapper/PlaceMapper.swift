//
//  PlaceMapper.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation
import Networking
public enum SportMapper {
    public static func map(_ dto: Sport) -> PlaceSport {
        PlaceSport(
            id: dto.id,
            name: dto.name,
            slug: dto.slug
        )
    }
}
public enum PlaceMapper {
    public static func map(_ dto: PlaceDto) -> Place {
        Place(
            id: dto.id,
            name: dto.name,
            description: dto.description ?? "",
            avatarURL: dto.avatarUrl,
            location: dto.location.map { GeoPoint(lat: $0.lat, lng: $0.lng) },
            sports: (dto.sports ?? []).map { PlaceSport(id: $0.id, name: $0.name, slug: $0.slug) },
            ridersCount: dto.ridersCount ?? 0,
            mentorsCount: dto.mentorsCount ?? 0
        )
    }
}
