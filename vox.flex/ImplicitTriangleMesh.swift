//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class ImplicitTriangleMesh {
    private var _triangleMesh = TriangleMesh()
    private var _engine: Engine
    var lower = SIMD3<Float>()
    var upper = SIMD3<Float>()
    var extend = SIMD3<Float>()
    var res = SIMD3<Int>()
    var sdf: MTLTexture?
    
    public var signRayCount: UInt32 = 1
    
    public init(_ engine: Engine) {
        _engine = engine
    }
    
    public func load(with filename: URL) {
        _triangleMesh.load(filename.path())
    }
    
    public func buildBVH() {
        _triangleMesh.buildBVH(_engine.device)
    }
    
    public func generateSDF(resolutionX: Int = 32, margin: Float = 0.2) {
        let lowerBounds = _triangleMesh.lowerBounds()
        let upperBounds = _triangleMesh.upperBounds()
        let scale = upperBounds - lowerBounds
        
        lower = lowerBounds - scale * margin
        upper = upperBounds + scale * margin
        extend = scale * (1 + margin * 2)

        let resolutionY = Int(ceil(Float(resolutionX) * extend.y / extend.x))
        let resolutionZ = Int(ceil(Float(resolutionX) * extend.z / extend.x))
        let resolution = SIMD3<Int>(resolutionX, resolutionY, resolutionZ)
        
        if sdf == nil || resolution != res {
            let desc = MTLTextureDescriptor()
            desc.pixelFormat = .r32Float
            desc.width = resolution.x
            desc.height = resolution.y
            desc.depth = resolution.z
            desc.textureType = .type3D
            desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
            desc.storageMode = .private
            sdf = _engine.device.makeTexture(descriptor: desc);
        }
        
        if resolution != res {
            res = resolution
            
            let function = _engine.library("flex.shader").makeFunction(name: "sdfBaker")
            let pipelineState = try! _engine.device.makeComputePipelineState(function: function!)
            if let commandBuffer = _engine.commandQueue.makeCommandBuffer() {
                if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                    commandEncoder.setComputePipelineState(pipelineState)
                    commandEncoder.setTexture(sdf!, index: 0)
                    commandEncoder.setBuffer(_triangleMesh.nodeBuffer(), offset: 0, index: 1)
                    commandEncoder.setBuffer(_triangleMesh.verticesBuffer(), offset: 0, index: 2)
                    commandEncoder.setBuffer(_triangleMesh.normalBuffer(), offset: 0, index: 3)
                    
                    commandEncoder.setBytes(&lower, length: MemoryLayout<SIMD3<Float>>.stride, index: 4)
                    commandEncoder.setBytes(&upper, length: MemoryLayout<SIMD3<Float>>.stride, index: 5)
                    commandEncoder.setBytes(&extend, length: MemoryLayout<SIMD3<Float>>.stride, index: 6)
                    
                    var triangleCount = _triangleMesh.triangleCount()
                    commandEncoder.setBytes(&triangleCount, length: MemoryLayout<UInt32>.stride, index: 7)
                    commandEncoder.setBytes(&signRayCount, length: MemoryLayout<UInt32>.stride, index: 8)

                    let w = pipelineState.threadExecutionWidth
                    let h = pipelineState.maxTotalThreadsPerThreadgroup / w
                    let X_SLICE_SIZE = 32;
                    for xBeg in stride(from: 0, to: res.x, by: X_SLICE_SIZE) {
                        var xBeg = xBeg
                        var xEnd = UInt32(min(res.x, xBeg + X_SLICE_SIZE))
                        commandEncoder.setBytes(&xBeg, length: MemoryLayout<UInt32>.stride, index: 9)
                        commandEncoder.setBytes(&xEnd, length: MemoryLayout<UInt32>.stride, index: 10)
                        
                        commandEncoder.dispatchThreads(MTLSizeMake(1, res.y, res.z),
                                threadsPerThreadgroup: MTLSizeMake(1, w, h))
                    }
                    commandEncoder.endEncoding()
                }

                commandBuffer.commit()
            }
            
        }
    }
}
