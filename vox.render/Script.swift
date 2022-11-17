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
    var _onPhysicsUpdateIndex: Int = -1
    var _onPreRenderIndex: Int = -1
    var _onPostRenderIndex: Int = -1
    var _entityScriptsIndex: Int = -1
    var _waitHandlingInValid: Bool = false

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

    /// Called before camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    func onBeginRender(_ camera: Camera) {
    }

    /// Called after camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    func onEndRender(_ camera: Camera) {
    }

    /// Called before physics calculations, the number of times is related to the physical update frequency.
    func onPhysicsUpdate() {
    }

    /// Called when the collision enter.
    /// - Parameter other: ColliderShape
    func onTriggerEnter(_ other: ColliderShape) {
    }

    /// Called when the collision stay.
    /// - Remark: onTriggerStay is called every frame while the collision stay.
    /// - Parameter other:ColliderShape
    func onTriggerExit(_ other: ColliderShape) {
    }

    /// Called when the collision exit.
    /// - Parameter other: ColliderShape
    func onTriggerStay(_ other: ColliderShape) {
    }

    /// Called when the collision enter.
    /// - Parameter other: ColliderShape
    func onCollisionEnter(_ other: ColliderShape) {
    }

    /// Called when the collision stay.
    /// - Remark: onTriggerStay is called every frame while the collision stay.
    /// - Parameter other: ColliderShape
    func onCollisionExit(_ other: ColliderShape) {
    }

    /// Called when the collision exit.
    /// - Parameter other: ColliderShape
    func onCollisionStay(_ other: ColliderShape) {
    }

    /// Called when the pointer is down while over the ColliderShape.
    /// - Parameter pointer: The pointer that triggered
    func onPointerDown(_ pointer: Pointer) {
    }

    /// Called when the pointer is up while over the ColliderShape.
    /// - Parameter pointer: The pointer that triggered
    func onPointerUp(_ pointer: Pointer) {
    }

    /// Called when the pointer is down and up with the same collider.
    /// - Parameter pointer: The pointer that triggered
    func onPointerClick(_ pointer: Pointer) {
    }

    /// Called when the pointer is enters the ColliderShape.
    /// - Parameter pointer: The pointer that triggered
    func onPointerEnter(_ pointer: Pointer) {
    }

    /// Called when the pointer is no longer over the ColliderShape.
    /// - Parameter pointer: The pointer that triggered
    func onPointerExit(_ pointer: Pointer) {
    }

    /// - Remark: onPointerDrag is called every frame while the pointer is down.
    /// Called when the pointer is down while over the ColliderShape and is still holding down.
    /// - Parameter pointer: The pointer that triggered
    func onPointerDrag(_ pointer: Pointer) {
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
            _waitHandlingInValid = false
        } else {
            let componentsManager = engine._componentsManager
            if (!_started) {
                componentsManager.addOnStartScript(self)
            }
            componentsManager.addOnUpdateScript(self)
            _entity._addScript(self)
        }
        onEnable()
    }

    override func _onDisable() {
        _waitHandlingInValid = true
        _engine._componentsManager.addDisableScript(component: self)
        onDisable()
    }

    override func _onDestroy() {
        _engine._componentsManager.addDestroyScript(component: self)
    }

    func _handlingInValid() {
        let componentsManager = engine._componentsManager
        componentsManager.removeOnUpdateScript(self)

        _entity._removeScript(self)
        _waitHandlingInValid = false
    }
}
