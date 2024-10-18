//
//  CompositionCreator.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import AVFoundation
import Observation

@Observable
class CompositionCreator {
    var mainResourceName: String
    var matteResourceName: String
    
    init(mainResourceName: String, matteResourceName: String) {
        self.mainResourceName = mainResourceName
        self.matteResourceName = matteResourceName
    }
    
    func createComposition() async throws -> (AVPlayerItem, AVMutableVideoComposition) {
                // Remove the extension from the filename
        let mainResourceName = URL(fileURLWithPath: mainResourceName).deletingPathExtension().lastPathComponent
        let matteResourceName = URL(fileURLWithPath: matteResourceName).deletingPathExtension().lastPathComponent
        
        guard let mainURL = Bundle.main.url(forResource: mainResourceName, withExtension: "mp4") else {
            throw NSError(domain: "CompositionCreator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to find main video resource"])
        }
        
        guard let matteURL = Bundle.main.url(forResource: matteResourceName, withExtension: "mp4") else {
            throw NSError(domain: "CompositionCreator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to find matte video resource"])
        }
        
        let mainAsset = AVURLAsset(url: mainURL)
        let matteAsset = AVURLAsset(url: matteURL)
        
        let (composition, mainTrack, matteTrack) = try await createMutableComposition(mainAsset: mainAsset, matteAsset: matteAsset)
        let videoComposition = try await createVideoComposition(composition: composition, mainTrack: mainTrack, matteTrack: matteTrack)
        
        return await MainActor.run {
            let playerItem = AVPlayerItem(asset: composition)
            return (playerItem, videoComposition)
        }
    }
    
    private func createMutableComposition(mainAsset: AVURLAsset, matteAsset: AVURLAsset) async throws -> (AVMutableComposition, AVMutableCompositionTrack, AVMutableCompositionTrack) {
        let composition = AVMutableComposition()
        
        guard
            let mainTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let matteTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let mainAssetTrack = try await mainAsset.loadTracks(withMediaType: .video).first,
            let matteAssetTrack = try await matteAsset.loadTracks(withMediaType: .video).first
        else {
            throw NSError(domain: "CompositionCreator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load video tracks"])
        }
        
        let mainDuration = try await mainAsset.load(.duration)
        let matteDuration = try await matteAsset.load(.duration)
        
        let duration = min(mainDuration, matteDuration)
        
        try mainTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: mainAssetTrack, at: .zero)
        try matteTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: matteAssetTrack, at: .zero)
        
        return (composition, mainTrack, matteTrack)
    }
    
    private func createVideoComposition(composition: AVMutableComposition, mainTrack: AVMutableCompositionTrack, matteTrack: AVMutableCompositionTrack) async throws -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = CustomVideoCompositor.self
        videoComposition.renderSize = mainTrack.naturalSize
        
        let nominalFrameRate = try await mainTrack.load(.nominalFrameRate)
        videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(nominalFrameRate))
        
        let instruction = CustomVideoCompositionInstruction(
            timeRange: CMTimeRangeMake(start: .zero, duration: composition.duration),
            mainTrackID: mainTrack.trackID,
            matteTrackID: matteTrack.trackID
        )
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
}
