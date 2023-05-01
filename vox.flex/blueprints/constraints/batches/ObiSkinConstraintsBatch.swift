//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiSkinConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: ISkinConstraintsBatchImpl?

    /// skin constraint anchor points, in solver space.
    public var skinPoints: [Vector4] = []

    /// normal vector for each skin constraint, in solver space.
    public var skinNormals: [Vector4] = []

    ///  3 floats per constraint: skin radius, backstop sphere radius, and backstop sphere distance.
    public var skinRadiiBackstop: [Float] = []

    /// one compliance value per skin constraint.
    public var skinCompliance: [Float] = []

    public init(constraints _: ObiSkinConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Skin
        implementation = m_BatchImpl
    }
}
