//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Abstracts rope topolgy as a list of elements.
public class ObiStructuralElement {
    public var particle1: Int = 0
    public var particle2: Int = 0
    public var restLength: Float = 0
    public var constraintForce: Float = 0
    public var tearResistance: Float = 0
}
