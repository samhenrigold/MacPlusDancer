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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dancersModel)
                .windowMinimizeBehavior(.disabled)
                .windowResizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
        }
        .windowLevel(.floating)
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
        .restorationBehavior(.disabled)
        .defaultPosition(.bottomTrailing)
        
        MenuBarExtra(isInserted: .constant(true)) {
            Section {
                Picker("Select Dancer", selection: $dancersModel.selectedDancer) {
                    ForEach(dancersModel.dancers) { dancer in
                        Text(dancer.name)
                            .tag(dancer as Dancer?)
                            .help(dancer.description ?? "")
                    }
                }
                .onChange(of: dancersModel.selectedDancer) { oldValue, newValue in
                    if oldValue == newValue {
                        dancersModel.selectedDancer = nil
                    }
                }
                .pickerStyle(.inline)
            }
            
            Section {
                Button(dancersModel.toggleDancerButtonLabel) {
                    dancersModel.isDancing.toggle()
                }
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "figure.dance.circle")
                .symbolVariant(dancersModel.isThereALittleDancerOnScreenAtThisVeryMoment ? .fill : .none)
        }
    }
}
