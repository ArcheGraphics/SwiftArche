//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// The camera's roaming controller, can move up and down, left and right, and rotate the viewing angle.
public class FreeControl : Script {
    let input: InputManager
    var inputDevices: [IControlInput.Type] = [ControlFreeKeyboard.self, ControlFreePointer.self]
    
    /** Movement distance per second, the unit is the unit before MVP conversion. */
    public var movementSpeed: Float = 1.0
    /** Rotate speed. */
    public var rotateSpeed: Float = 1.0
    /** Simulate a ground. */
    public var floorMock: Bool = true
    /** Simulated ground height. */
    public var floorY: Float = 0
    
    private var _cameraTransform: Transform!
    private var _spherical: Spherical = Spherical()
    private var _tempVec: Vector3 = Vector3()
    
    public required init(_ entity: Entity) {
        input = entity.engine.inputManager
        super.init(entity)
        
        _cameraTransform = entity.transform
        _ = _spherical.setFromVec3(Vector3.transformByQuat(v: Vector3(0, 0, -1), quaternion: _cameraTransform.rotationQuaternion))
    }
    
    public override func onUpdate(_ deltaTime: Float) {
        if (enabled == false) {return}
        var curHandlerType:Int = ControlHandlerType.None.rawValue
        for handler in inputDevices{
            let handlerType = handler.onUpdateHandler(input)
            if (handlerType != .None) {
                curHandlerType |= handlerType.rawValue
                var delta = Vector3()
                handler.onUpdateDelta(self, &delta)
                switch (handlerType) {
                case ControlHandlerType.ROTATE:
                    _rotate(delta)
                    break
                case ControlHandlerType.PAN:
                    _pan(delta, deltaTime)
                    break
                default:
                    break
                }
            }
        }
        if (floorMock) {
            let position = _cameraTransform.position
            if (position.y != floorY) {
                _cameraTransform.setPosition(x: position.x, y: floorY, z: position.z)
            }
        }
    }
    
    private func _pan(_ moveDelta: Vector3, _ delta: Float) {
        let actualMoveSpeed = (delta / 1000) * movementSpeed
        var moveDelta = moveDelta
        _ = moveDelta.normalize()
        _ = moveDelta.scale(s: actualMoveSpeed)
        _cameraTransform.translate(moveDelta, true)
    }
    
    private func _rotate(_ moveDelta: Vector3) {
        if (moveDelta.x != 0 || moveDelta.y != 0) {
            let canvas = engine.canvas
            let deltaAlpha = (-moveDelta.x * 180) / Float(canvas.bounds.width)
            let deltaPhi = (moveDelta.y * 180) / Float(canvas.bounds.height)
            _spherical.theta += MathUtil.degreeToRadian(deltaAlpha)
            _spherical.phi += MathUtil.degreeToRadian(deltaPhi)
            _ = _spherical.makeSafe()
            _ = _spherical.setToVec3(&_tempVec)
            _cameraTransform.lookAt(targetPosition: _cameraTransform.position + _tempVec, worldUp: Vector3(0, 1, 0))
        }
    }
}
