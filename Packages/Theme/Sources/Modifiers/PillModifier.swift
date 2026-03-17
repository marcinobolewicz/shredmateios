//
//  File.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 25/02/2026.
//

import SwiftUI

public struct PillModifier: ViewModifier {
    let theme: AppTheme
    var backgroundColor: Color? = nil
    var foregroundColor: Color? = nil

    public func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .foregroundStyle(foregroundColor ?? theme.colors.primaryForeground)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xxs + 2)
            .background(
                Capsule()
                    .fill(backgroundColor ?? theme.colors.primary)
            )
    }
}

extension View {
    public func pillStyle(theme: AppTheme,
                   backgroundColor: Color? = nil,
                   foregroundColor: Color? = nil) -> some View {
        modifier(PillModifier(
            theme: theme,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }
}

public struct PillView: View {
    let title: String
    let theme: AppTheme
    var backgroundColor: Color? = nil
    var foregroundColor: Color? = nil

    public init(
        title: String,
        theme: AppTheme,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.title = title
        self.theme = theme
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        Text(title)
            .pillStyle(theme: theme,
                       backgroundColor: backgroundColor,
                       foregroundColor: foregroundColor)
    }
}
