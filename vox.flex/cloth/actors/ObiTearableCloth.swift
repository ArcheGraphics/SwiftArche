//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiTearableCloth: ObiClothBase {
    public var m_TearableClothBlueprint: ObiTearableClothBlueprint?
    private var m_TearableBlueprintInstance: ObiTearableClothBlueprint?

    public var tearingEnabled = true
    /// Factor that controls how much a structural cloth spring can stretch before breaking
    public var tearResistanceMultiplier: Float = 1000
    public var tearRate: Int = 1
    public var tearDebilitation: Float = 0.5
}
