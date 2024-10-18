//
//  CustomVideoCompositor.swift
//  MacPlusDancer
//
//  Created by Sam Gold on 2024-10-17.
//

import AVFoundation
import CoreImage

class CustomVideoCompositor: NSObject, AVVideoCompositing {
    private let renderContextQueue = DispatchQueue(label: "renderContextQueue")
    private var renderContext: AVVideoCompositionRenderContext?
    
    private lazy var ciContext: CIContext = {
        return CIContext(options: [.workingColorSpace: NSNull()])
    }()
    
    private lazy var blendFilter: CIFilter? = {
        return CIFilter(name: "CIBlendWithMask")
    }()
    
    var sourcePixelBufferAttributes: [String : Any]? {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        return [
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
                let matteBuffer = request.sourceFrame(byTrackID: instruction.matteTrackID)
            else {
                request.finish(with: NSError(domain: "com.example", code: -1, userInfo: nil))
                return
            }
            
            let mainImage = CIImage(cvPixelBuffer: mainBuffer)
            let matteImage = CIImage(cvPixelBuffer: matteBuffer)
            
            let clearImage = CIImage(color: .clear).cropped(to: mainImage.extent)
            
            guard let blendFilter = self.blendFilter else {
                request.finish(with: NSError(domain: "com.example", code: -2, userInfo: nil))
                return
            }
            
            blendFilter.setValue(clearImage, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(mainImage, forKey: kCIInputImageKey)
            blendFilter.setValue(matteImage, forKey: kCIInputMaskImageKey)
            
            guard let outputImage = blendFilter.outputImage else {
                request.finish(with: NSError(domain: "com.example", code: -3, userInfo: nil))
                return
            }
            
            guard let outputBuffer = request.renderContext.newPixelBuffer() else {
                request.finish(with: NSError(domain: "com.example", code: -4, userInfo: nil))
                return
            }
            
            ciContext.render(outputImage, to: outputBuffer)
            request.finish(withComposedVideoFrame: outputBuffer)
        }
    }
}
