//
//  SportsAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Sports API endpoints
public enum SportsAPI {
    
    /// Get all available sports
    public static func all() -> Endpoint<[Sport]> {
        .get("/sports", auth: .bearerToken)
    }
}
