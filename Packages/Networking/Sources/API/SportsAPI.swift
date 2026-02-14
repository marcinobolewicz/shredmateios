//
//  SportsAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

public enum SportsAPI {
    
    public static func all() -> Endpoint<[Sport]> {
        .get("/sports", auth: .bearerToken)
    }
}
