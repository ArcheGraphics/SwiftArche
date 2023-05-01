//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRopeBlueprintBase: ObiActorBlueprint {
    public var path = ObiPath()
    public var thickness: Float = 0.1

    public var resolution: Float = 1

    var m_InterParticleDistance: Float = 0
    var totalParticles: Int = 0
    var m_RestLength: Float = 0

    public var restLengths: [Float] = []

    func ControlPointAdded(index _: Int) {}

    func ControlPointRenamed(index _: Int) {}

    func ControlPointRemoved(index _: Int) {}

    func CreateSimplices(numSegments _: Int) {}
}
