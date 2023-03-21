//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#if os(iOS)
import ARKit
#endif
import Metal

/// Script class, used for logic writing.
open class Script: Component {
    var _started: Bool = false
    var _onStartIndex: Int = -1
    var _onUpdateIndex: Int = -1
    var _onPhysicsUpdateIndex: Int = -1
    var _onPreRenderIndex: Int = -1
    var _onPostRenderIndex: Int = -1
    var _onGUIIndex: Int = -1
    var _entityScriptsIndex: Int = -1
    var _waitHandlingInValid: Bool = false

    /// Called when be enabled first time, only once.
    open func onAwake() {
    }

    /// Called when be enabled.
    open func onEnable() {
    }

    /// Called before the frame-level loop start for the first time, only once.
    open func onStart() {
    }

    /// The main loop, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    open func onUpdate(_ deltaTime: Float) {
    }

    /// Called after the onUpdate finished, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    open func onLateUpdate(_ deltaTime: Float) {
    }

#if os(iOS)
    /// Called after the onLateUpdate finished, called frame by frame.
    /// - Parameter deltaTime: The deltaTime when the script update.
    /// - Parameter frame: The ARFrame when the script update.
    open func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
    }
#endif

    /// Called before camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    /// - Parameter commandBuffer: Current commandBuffer.
    open func onBeginRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
    }

    /// Called after camera rendering, called per camera.
    /// - Parameter camera: Current camera.
    /// - Parameter commandBuffer: Current commandBuffer.
    open func onEndRender(_ camera: Camera, _ commandBuffer: MTLCommandBuffer) {
    }

    /// Called before physics calculations, the number of times is related to the physical update frequency.
    open func onPhysicsUpdate() {
    }

    /// Called when the collision enter.
    /// - Parameter other: ColliderShape
    open func onTriggerEnter(_ other: ColliderShape) {
    }

    /// Called when the collision stay.
    /// - Remark: onTriggerStay is called every frame while the collision stay.
    /// - Parameter other:ColliderShape
    open func onTriggerExit(_ other: ColliderShape) {
    }

    /// Called when the collision exit.
    /// - Parameter other: ColliderShape
    open func onTriggerStay(_ other: ColliderShape) {
    }

    /// Called when the collision enter.
    /// - Parameter other: ColliderShape
    open func onCollisionEnter(_ other: Collision) {
    }

    /// Called when the collision stay.
    /// - Remark: onTriggerStay is called every frame while the collision stay.
    /// - Parameter other: ColliderShape
    open func onCollisionExit(_ other: Collision) {
    }

    /// Called when the collision exit.
    /// - Parameter other: ColliderShape
    open func onCollisionStay(_ other: Collision) {
    }

    /// Called when the pointer is casted while over the ColliderShape.
    ///   - hitResult: The pointer hit result
    ///   - type: The event type depend on platform (NSEvent.type or UITouch.phase)
    open func onPointerCast(_ hitResult: HitResult, _ type: UInt) {
    }
    
    open func onGUI() {
    }

    /// Called when be disabled.
    open func onDisable() {
    }

    /// Called at the end of the destroyed frame.
    open func onDestroy() {
    }

    override func _onAwake() {
        onAwake()
    }

    override func _onEnable() {
        if (_waitHandlingInValid) {
            _waitHandlingInValid = false
        } else {
            let componentsManager = Engine._componentsManager
            if (!_started) {
                componentsManager.addOnStartScript(self)
            }
            componentsManager.addOnUpdateScript(self)
#if os(iOS)
            Engine.arManager?.addOnUpdateScript(self)
#endif
#if os(macOS)
            Engine._guiManager.addOnGUIScript(self)
#endif
            _entity._addScript(self)
        }
        onEnable()
    }

    override func _onDisable() {
        _waitHandlingInValid = true
        Engine._componentsManager.addDisableScript(component: self)
#if os(macOS)
        Engine._guiManager.removeOnGUIScript(self)
#endif
        onDisable()
    }

    override func _onDestroy() {
        Engine._componentsManager.addDestroyScript(component: self)
    }

    func _handlingInValid() {
        Engine._componentsManager.removeOnUpdateScript(self)
#if os(iOS)
        Engine.arManager?.removeOnUpdateScript(self)
#endif
        _entity._removeScript(self)
        _waitHandlingInValid = false
    }
}
