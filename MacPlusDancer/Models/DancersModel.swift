//
//  DancersModel.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import Foundation
import Observation

@Observable
class DancersModel {
    var dancers: [Dancer] = []
    var selectedDancer: Dancer?
    var isDancing: Bool = true
    
    var toggleDancerButtonLabel: String {
        self.isDancing ? "Stop Dancing" : "Start Dancing"
    }
    
    var isThereALittleDancerOnScreenAtThisVeryMoment: Bool {
        self.selectedDancer != nil && self.isDancing
    }

    func loadDancers() {
        if let url = Bundle.main.url(forResource: "Metadata", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let dancersData = try decoder.decode(DancersData.self, from: data)
                dancers = dancersData.dancers.sorted { $0.name < $1.name }
                selectedDancer = dancers.first
            } catch {
                print("Failed to load or parse Metadata.json: \(error)")
            }
        } else {
            print("Metadata.json not found in bundle")
        }
    }
}
