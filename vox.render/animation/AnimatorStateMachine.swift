//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// A graph controlling the interaction of states. Each state references a motion.
public class AnimatorStateMachine {
    /// The list of states.
    public var states: [AnimatorState] = []

    /// The state will be played automatically.
    /// @remarks When the Animator's AnimatorController changed or the Animator's onEnable be triggered.
    public var defaultState: AnimatorState!

    var _statesMap: [String: AnimatorState] = [:]

    /// Add a state to the state machine.
    /// - Parameter name: The name of the new state
    /// - Returns: new state
    func addState(_ name: String) -> AnimatorState {
        var state = self.findStateByName(name)
        if state == nil {
            state = AnimatorState(name)
            states.append(state!)
            _statesMap[name] = state
        } else {
            logger.warning("The state named \(name) has existed.")
        }
        return state!
    }

    /// Remove a state from the state machine.
    /// - Parameter state: The state
    func removeState(_ state: AnimatorState) {
        let name = state.name
        states.removeAll { s in
            s === state
        }
        _statesMap.removeValue(forKey: name)
    }

    /// Get the state by name.
    /// - Parameter name: The layer's name
    func findStateByName(_ name: String) -> AnimatorState? {
        _statesMap[name]
    }

    /// Makes a unique state name in the state machine.
    /// - Parameter name: Desired name for the state.
    /// - Returns: Unique name.
    func makeUniqueStateName(_ name: inout String) -> String {
        let originName = name
        var index = 0
        while (_statesMap[name] != nil) {
            name = "\(originName) \(index)"
            index += 1
        }
        return name
    }
}
