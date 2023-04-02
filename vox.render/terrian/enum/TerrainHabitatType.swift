//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum TerrainHabitatType: UInt8 {
    case Sand = 0
    case Grass = 1
    case Rock = 2
    case Snow = 3

    // The number of variations of each type, for added realism
    case COUNT = 4
}
