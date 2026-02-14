//
//  AppError.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

public struct AppError: Error, Equatable, Sendable, Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let recoverySuggestion: String?

    public init(title: String, message: String, recoverySuggestion: String? = nil) {
        self.title = title
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }
}

public extension AppError {
    static func from(_ error: Error) -> AppError {
        AppError(
            title: CommonStrings.genericErrorTitle.localized,
            message: CommonStrings.genericErrorMessage.localized,
            recoverySuggestion: CommonStrings.genericErrorRecovery.localized
        )
    }
}

