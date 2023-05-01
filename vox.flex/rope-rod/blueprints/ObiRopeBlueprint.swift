//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRopeBlueprint: ObiRopeBlueprintBase {
    public var pooledParticles: Int = 100

    public static let DEFAULT_PARTICLE_MASS: Float = 0.1

    func CreateDistanceConstraints() {}
    func CreateBendingConstraints() {}
}
