//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import ARKit
import Math

public class ARSubpass: Subpass {
    var capturedImagePipelineState: MTLRenderPipelineState!
    var capturedImageDepthState: MTLDepthStencilState!
    var imagePlaneVertexBuffer: MTLBuffer!

    var viewportSize: CGSize = CGSize()
    var viewportSizeDidChange: Bool = true

    // Vertex data for an image plane
    let kImagePlaneVertexData: [Float] = [
        -1.0, -1.0, 0.0, 1.0,
        1.0, -1.0, 1.0, 1.0,
        -1.0, 1.0, 0.0, 0.0,
        1.0, 1.0, 1.0, 0.0,
    ]

    override init() {
        super.init()

        // Create a vertex descriptor for our image plane vertex buffer
        let imagePlaneVertexDescriptor = MTLVertexDescriptor()
        // Positions.
        imagePlaneVertexDescriptor.attributes[0].format = .float2
        imagePlaneVertexDescriptor.attributes[0].offset = 0
        imagePlaneVertexDescriptor.attributes[0].bufferIndex = 0
        // Texture coordinates.
        imagePlaneVertexDescriptor.attributes[1].format = .float2
        imagePlaneVertexDescriptor.attributes[1].offset = 8
        imagePlaneVertexDescriptor.attributes[1].bufferIndex = 0
        // Buffer Layout
        imagePlaneVertexDescriptor.layouts[0].stride = 16
        imagePlaneVertexDescriptor.layouts[0].stepRate = 1
        imagePlaneVertexDescriptor.layouts[0].stepFunction = .perVertex

        // Create a vertex buffer with our image plane vertex data.
        let imagePlaneVertexDataCount = kImagePlaneVertexData.count * MemoryLayout<Float>.size
        imagePlaneVertexBuffer = Engine.device.makeBuffer(bytes: kImagePlaneVertexData, length: imagePlaneVertexDataCount, options: [])
        imagePlaneVertexBuffer.label = "ImagePlaneVertexBuffer"

        let capturedImageVertexFunction = Engine.library().makeFunction(name: "capturedImageVertexTransform")!
        let capturedImageFragmentFunction = Engine.library().makeFunction(name: "capturedImageFragmentShader")!
        let capturedImagePipelineStateDescriptor = MTLRenderPipelineDescriptor()
        capturedImagePipelineStateDescriptor.label = "CapturedImagePipeline"
        capturedImagePipelineStateDescriptor.rasterSampleCount = Int(Engine.canvas.sampleCount)
        capturedImagePipelineStateDescriptor.vertexFunction = capturedImageVertexFunction
        capturedImagePipelineStateDescriptor.fragmentFunction = capturedImageFragmentFunction
        capturedImagePipelineStateDescriptor.vertexDescriptor = imagePlaneVertexDescriptor
        capturedImagePipelineStateDescriptor.colorAttachments[0].pixelFormat = Engine.canvas.colorPixelFormat
        capturedImagePipelineStateDescriptor.depthAttachmentPixelFormat = Engine.canvas.depthStencilPixelFormat
        capturedImagePipelineStateDescriptor.stencilAttachmentPixelFormat = Engine.canvas.depthStencilPixelFormat
        do {
            try capturedImagePipelineState = Engine.device.makeRenderPipelineState(descriptor: capturedImagePipelineStateDescriptor)
        } catch let error {
            print("Failed to created captured image pipeline state, error \(error)")
        }

        let capturedImageDepthStateDescriptor = MTLDepthStencilDescriptor()
        capturedImageDepthStateDescriptor.depthCompareFunction = .lessEqual
        capturedImageDepthStateDescriptor.isDepthWriteEnabled = false
        capturedImageDepthState = Engine.device.makeDepthStencilState(descriptor: capturedImageDepthStateDescriptor)

        viewportSize = Engine.canvas.bounds.size
        let updateFlag = ListenerUpdateFlag()
        updateFlag.listener = resize
        Engine.canvas.updateFlagManager.addFlag(flag: updateFlag)
    }

    public override func draw(_ encoder: inout RenderCommandEncoder) {
        guard let arManager = Engine.arManager,
              let currentFrame = arManager.session.currentFrame else {
            return
        }

        if viewportSizeDidChange {
            viewportSizeDidChange = false
            updateImagePlane(frame: currentFrame)
        }

        guard let textureY = arManager.capturedImageTextureY,
                let textureCbCr = arManager.capturedImageTextureCbCr else {
            return
        }

        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool
        encoder.handle.pushDebugGroup("DrawCapturedImage")

        // Set render command encoder state
        encoder.handle.setCullMode(.none)
        encoder.handle.setRenderPipelineState(capturedImagePipelineState)
        encoder.handle.setDepthStencilState(capturedImageDepthState)

        // Set mesh's vertex buffers
        encoder.handle.setVertexBuffer(imagePlaneVertexBuffer, offset: 0, index: 0)

        // Set any textures read/sampled from our render pipeline
        encoder.handle.setFragmentTexture(CVMetalTextureGetTexture(textureY), index: 0)
        encoder.handle.setFragmentTexture(CVMetalTextureGetTexture(textureCbCr), index: 1)

        // Draw each submesh of our mesh
        encoder.handle.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        encoder.handle.popDebugGroup()
    }

    private func resize(bit: Int?, param: AnyObject?) {
        viewportSizeDidChange = true
        viewportSize = (param as! Canvas).bounds.size
    }

    private func updateImagePlane(frame: ARFrame) {
        // Update the texture coordinates of our image plane to aspect fill the viewport
        let displayToCameraTransform = frame.displayTransform(for: .landscapeRight, viewportSize: viewportSize).inverted()

        let vertexData = imagePlaneVertexBuffer.contents().assumingMemoryBound(to: Float.self)
        for index in 0...3 {
            let textureCoordIndex = 4 * index + 2
            let textureCoord = CGPoint(x: CGFloat(kImagePlaneVertexData[textureCoordIndex]), y: CGFloat(kImagePlaneVertexData[textureCoordIndex + 1]))
            let transformedCoord = textureCoord.applying(displayToCameraTransform)
            vertexData[textureCoordIndex] = Float(transformedCoord.x)
            vertexData[textureCoordIndex + 1] = Float(transformedCoord.y)
        }
    }
}
