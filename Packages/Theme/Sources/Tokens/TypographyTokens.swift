//
//  TypographyTokens.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Typography scale using system Dynamic Type fonts.
/// Leverages `Font` semantic styles for automatic accessibility scaling.
public struct TypographyTokens: Sendable {

    public let largeTitle: Font
    public let title: Font
    public let title2: Font
    public let title3: Font
    public let headline: Font
    public let body: Font
    public let callout: Font
    public let subheadline: Font
    public let footnote: Font
    public let caption: Font

    public init(
        largeTitle: Font = .largeTitle,
        title: Font = .title,
        title2: Font = .title2,
        title3: Font = .title3,
        headline: Font = .headline,
        body: Font = .body,
        callout: Font = .callout,
        subheadline: Font = .subheadline,
        footnote: Font = .footnote,
        caption: Font = .caption
    ) {
        self.largeTitle = largeTitle
        self.title = title
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption = caption
    }
}
