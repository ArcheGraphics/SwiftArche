//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiBoneBlueprint: ObiActorBlueprint {
    public var root: Transform?

    public static let DEFAULT_PARTICLE_MASS: Float = 0.1
    public static let DEFAULT_PARTICLE_ROTATIONAL_MASS: Float = 0.1
    public static let DEFAULT_PARTICLE_RADIUS: Float = 0.05

    public var transforms: [Transform] = []
    public var restTransformOrientations: [Quaternion] = []
    public var parentIndices: [Int] = []
    public var normalizedLengths: [Float] = []

    public var ignored: [ObiBone.IgnoredBone] = []
    public var mass: ObiBone.BonePropertyCurve?
    public var rotationalMass: ObiBone.BonePropertyCurve?
    public var radius: ObiBone.BonePropertyCurve?

    public var root2WorldR = Quaternion()

    private var colorizer: GraphColoring?

    private func GetIgnoredBone(bone _: Transform) -> ObiBone.IgnoredBone {
        ObiBone.IgnoredBone()
    }

    func CreateSimplices() {}

    func CreateStretchShearConstraints(particlePositions _: [Vector3]) {}

    func CreateBendTwistConstraints(particlePositions _: [Vector3]) {}

    func CreateSkinConstraints(particlePositions _: [Vector3]) {}
}
