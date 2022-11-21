//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// States are the basic building blocks of a state machine. Each state contains a AnimationClip which will play while the character is in that state.
class AnimatorState {
    /// The speed of the clip. 1 is normal speed, default 1.
    var speed: Float = 1.0
    /// The wrap mode used in the state.
    var wrapMode: WrapMode = WrapMode.Loop
    /// The state's name
    var name: String

    internal var _onStateEnterScripts: [StateMachineScript] = []
    internal var _onStateUpdateScripts: [StateMachineScript] = []
    internal var _onStateExitScripts: [StateMachineScript] = []

    private var _clipStartTime: Float = 0
    private var _clipEndTime: Float = Float.greatestFiniteMagnitude
    private var _clip: AnimationClip!
    private var _transitions: [AnimatorStateTransition] = []

    /// The transitions that are going out of the state.
    var transitions: [AnimatorStateTransition] {
        get {
            _transitions
        }
    }

    /// The clip that is being played by this animator state.
    var clip: AnimationClip? {
        get {
            _clip
        }
        set {
            _clip = newValue
            _clipEndTime = min(_clipEndTime, newValue!.length)
        }
    }

    /// The clip start time the user set , default is 0.
    var clipStartTime: Float {
        get {
            _clipStartTime
        }
        set {
            _clipStartTime = newValue < 0 ? 0 : newValue
        }
    }

    /// The clip end time the user set , default is the clip duration.
    var clipEndTime: Float {
        get {
            _clipEndTime
        }
        set {
            if (_clip != nil) {
                _clipEndTime = min(newValue, _clip!.length)
            }
        }
    }

    /// constructor
    /// - Parameter name: The state's name
    init(_ name: String) {
        self.name = name
    }

    /// Add an outgoing transition to the destination state.
    /// - Parameter transition: The transition
    func addTransition(_ transition: AnimatorStateTransition) {
        _transitions.append(transition)
    }

    /// Remove a transition from the state.
    /// - Parameter transition: The transition
    func removeTransition(_ transition: AnimatorStateTransition) {
        _transitions.removeAll { t in
            t === transition
        }
    }

    /// Adds a state machine script class of type T to the AnimatorState.
    /// - Returns: The state machine script class of type T
    func addStateMachineScript<T: StateMachineScript>(_ scriptType: T.Type) -> T {
        let script = scriptType.init()
        script._state = self

        _onStateEnterScripts.append(script)
        _onStateUpdateScripts.append(script)
        _onStateExitScripts.append(script)

        return script
    }

    /// Clears all transitions from the state.
    func clearTransitions() {
        _transitions = []
    }


    internal func _getDuration() -> Float {
        return _clipEndTime - _clipStartTime
    }

    internal func _removeStateMachineScript(_ script: StateMachineScript) {
        _onStateEnterScripts.removeAll { s in
            s === script
        }
        _onStateUpdateScripts.removeAll { s in
            s === script
        }
        _onStateExitScripts.removeAll { s in
            s === script
        }
    }
}
