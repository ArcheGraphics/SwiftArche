//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum TerrainHabitat_MemberIds: UInt32 {
    case slopeStrength = 0
    case slopeThreshold = 1
    case elevationStrength = 2
    case elevationThreshold = 3
    case specularPower = 4
    case textureScale = 5
    case flipNormal = 6

    case diffSpecTextureArray = 7
    case normalTextureArray = 8
    case COUNT = 9
}
