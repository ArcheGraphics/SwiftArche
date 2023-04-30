//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol IAerodynamicConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetAerodynamicConstraints(particleIndices: [Int], aerodynamicCoeffs: [Float], count: Int)
}
