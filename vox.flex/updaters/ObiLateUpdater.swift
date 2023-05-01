//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Updater class that will perform simulation during LateUpdate(). This is highly unphysical and should be avoided whenever possible.
/// This updater does not make any accuracy guarantees when it comes to two-way coupling with rigidbodies.
/// It is only provided for the odd case when there's no way to perform simulation with a fixed timestep.
/// If in doubt, use the ObiFixedUpdater component instead.
public class ObiLateUpdater: ObiUpdater {
    /// Smoothing factor fo the timestep (smoothDelta). Values closer to 1 will yield stabler simulation, but it will be off-sync with rendering.
    public var deltaSmoothing: Float = 0.95

    /// Target timestep used to advance the simulation. The updater will interpolate this value with Time.deltaTime to find the actual timestep used for each frame.
    private var smoothDelta: Float = 0.02

    /// Each FixedUpdate() call will be divided into several substeps. Performing more substeps will greatly improve the accuracy/convergence speed of the simulation.
    /// Increasing the amount of substeps is more effective than increasing the amount of constraint iterations.
    public var substeps: Int = 4

    override public func onUpdate(_: Float) {}

    override public func onLateUpdate(_: Float) {}
}
