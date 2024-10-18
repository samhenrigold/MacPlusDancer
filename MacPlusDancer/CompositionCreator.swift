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
    
    func createComposition() -> (AVPlayerItem, AVMutableVideoComposition) {
        let mainURL = Bundle.main.url(forResource: mainResourceName, withExtension: "mp4")!
        let matteURL = Bundle.main.url(forResource: matteResourceName, withExtension: "mp4")!

        let mainAsset = AVURLAsset(url: mainURL)
        let matteAsset = AVURLAsset(url: matteURL)

        let composition = AVMutableComposition()
        guard
            let mainTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let matteTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
            let mainAssetTrack = mainAsset.tracks(withMediaType: .video).first,
            let matteAssetTrack = matteAsset.tracks(withMediaType: .video).first
        else {
            fatalError("Failed to load video tracks")
        }

        do {
            try mainTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: mainAsset.duration), of: mainAssetTrack, at: .zero)
            try matteTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: matteAsset.duration), of: matteAssetTrack, at: .zero)
        } catch {
            fatalError("Failed to insert video tracks into composition: \(error)")
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.customVideoCompositorClass = CustomVideoCompositor.self
        videoComposition.renderSize = mainTrack.naturalSize

        // Set frame duration based on the video's frame rate
        let nominalFrameRate = mainAssetTrack.nominalFrameRate
        videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(nominalFrameRate))

        let instruction = CustomVideoCompositionInstruction(
            timeRange: CMTimeRangeMake(start: .zero, duration: composition.duration),
            mainTrackID: mainTrack.trackID,
            matteTrackID: matteTrack.trackID
        )
        videoComposition.instructions = [instruction]

        return (AVPlayerItem(asset: composition), videoComposition)
    }
}
