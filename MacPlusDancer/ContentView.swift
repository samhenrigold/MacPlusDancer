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
    @State private var composition = CompositionCreator(mainResourceName: "Amanda_L", matteResourceName: "Amanda_L_Matte")
    
    var body: some View {
        ZStack {
            TransparentVideoPlayer(playerManager: playerManager)
        }
        .frame(width: 320, height: 240)
        .task {
            await playerManager.setupPlayer(with: composition)
        }
    }
}


#Preview {
    ContentView()
}
