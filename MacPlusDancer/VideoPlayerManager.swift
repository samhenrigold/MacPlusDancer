//
//  VideoPlayerManager.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-18.
//

import Observation
import AVFoundation

@Observable
class VideoPlayerManager {
    var player: AVPlayer?
    var error: Error?
    private var playerItemObserver: NSObjectProtocol?
    
    func setupPlayer(with composition: CompositionCreator) async {
        player?.pause()
        player = nil
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
