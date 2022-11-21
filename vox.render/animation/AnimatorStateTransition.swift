//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Transitions define when and how the state machine switch from on state to another.
// AnimatorTransition always originate from a StateMachine or a StateMachine entry.
public class AnimatorStateTransition {
    /// The duration of the transition. This is represented in normalized time.
    public var duration: Float = 0
    /// The time at which the destination state will start. This is represented in normalized time.
    public var offset: Float = 0
    /// ExitTime represents the exact time at which the transition can take effect. This is represented in normalized time.
    public var exitTime: Float = 1
    /// The destination state of the transition.
    public var destinationState: AnimatorState!
}
