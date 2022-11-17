//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The JointMotor is used to motorize a joint.
public class JointMotor {
    /// The motor will apply a force up to force to achieve targetVelocity.
    var targetVelocity: Float = 0;
    /// The force limit
    var forceLimit: Float = Float.greatestFiniteMagnitude
    /// Gear ration for the motor
    var gearRation: Float = 1.0;
    /// If freeSpin is enabled the motor will only accelerate but never slow down.
    var freeSpin: Bool = false;
}