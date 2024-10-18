//
//  ContentView.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @Environment(DancersModel.self) private var dancersModel
    @State private var playerManager = VideoPlayerManager()

    var body: some View {
        VStack {
            if let selectedDancer = dancersModel.selectedDancer {
                TransparentVideoPlayer(playerManager: playerManager)
                    .frame(width: 320, height: 240)
                    .onChange(of: dancersModel.selectedDancer) { _, newDancer in
                        if let newDancer = newDancer {
                            Task {
                                await updateComposition(for: newDancer)
                            }
                        }
                    }
                    .task {
                        await updateComposition(for: selectedDancer)
                    }
                    .allowsHitTesting(false)
            } else {
                Text("Please select a dancer")
            }

            List(dancersModel.dancers) { dancer in
                Button(action: {
                    dancersModel.selectedDancer = dancer
                }) {
                    Text(dancer.name)
                }
            }
        }
        .onAppear {
            dancersModel.loadDancers()
        }
    }

    func updateComposition(for dancer: Dancer) async {
        guard let regularVideoPath = dancer.regular_video?.converted_file,
              let matteVideoPath = dancer.matte_video?.converted_file else {
            print("No video files for dancer \(dancer.name)")
            return
        }

        let composition = CompositionCreator(mainResourcePath: regularVideoPath, matteResourcePath: matteVideoPath)
        await playerManager.setupPlayer(with: composition)
    }
}

#Preview {
    ContentView()
}
