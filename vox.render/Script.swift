//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Script class, used for logic writing.
public class Script: Component {
    var _started: Bool = false
    var _onStartIndex: Int = -1
    var _onUpdateIndex: Int = -1
    var _onLateUpdateIndex: Int = -1
    var _onPhysicsUpdateIndex: Int = -1;
    var _onPreRenderIndex: Int = -1
    var _onPostRenderIndex: Int = -1
    var _entityScriptsIndex: Int = -1;
    var _waitHandlingInValid: Bool = false;

    /// Called when be enabled first time, only once.
    public func onAwake() {
    }

    /// Called when be enabled.
    public func onEnable() {
    }

    /// Called before the frame-level loop start for the first time, only once.
    public func onStart() {
    }

    /// The main loop, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    public func onUpdate(_ deltaTime: Float) {
    }

    /// Called after the onUpdate finished, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    public func onLateUpdate(_ deltaTime: Float) {
    }

    /// Called when be disabled.
    public func onDisable() {
    }

    /// Called at the end of the destroyed frame.
    public func onDestroy() {
    }

    override func _onAwake() {
        onAwake()
    }

    override func _onEnable() {
        if (_waitHandlingInValid) {
            _waitHandlingInValid = false;
        } else {
            let componentsManager = engine._componentsManager
            if (!_started) {
                componentsManager.addOnStartScript(self)
            }
            componentsManager.addOnUpdateScript(self)
            componentsManager.addOnLateUpdateScript(self)
            _entity._addScript(self)
        }
        onEnable()
    }

    override func _onDisable() {
        _waitHandlingInValid = true;
        _engine._componentsManager.addDisableScript(component: self);
        onDisable()
    }

    override func _onDestroy() {
        _engine._componentsManager.addDestroyScript(component: self);
    }

    func _handlingInValid() {
        let componentsManager = engine._componentsManager;
        componentsManager.removeOnUpdateScript(self);
        componentsManager.removeOnLateUpdateScript(self);

        _entity._removeScript(self);
        _waitHandlingInValid = false;
    }
}
