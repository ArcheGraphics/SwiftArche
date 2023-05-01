//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiEmitterShapeImage: ObiEmitterShape {
    public var pixelScale: Float = 0.05
    public var maxSize: Float = 2

    public var maskThreshold: Float = 0.5

    override public func GenerateDistribution() {}

    private func GetWorldSpaceEmitterSize(width _: inout Float, height _: inout Float) {}
}
