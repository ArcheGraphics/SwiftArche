//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Base class for updating multiple solvers in parallel.
/// Derive from this class to write your onw updater. This grants you precise control over execution order,
/// as you can choose to update solvers at any point during Unity's update cycle.
public class ObiUpdater: Script {
    /// List of solvers updated by this updater.
    public var solvers: [ObiSolver] = []

    /// Prepares all solvers to begin simulating a new frame. This should be called as soon as possible in the frame,
    /// and guaranteed to be called every frame that will step physics.
    func PrepareFrame() {}

    /// Prepares all solvers to begin simulating a new physics step. This involves
    /// caching some particle data for interpolation, performing collision detection, among other things.
    /// - Parameter stepDeltaTime: Duration (in seconds) of the next step.
    func BeginStep(stepDeltaTime _: Float) {}

    /// Advances the simulation a given amount of time. Note that once BeginStep has been called,
    /// Substep can be called multiple times.
    /// - Parameters:
    ///   - stepDeltaTime: Duration (in seconds) of the substep.
    ///   - substepDeltaTime: substepDeltaTime
    ///   - index: index
    func Substep(stepDeltaTime _: Float, substepDeltaTime _: Float, index _: Int) {}

    /// Wraps up the current simulation step. This will trigger contact callbacks.
    func EndStep(substepDeltaTime _: Float) {}

    /// Interpolates the previous and current physics states. Should be called right before rendering the current frame.
    /// - Parameters:
    ///   - stepDeltaTime: Duration (in seconds) of the last step taken.
    ///   - accumulatedTime: Amount of accumulated (not yet simulated) time.
    func Interpolate(stepDeltaTime _: Float, accumulatedTime _: Float) {}
}
