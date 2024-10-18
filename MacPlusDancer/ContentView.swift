//
//  ContentView.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var playerManager = VideoPlayerManager()
    @State private var composition = CompositionCreator(mainResourceName: "Scooby_SkeleMan_L", matteResourceName: "Scooby_SkeleMan_L_Matte")
    
    var body: some View {
        TransparentVideoPlayer(playerManager: playerManager)
        .frame(width: 320, height: 240)
        .task {
            await playerManager.setupPlayer(with: composition)
        }
        .allowsHitTesting(false)
    }
}


#Preview {
    ContentView()
}
