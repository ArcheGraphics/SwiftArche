//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiParticleGroup {
    public var particleIndices: [Int] = []
    public var m_Blueprint: ObiActorBlueprint?

    public var blueprint: ObiActorBlueprint? {
        return m_Blueprint
    }

    public func SetSourceBlueprint(blueprint: ObiActorBlueprint) {
        m_Blueprint = blueprint
    }

    public var Count: Int
    { return particleIndices.count }

    public func ContainsParticle(index: Int) -> Bool {
        return particleIndices.contains(index)
    }
}
