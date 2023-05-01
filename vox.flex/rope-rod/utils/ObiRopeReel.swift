//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRopeReel: Script {
    private var cursor: ObiRopeCursor?
    private var rope: ObiRope?

    // Roll out/in thresholds
    public var outThreshold: Float = 0.8
    public var inThreshold: Float = 0.4

    // Roll out/in speeds
    public var outSpeed: Float = 0.05
    public var inSpeed: Float = 0.15

    override public func onAwake() {}

    override public func onUpdate(_: Float) {}
}
