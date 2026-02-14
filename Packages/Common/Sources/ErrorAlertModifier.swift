//
//  ErrorAlertModifier.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import SwiftUI

public struct ErrorAlertModifier: ViewModifier {
    let state: LoadState
    let retry: () -> Void

    @State private var shownError: AppError?

    public func body(content: Content) -> some View {
        content
            .onChange(of: state) { _, newValue in
                if case .failed(let err) = newValue {
                    shownError = err
                }
            }
            .alert(item: $shownError) { err in
                Alert(
                    title: Text(err.title),
                    message: Text([err.message, err.recoverySuggestion].compactMap { $0 }.joined(separator: "\n")),
                    primaryButton: .default(Text(CommonStrings.retryButton.localized), action: retry),
                    secondaryButton: .cancel(Text(CommonStrings.okButton.localized))
                )
            }
    }
}

public extension View {
    func errorAlert(state: LoadState, retry: @escaping () -> Void) -> some View {
        modifier(ErrorAlertModifier(state: state, retry: retry))
    }
}

