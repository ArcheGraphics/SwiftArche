//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IStructuralConstraintBatch {
    func GetRestLength(at index: Int) -> Float
    func SetRestLength(at index: Int, restLength: Float)
    func GetParticleIndices(at index: Int) -> ParticlePair
}
