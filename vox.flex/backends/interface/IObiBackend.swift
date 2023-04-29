//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Base class for backend implementations.
public protocol IObiBackend {
    func CreateSolver(_ solver: ObiSolver, capacity: Int) -> ISolverImpl
    func DestroySolver(_ solver: ISolverImpl)
}
