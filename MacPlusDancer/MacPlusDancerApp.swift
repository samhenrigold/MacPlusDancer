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
    
    private let groupOrder = ["Modern", "Traditional", "Retro", "Seth", "Novelty"]
    
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
        
        MenuBarExtra {
            Section {
                Picker("Select Dancer", selection: $dancersModel.selectedDancer) {
                    ForEach(sortedGroupKeys(), id: \.self) { group in
                        Section(header: Text(group)) {
                            ForEach(dancersModel.groupedDancers[group]!.sorted(by: { $0.name < $1.name })) { dancer in
                                Button {} label: {
                                    Text(dancer.name)
                                    Text(dancer.general_dance_style ?? "")
                                }
                                .tag(dancer as Dancer?)
                            }
                        }
                    }
                }
                .onChange(of: dancersModel.selectedDancer) { oldValue, newValue in
                    if oldValue == newValue {
                        dancersModel.selectedDancer = nil
                    }
                }
            }
            
            Section {
                let isSeth = dancersModel.selectedDancer?.name == "Seth"
                
                Button(isSeth ? "Seth is not permitted to stop dancing" : dancersModel.toggleDancerButtonLabel) {
                    dancersModel.isDancing.toggle()
                }
                .disabled(isSeth)
                .help(isSeth ? "If Seth stops dancing, he dies." : "")
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "figure.dance.circle")
                .symbolVariant(dancersModel.isThereALittleDancerOnScreenAtThisVeryMoment ? .fill : .none)
        }
    }
    
    private func sortedGroupKeys() -> [String] {
        let allGroups = dancersModel.groupedDancers.keys
        
        // Separate specified groups and game groups
        let specifiedGroups = groupOrder
        let gameGroups = allGroups.filter { !groupOrder.contains($0) }.sorted()
        
        // Combine specified groups and game groups
        return specifiedGroups + gameGroups
    }
}
