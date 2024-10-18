//
//  DancersModel.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import Foundation
import Observation

/// A model that manages the list of dancers and the selected dancer state.
@Observable
class DancersModel {
    var dancers: [Dancer] = []
    var selectedDancer: Dancer?
    var isDancing: Bool = true
    
    var toggleDancerButtonLabel: String {
        isDancing ? "Stop Dancing" : "Start Dancing"
    }
    
    var isThereALittleDancerOnScreenAtThisVeryMoment: Bool {
        selectedDancer != nil && isDancing
    }
    
    var groupedDancers: [String: [Dancer]] {
        Dictionary(grouping: dancers, by: { $0.group ?? "Unknown" })
    }
    
    init() {
        loadDancers()
    }
    
    func loadDancers() {
        guard let url = Bundle.main.url(forResource: "Metadata", withExtension: "json") else {
            print("Metadata.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dancersData = try decoder.decode(DancersData.self, from: data)
            dancers = dancersData.dancers.sorted { $0.name < $1.name }
            selectedDancer = dancers.first
        } catch {
            print("Failed to load or parse Metadata.json: \(error)")
        }
    }
}
