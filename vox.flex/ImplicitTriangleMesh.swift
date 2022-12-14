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
    
    public func buildBVH(_ resize: Bool = true) {
        _triangleMesh.buildBVH(_engine.device, resize)
    }
    
    public func generateSDF(lower: SIMD3<Float>,
                            upper: SIMD3<Float>,
                            res: SIMD3<Int>) {
        if sdf == nil || res != self.res {
            let desc = MTLTextureDescriptor()
            desc.pixelFormat = .r32Float
            desc.width = res.x
            desc.height = res.y
            desc.depth = res.z
            desc.textureType = .type3D
            desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
            desc.storageMode = .private
            sdf = _engine.device.makeTexture(descriptor: desc);
        }
        
        if lower != self.lower || upper != self.upper || res != self.res {
            self.lower = lower
            self.upper = upper
            self.res = res
            
            let function = _engine.library("flex.shader").makeFunction(name: "sdfBaker")
            let pipelineState = try! _engine.device.makeComputePipelineState(function: function!)
            if let commandBuffer = _engine.commandQueue.makeCommandBuffer() {
                if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                    commandEncoder.setComputePipelineState(pipelineState)
                    commandEncoder.setTexture(sdf!, index: 0)
                    commandEncoder.setBuffer(_triangleMesh.nodeBuffer(), offset: 0, index: 1)
                    commandEncoder.setBuffer(_triangleMesh.verticesBuffer(), offset: 0, index: 2)
                    commandEncoder.setBuffer(_triangleMesh.normalBuffer(), offset: 0, index: 3)
                    
                    extend = upper - lower
                    commandEncoder.setBytes(&self.lower, length: MemoryLayout<SIMD3<Float>>.stride, index: 4)
                    commandEncoder.setBytes(&self.upper, length: MemoryLayout<SIMD3<Float>>.stride, index: 5)
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
