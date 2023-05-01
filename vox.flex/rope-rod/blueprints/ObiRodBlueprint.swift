//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRodBlueprint: ObiRopeBlueprintBase {
    public var keepInitialShape = true

    public let DEFAULT_PARTICLE_MASS: Float = 0.1
    public let DEFAULT_PARTICLE_ROTATIONAL_MASS: Float = 0.01

    func CreateStretchShearConstraints(particleNormals _: [Vector3]) {}
    func CreateBendTwistConstraints() {}
    func CreateChainConstraints() {}
}
