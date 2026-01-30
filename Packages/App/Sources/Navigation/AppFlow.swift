//
//  AppFlow.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Login

enum RootFlow: Equatable {
    case guest
    case auth(AuthEntryPoint = .login)
    case user
}

@MainActor
@Observable
final class RootRouter {
    var flow: RootFlow = .guest
    
    func showGuest() { flow = .guest }
    func showAuth(_ entry: AuthEntryPoint = .login) { flow = .auth(entry) }
    func showUser() { flow = .user }
}

