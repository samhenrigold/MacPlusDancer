//
//  CustomVideoCompositionInstruction.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import AVFoundation

class CustomVideoCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    let timeRange: CMTimeRange
    let enablePostProcessing: Bool = false
    let containsTweening: Bool = false
    let requiredSourceTrackIDs: [NSValue]?
    let passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid

    let mainTrackID: CMPersistentTrackID
    let matteTrackID: CMPersistentTrackID

    init(timeRange: CMTimeRange, mainTrackID: CMPersistentTrackID, matteTrackID: CMPersistentTrackID) {
        self.timeRange = timeRange
        self.mainTrackID = mainTrackID
        self.matteTrackID = matteTrackID
        self.requiredSourceTrackIDs = [NSNumber(value: mainTrackID), NSNumber(value: matteTrackID)]
    }
}
