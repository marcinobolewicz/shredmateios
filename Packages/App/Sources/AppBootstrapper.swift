//
//  AppBootstrapper.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 25/02/2026.
//

import Networking

@MainActor
public final class AppBootstrapper {
    private let sportsService: any SportsServiceProtocol
    private var didRun = false

    public init(sportsService: any SportsServiceProtocol) {
        self.sportsService = sportsService
    }

    public func run() async {
        guard !didRun else { return }
        didRun = true
        _ = try? await sportsService.fetchSports()
    }
}
