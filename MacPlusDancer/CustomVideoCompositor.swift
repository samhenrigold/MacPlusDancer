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

    static let kernel: CIColorKernel = {
        let kernelString = """
        kernel vec4 alphaFrame(__sample s, __sample m) {
            return vec4(s.rgb, m.r);
        }
        """
        return CIColorKernel(source: kernelString)!
    }()

    var sourcePixelBufferAttributes: [String : Any]? {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
    }

    var requiredPixelBufferAttributesForRenderContext: [String : Any] {
        return [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
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

            // Optionally invert the matte if necessary
            // let matteImage = matteImage.applyingFilter("CIColorInvert")

            // Apply the custom kernel to combine images
            guard let outputImage = CustomVideoCompositor.kernel.apply(extent: mainImage.extent, arguments: [mainImage, matteImage]) else {
                request.finish(with: NSError(domain: "com.example", code: -2, userInfo: nil))
                return
            }

            guard let outputBuffer = request.renderContext.newPixelBuffer() else {
                request.finish(with: NSError(domain: "com.example", code: -3, userInfo: nil))
                return
            }

            ciContext.render(outputImage, to: outputBuffer)
            request.finish(withComposedVideoFrame: outputBuffer)
        }
    }
}
