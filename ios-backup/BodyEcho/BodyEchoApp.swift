//
//  BodyEchoApp.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI
import FirebaseCore

@main
struct BodyEchoApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
