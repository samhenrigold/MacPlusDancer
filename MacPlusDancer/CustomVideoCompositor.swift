//
//  CustomVideoCompositor.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import AVFoundation
import CoreImage

/// A custom video compositor that blends main video and matte video to create a transparent background.
class CustomVideoCompositor: NSObject, AVVideoCompositing {
    private let renderContextQueue = DispatchQueue(label: "renderContextQueue")
    private var renderContext: AVVideoCompositionRenderContext?
    
    private lazy var ciContext: CIContext = {
        CIContext(options: [.workingColorSpace: NSNull()])
    }()
    
    private lazy var blendFilter: CIFilter? = {
        CIFilter(name: "CIBlendWithMask")
    }()
    
    var sourcePixelBufferAttributes: [String : Any]? {
        [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync {
            renderContext = newRenderContext
        }
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        autoreleasepool {
            guard
                let instruction = request.videoCompositionInstruction as? CustomVideoCompositionInstruction,
                let mainBuffer = request.sourceFrame(byTrackID: instruction.mainTrackID),
                let matteBuffer = request.sourceFrame(byTrackID: instruction.matteTrackID),
                let blendFilter = blendFilter
            else {
                request.finish(with: NSError(domain: "CustomVideoCompositor", code: -1, userInfo: nil))
                return
            }
            
            let mainImage = CIImage(cvPixelBuffer: mainBuffer)
            let matteImage = CIImage(cvPixelBuffer: matteBuffer)
            let clearImage = CIImage(color: .clear).cropped(to: mainImage.extent)
            
            blendFilter.setValue(clearImage, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(mainImage, forKey: kCIInputImageKey)
            blendFilter.setValue(matteImage, forKey: kCIInputMaskImageKey)
            
            guard let outputImage = blendFilter.outputImage else {
                request.finish(with: NSError(domain: "CustomVideoCompositor", code: -2, userInfo: nil))
                return
            }
            
            guard let outputBuffer = request.renderContext.newPixelBuffer() else {
                request.finish(with: NSError(domain: "CustomVideoCompositor", code: -3, userInfo: nil))
                return
            }
            
            ciContext.render(outputImage, to: outputBuffer)
            request.finish(withComposedVideoFrame: outputBuffer)
        }
    }
}
