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
    private var _signRayCount: UInt32

    var data = SDFData()
    var res = SIMD3<Int>()
    var sdf: MTLTexture?
    var sdfSampler = MTLSamplerDescriptor()
    
    public static func builder() -> Builder {
        ImplicitTriangleMesh.Builder()
    }
    
    public init(_ engine: Engine, mesh: TriangleMesh,
                resolutionX: Int = 32, margin: Float = 0.2, signRayCount: UInt32 = 12,
                transform: simd_float4x4 = simd_float4x4()) {
        _engine = engine
        _triangleMesh = mesh
        _signRayCount = signRayCount
        
        sdfSampler.magFilter = .linear
        sdfSampler.minFilter = .linear
        sdfSampler.mipFilter = .linear
        sdfSampler.rAddressMode = .clampToEdge
        sdfSampler.sAddressMode = .clampToEdge
        sdfSampler.tAddressMode = .clampToEdge
        
        let lowerBounds = _triangleMesh.lowerBounds()
        let upperBounds = _triangleMesh.upperBounds()
        let scale = upperBounds - lowerBounds
        
        data.SDFLower = lowerBounds - scale * margin
        data.SDFUpper = upperBounds + scale * margin
        let extend = scale * (1 + margin * 2)
        let resolutionY = Int(ceil(Float(resolutionX) * extend.y / extend.x))
        let resolutionZ = Int(ceil(Float(resolutionX) * extend.z / extend.x))
        res = SIMD3<Int>(resolutionX, resolutionY, resolutionZ)
        
        _createGrid()
        _generateSDF()
    }
    
    private func _createGrid() {
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
    
    private func _generateSDF() {
        let function = _engine.library("flex.shader").makeFunction(name: "sdfBaker")
        let pipelineState = try! _engine.device.makeComputePipelineState(function: function!)
        if let commandBuffer = _engine.commandQueue.makeCommandBuffer() {
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                commandEncoder.setComputePipelineState(pipelineState)
                commandEncoder.setTexture(sdf!, index: 0)
                commandEncoder.setBuffer(_triangleMesh.nodeBuffer(), offset: 0, index: 1)
                commandEncoder.setBuffer(_triangleMesh.verticesBuffer(), offset: 0, index: 2)
                commandEncoder.setBuffer(_triangleMesh.normalBuffer(), offset: 0, index: 3)
                
                commandEncoder.setBytes(&data, length: MemoryLayout<SDFData>.stride, index: 4)
                
                var triangleCount = _triangleMesh.triangleCount()
                commandEncoder.setBytes(&triangleCount, length: MemoryLayout<UInt32>.stride, index: 5)
                commandEncoder.setBytes(&_signRayCount, length: MemoryLayout<UInt32>.stride, index: 6)
                
                let w = pipelineState.threadExecutionWidth
                let h = pipelineState.maxTotalThreadsPerThreadgroup / w
                let X_SLICE_SIZE = 32;
                for xBeg in stride(from: 0, to: res.x, by: X_SLICE_SIZE) {
                    var xBeg = xBeg
                    var xEnd = UInt32(min(res.x, xBeg + X_SLICE_SIZE))
                    commandEncoder.setBytes(&xBeg, length: MemoryLayout<UInt32>.stride, index: 7)
                    commandEncoder.setBytes(&xEnd, length: MemoryLayout<UInt32>.stride, index: 8)
                    
                    commandEncoder.dispatchThreads(MTLSizeMake(1, res.y, res.z),
                                                   threadsPerThreadgroup: MTLSizeMake(1, w, h))
                }
                commandEncoder.endEncoding()
            }
            
            commandBuffer.commit()
        }
    }
    
    // MARK: - Builder
    public class Builder {
        private var _mesh: TriangleMesh?
        private var _resolutionX: Int = 32
        private var _margin: Float = 0.2
        private var _transform = simd_float4x4()
        private var _signRayCount: UInt32 = 12

        /// Returns builder with triangle mesh.
        public func withTriangleMesh(_ mesh: TriangleMesh) -> Builder {
            _mesh = mesh
            return self
        }

        /// Returns builder with resolution in x axis.
        public func withResolutionX(_ resolutionX: Int) -> Builder {
            _resolutionX = resolutionX
            return self
        }

        /// Returns builder with margin around the mesh.
        public func withMargin(_ margin: Float) -> Builder {
            _margin = margin
            return self
        }
        
        /// Returns builder with sign ray count
        public func withSignRayCount(_ signRayCount: UInt32) -> Builder {
            _signRayCount = signRayCount
            return self
        }
        
        /// Returns builder with transform.
        public func withTransform(_ transform: simd_float4x4) -> Builder {
            _transform = transform
            return self
        }
        /// Builds ImplicitTriangleMesh3.
        public func build(_ engine: Engine) -> ImplicitTriangleMesh? {
            if let mesh = _mesh {
                return ImplicitTriangleMesh(engine, mesh: mesh, resolutionX: _resolutionX,
                                            margin: _margin, signRayCount: _signRayCount, transform: _transform)
            } else {
                return nil
            }
        }
    }
}
