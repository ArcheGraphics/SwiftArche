//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

open class ControllerBehavior {
    open func onShapeHit(hit _: ControllerColliderHit) {}

    open func getShapeBehaviorFlags(shape _: ColliderShape) -> ControllerBehaviorFlag {
        []
    }

    public init() {}
}

public struct ControllerBehaviorFlag: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Controller can ride on touched object
    public static let CanRideOnObject = ControllerBehaviorFlag(rawValue: 1 << 0)
    /// Controller should slide on touched object
    public static let Slide = ControllerBehaviorFlag(rawValue: 1 << 1)
}
