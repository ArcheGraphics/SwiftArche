//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol IConstraintsBatchImpl {
    var constraintType: Oni.ConstraintType {
        get
    }

    var constraints: IConstraints {
        get
    }

    var enabled: Bool {
        set
        get
    }

    func Destroy()
    func SetConstraintCount(constraintCount: Int)
    func GetConstraintCount() -> Int
}
