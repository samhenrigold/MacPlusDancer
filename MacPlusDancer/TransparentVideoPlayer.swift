//
//  TransparentVideoPlayer.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import SwiftUI
import AVFoundation

struct TransparentVideoPlayer: View {
    @Bindable var playerManager: VideoPlayerManager

    var body: some View {
        Group {
            if let error = playerManager.error {
                Text("Error: \(error.localizedDescription)")
            } else if let player = playerManager.player {
                VideoPlayerView(player: player)
            } else {
                Text("Loading...")
            }
        }
    }
}

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer?
    
    func makeNSView(context: Context) -> NSView {
        VideoPlayerNSView(player: player)
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? VideoPlayerNSView {
            view.updatePlayer(player)
        }
    }
}

class VideoPlayerNSView: NSView {
    private var playerLayer: AVPlayerLayer?
    
    init(player: AVPlayer?) {
        super.init(frame: .zero)
        setupPlayerLayer(with: player)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayerLayer(with player: AVPlayer?) {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.backgroundColor = NSColor.clear.cgColor
        layer = playerLayer
        wantsLayer = true
    }
    
    func updatePlayer(_ player: AVPlayer?) {
        playerLayer?.player = player
    }
}
