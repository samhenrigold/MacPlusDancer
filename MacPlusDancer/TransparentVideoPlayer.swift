//
//  TransparentVideoPlayer.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import SwiftUI
import AVFoundation

@Observable
class VideoPlayerManager {
    var player: AVPlayer?
    var error: Error?
    private var playerItemObserver: NSObjectProtocol?
    
    func setupPlayer(with composition: CompositionCreator) async {
        do {
            let (playerItem, videoComposition) = try await composition.createComposition()
            await MainActor.run {
                playerItem.videoComposition = videoComposition
                player = AVPlayer(playerItem: playerItem)
                player?.play()
            }
            
            // Loop video
            playerItemObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            print("Error setting up player: \(error)")
        }
    }
    
    deinit {
        if let observer = playerItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}


struct TransparentVideoPlayer: View {
    @Bindable var playerManager: VideoPlayerManager
    
    var body: some View {
        Group {
            if let error = playerManager.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                VideoPlayerView(player: playerManager.player)
            }
        }
    }
}

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer?
    
    func makeNSView(context: Context) -> NSView {
        let view = VideoPlayerNSView(player: player)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? VideoPlayerNSView {
            view.updatePlayer(player)
        }
    }
    
    static func dismantleNSView(_ nsView: NSView, coordinator: ()) {
        if let view = nsView as? VideoPlayerNSView {
            view.stopDisplayLink()
        }
    }
}

class VideoPlayerNSView: NSView {
    private var playerLayer: AVPlayerLayer?
    private var displayLink: Any?
    
    init(player: AVPlayer?) {
        super.init(frame: .zero)
        setupPlayerLayer(with: player)
        setupDisplayLink()
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
    
    private func setupDisplayLink() {
        displayLink = self.displayLink(target: self, selector: #selector(displayLinkCallback))
    }
    
    @objc private func displayLinkCallback() {
        playerLayer?.setNeedsDisplay()
    }
    
    func stopDisplayLink() {
        if let displayLink = displayLink as? CADisplayLink {
            displayLink.invalidate()
        }
    }
    
    deinit {
        stopDisplayLink()
    }
}
