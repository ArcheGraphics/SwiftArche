//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// StateMachineScript is a component that can be added to a animator state.
/// It's the base class every script on a state derives from.
class StateMachineScript {
    var _state: AnimatorState!

    required init() {
    }

    deinit {
        _state!._removeStateMachineScript(self)
    }

    /// onStateEnter is called when a transition starts and the state machine starts to evaluate this state.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateEnter(_ animator: Animator, _ animatorState: AnimatorState, _ layerIndex: Int) {
    }

    /// onStateUpdate is called on each Update frame between onStateEnter and onStateExit callbacks.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateUpdate(_ animator: Animator, _ animatorState: AnimatorState, _ layerIndex: Int) {
    }

    /// onStateExit is called when a transition ends and the state machine finishes evaluating this state.
    /// - Parameters:
    ///   - animator: The animator
    ///   - animatorState: The state be evaluated
    ///   - layerIndex: The index of the layer where the state is located
    func onStateExit(_ animator: Animator, _ animatorState: AnimatorState, _ layerIndex: Int) {
    }
}
