//
//  GuestWelcomeView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI

/// Full-screen vertical page view shown to unauthenticated users.
///
/// Three slides highlight core app features; each CTA button forwards
/// the `onCTATap` callback so the parent can decide what to do
/// (e.g. switch to the login flow).
public struct GuestWelcomeView: View {

    var onCTATap: (() -> Void)?

    public init(onCTATap: (() -> Void)? = nil) {
        self.onCTATap = onCTATap
    }

    public var body: some View {
        VerticalPageView(items: GuestSlide.all) { slide in
            SlideView(slide: slide, onCTATap: onCTATap)
        }
    }
}

#Preview {
    GuestWelcomeView()
}

