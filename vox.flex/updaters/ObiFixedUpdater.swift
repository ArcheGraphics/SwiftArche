//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Updater class that will perform simulation during FixedUpdate(). This is the most physically correct updater,
/// and the one to be used in most cases. Also allows to perform substepping, greatly improving convergence.
public class ObiFixedUpdater: ObiUpdater {
    /// Each FixedUpdate() call will be divided into several substeps. Performing more substeps will greatly improve the accuracy/convergence speed of the simulation.
    /// Increasing the amount of substeps is more effective than increasing the amount of constraint iterations.
    public var substeps = 4

    private var accumulatedTime: Float = 0

    override public func onEnable() {}

    override public func onDisable() {}

    override public func onPhysicsUpdate() {}

    override public func onUpdate(_: Float) {}
}
