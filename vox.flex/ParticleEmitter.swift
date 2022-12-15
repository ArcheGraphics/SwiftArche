//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

open class ParticleEmitter : ComputePass {
    private var _target: ParticleSystemData?
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
}
