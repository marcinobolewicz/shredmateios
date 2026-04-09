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

    var onSlideCTATap: ((GuestSlide) -> Void)?

    init(onSlideCTATap: ((GuestSlide) -> Void)? = nil) {
        self.onSlideCTATap = onSlideCTATap
    }

    public var body: some View {
        PageView(items: GuestSlide.all) { slide in
            SlideView(slide: slide, onCTATap: { onSlideCTATap?(slide) })
        }
        .toolbarBackground(.hidden, for: .tabBar)
    }
}

#Preview {
    GuestWelcomeView()
}

