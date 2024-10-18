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
    
    func setupPlayer(with composition: CompositionCreator) {
        let (playerItem, videoComposition) = composition.createComposition()
        playerItem.videoComposition = videoComposition
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    func stopDisplayLink() {
        // Implement if needed
    }
}

struct TransparentVideoPlayer: View {
    @Bindable var playerManager: VideoPlayerManager

    var body: some View {
        VideoPlayerView(player: playerManager.player)
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
    private var displayLink: CVDisplayLink?

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
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
            let view = Unmanaged<VideoPlayerNSView>.fromOpaque(displayLinkContext!).takeUnretainedValue()
            view.displayLinkCallback(inOutputTime: inOutputTime)
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(displayLink!)
    }

    private func displayLinkCallback(inOutputTime: UnsafePointer<CVTimeStamp>) {
        DispatchQueue.main.async { [weak self] in
            self?.playerLayer?.setNeedsDisplay()
        }
    }

    func stopDisplayLink() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }

    deinit {
        stopDisplayLink()
    }
}
