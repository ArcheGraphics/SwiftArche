//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiEmitterShape: Script {
    public struct DistributionPoint {
        public var position: Vector3
        public var velocity: Vector3
        public var color: Color

        public init(position: Vector3, velocity: Vector3) {
            self.position = position
            self.velocity = velocity
            color = Color.white
        }

        public init(position: Vector3, velocity: Vector3, color: Color) {
            self.position = position
            self.velocity = velocity
            self.color = color
        }

        public func GetTransformed(transform _: Matrix, multiplyColor _: Color) -> DistributionPoint {
            return DistributionPoint(position: Vector3(), velocity: Vector3())
        }
    }

    var emitter: ObiEmitter?

    public var color = Color.white

    public var particleSize: Float = 0
    public var distribution: [DistributionPoint] = []

    var l2sTransform: Matrix = .init()

    override public func onEnable() {}

    override public func onDisable() {}

    public func UpdateLocalToSolverMatrix() {}

    public func GenerateDistribution() {}
}
