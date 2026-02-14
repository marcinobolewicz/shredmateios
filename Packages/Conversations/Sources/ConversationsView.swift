//
//  ConversationsView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//
//  This file is kept for backward compatibility.
//  The main entry point is ConversationsRootView.
//

import SwiftUI
import Theme

public struct ConversationsView: View {
    public init() {}

    public var body: some View {
        ConversationsRootView()
    }
}

#Preview {
    ConversationsView()
        .environment(AppTheme.default)
}
