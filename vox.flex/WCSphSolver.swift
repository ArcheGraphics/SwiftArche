//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public final class WCSphSolver: SphSolverBase {
    // WCSPH solver properties
    private var _eosExponent: Float = 7.0
    
    public var eosExponent: Float {
        get {
            _eosExponent
        }
        set {
            _eosExponent = max(newValue, 1.0)
        }
    }
    
    public required init(_ entity: Entity) {
        super.init(entity)
        let sph = SphSystemData(engine, maxLength: ParticleSystemSolverBase.maxLength)
        sph.targetDensity = kWaterDensity
        sph.targetSpacing = 0.1
        sph.relativeKernelRadius = 1.8
        _particleSystemData = sph
    }
}
