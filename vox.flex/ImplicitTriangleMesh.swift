//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

class ImplicitTriangleMesh {
    private var _triangleMesh = TriangleMesh()
    private var _engine: Engine
    var lower = SIMD3<Float>()
    var upper = SIMD3<Float>()
    var res = SIMD3<Int>()
    var sdf: MTLTexture?
    
    init(_ engine: Engine) {
        _engine = engine
    }
    
    func load(with filename: String) {
        _triangleMesh.load(filename)
    }
    
    func buildBVH() {
        _triangleMesh.buildBVH(_engine.device)
    }
    
    func generateSDF(lower: SIMD3<Float>,
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
            
        }
    }
}
