//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

open class ParticleEmitter : ComputePass {
    var _target: ParticleSystemData?
    public var isEnabled: Bool = true
    
    public var target: ParticleSystemData? {
        get {
            _target
        }
        set {
            _target = newValue
            if let target = _target {
                data.append(target)
            }
        }
    }
 
    /// Updates the emitter state from \p currentTimeInSeconds to the following time-step.
    open func update(_ commandEncoder: MTLComputeCommandEncoder,
                     currentTimeInSeconds: Float, timeIntervalInSeconds: Float) {}
    
    func createRandomTexture(_ device: MTLDevice, _ size: Int) -> MTLTexture {
        let desc = MTLTextureDescriptor()
        desc.width = size
        desc.textureType = .type1D
        desc.pixelFormat = .rg32Float
        desc.usage = .shaderRead
        let texture = device.makeTexture(descriptor: desc)!
        updateRandomTexture(texture)
        return texture
    }
    
    func updateRandomTexture(_ texture: MTLTexture) {
        let size = texture.width
        var buffer: [SIMD2<Float>] = []
        buffer.reserveCapacity(size)
        for _ in 0..<size {
            buffer.append(SIMD2<Float>(Float.random(in: 0..<1), Float.random(in: 0..<1)))
        }
        texture.replace(region: MTLRegionMake1D(0, size), mipmapLevel: 0, withBytes: buffer,
                        bytesPerRow: MemoryLayout<SIMD2<Float>>.stride * size)
    }
}
