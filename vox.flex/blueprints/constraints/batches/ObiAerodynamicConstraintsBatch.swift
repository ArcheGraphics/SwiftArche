//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiAerodynamicConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IAerodynamicConstraintsBatchImpl?

    /// 3 floats per constraint: surface area, drag and lift.
    public var aerodynamicCoeffs: [Float] = []

    public init(constraints _: ObiAerodynamicConstraintsData? = nil) {
        super.init()
        implementation = m_BatchImpl
        constraintType = Oni.ConstraintType.Aerodynamics
    }
}
