//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class VolumeParticleEmitter: ParticleEmitter {
    private var _jitter: Float = 0

    public var implicitSurface: ImplicitTriangleMesh?
    public var maxRegion = BoundingBox3F()
    public var spacing: Float = 0
    public var initialVelocity = Vector3F()
    public var linearVelocity = Vector3F()
    public var angularVelocity = Vector3F()
    public var maxNumberOfParticles: Int = 0
    public var isOneShot: Bool = false
    public var allowOverlapping: Bool = false

    public var jitter: Float {
        get {
            _jitter
        }
        set {
            _jitter = simd_clamp(newValue, 0.0, 1.0)
        }
    }
    
    public override init(_ engine: Engine) {
        super.init(engine)
        shader.append(ShaderPass(engine.library("flex.shader"), "grid_point_generator"))
    }

    public override func update(_ commandEncoder: MTLComputeCommandEncoder,
                                currentTimeInSeconds: Float, timeIntervalInSeconds: Float) {
        if let target = target {
            if (!isEnabled) {
                return
            }
            emit(commandEncoder, target)
            
            if isOneShot {
                isEnabled = false
            }
        }
    }
    
    private func emit(_ commandEncoder: MTLComputeCommandEncoder,
                      _ target: ParticleSystemData) {
        if let implicitSurface = implicitSurface,
           let sdf = implicitSurface.sdf {
            defaultShaderData.setImageView("", "", sdf)
            
            let region = maxRegion
            let boxWidth = region.width
            let boxHeight = region.height
            let boxDepth = region.depth
            threadsPerGridX = Int(boxWidth / spacing)
            threadsPerGridY = Int(boxHeight / spacing)
            threadsPerGridZ = Int(boxDepth / spacing)
            compute(commandEncoder: commandEncoder)
        }
    }
}
