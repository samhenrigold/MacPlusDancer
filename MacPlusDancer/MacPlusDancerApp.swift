//
//  MacPlusDancerApp.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import SwiftUI

@main
struct MacPlusDancerApp: App {
    @State private var dancersModel = DancersModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dancersModel)
//                .containerBackground(.ultraThinMaterial.opacity(0.5), for: .window)
                .windowMinimizeBehavior(.disabled)
                .windowResizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
        }
        .windowLevel(.floating)
//        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
        .restorationBehavior(.disabled)
        .defaultPosition(.bottomTrailing)
    }
}
