//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

final class ParticleSystemSolver: ParticleSystemSolverBase {
    private var _radius: Float = 1e-3
    private var _mass: Float = 1e-3
    
    public var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
        }
    }
    
    public var mass: Float {
        get {
            _mass
        }
        set {
            _mass = newValue
        }
    }
    
    public override init(_ entity: Entity, maxLength: UInt32) {
        super.init(entity)
    }
    
    required public init(_ entity: Entity) {
        fatalError("init(_:) has not been implemented")
    }
}
