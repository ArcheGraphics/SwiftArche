//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiEmitterShapeMesh: ObiEmitterShape {
    public var mesh: ModelMesh?
    public var scale = Vector3.one

    override public func GenerateDistribution() {}
}
