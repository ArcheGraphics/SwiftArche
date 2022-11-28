//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class OrbitControl : Script {
    let canvas: Canvas
    let input: InputManager
    var inputDevices: [IControlInput.Type] = [ControlPointer.self, ControlKeyboard.self, ControlWheel.self]
    var camera: Camera!
    var cameraTransform: Transform!
    
    /** Whether to automatically rotate the camera, the default is false. */
    public  var autoRotate: Bool = false
    /** The radian of automatic rotation per second. */
    public var autoRotateSpeed: Float = .pi
    /** Whether to enable camera damping, the default is true. */
    public var enableDamping: Bool = true
    /** Rotation speed, default is 1.0 . */
    public var rotateSpeed: Float = 1.0
    /** Camera zoom speed, the default is 1.0. */
    public var zoomSpeed: Float = 1.0
    /** Keyboard translation speed, the default is 7.0 . */
    public var keyPanSpeed: Float = 7.0
    /** Rotation damping parameter, default is 0.1 . */
    public var dampingFactor: Float = 0.1
    /** Zoom damping parameter, default is 0.2 . */
    public var zoomFactor: Float = 0.2
    /**  The minimum distance, the default is 0.1, should be greater than 0. */
    public var minDistance: Float = 0.1
    /** The maximum distance, the default is infinite, should be greater than the minimum distance. */
    public var maxDistance: Float = .greatestFiniteMagnitude
    /** Minimum zoom speed, the default is 0.0. */
    public var minZoom: Float = 0.0
    /** Maximum zoom speed, the default is positive infinity. */
    public var maxZoom: Float = .greatestFiniteMagnitude
    /** The minimum radian in the vertical direction, the default is 1 degree. */
    public var minPolarAngle: Float = 1
    /** The maximum radian in the vertical direction,  the default is 179 degree.  */
    public var maxPolarAngle: Float = (179 / 180) * .pi
    /** The minimum radian in the horizontal direction, the default is negative infinity. */
    public var minAzimuthAngle: Float = -.greatestFiniteMagnitude
    /** The maximum radian in the horizontal direction, the default is positive infinity.  */
    public var maxAzimuthAngle: Float = .greatestFiniteMagnitude
    
    private var _enableKeys: Bool = true
    private var _up: Vector3 = Vector3(0, 1, 0)
    private var _target: Vector3 = Vector3()
    private var _atTheBack: Bool = false
    private var _spherical: Spherical = Spherical()
    private var _sphericalDelta: Spherical = Spherical()
    private var _sphericalDump: Spherical = Spherical()
    private var _zoomFrag: Float = 0
    private var _scale: Float = 1
    private var _panOffset: Vector3 = Vector3()
    private var _enableHandler: Int = ControlHandlerType.All.rawValue
    
    /// Return whether to enable keyboard.
    public var enableKeys:Bool {
        get {
            _enableKeys
        }
        set {
            if (_enableKeys != newValue) {
                _enableKeys = newValue
                if (newValue) {
                    inputDevices.append(ControlKeyboard.self)
                } else {
                    for i in 0..<inputDevices.count {
                        if (inputDevices[i] == ControlKeyboard.self) {
                            inputDevices.remove(at: i)
                            break
                        }
                    }
                }
            }
        }
    }
    
    /// Return up vector.
    public var up: Vector3 {
        get {
            _up
        }
        set {
            _up = newValue
            _spherical.setYAxis(newValue)
            _atTheBack = false
        }
    }
    
    /// Return target position.
    public var target:Vector3 {
        get {
            _target
        }
        set {
            _target = newValue
            _atTheBack = false
        }
    }
    
    /// Return Whether to enable rotation, the default is true.
    public var enableRotate:Bool {
        get {
            (_enableHandler & ControlHandlerType.ROTATE.rawValue) != 0
        }
        set {
            if (newValue) {
                _enableHandler |= ControlHandlerType.ROTATE.rawValue
            } else {
                _enableHandler &= ~ControlHandlerType.ROTATE.rawValue
            }
        }
    }
    
    /// Whether to enable camera damping, the default is true.
    public var enableZoom:Bool {
        get {
            (_enableHandler & ControlHandlerType.ZOOM.rawValue) != 0
        }
        set {
            if (newValue) {
                _enableHandler |= ControlHandlerType.ZOOM.rawValue
            } else {
                _enableHandler &= ~ControlHandlerType.ZOOM.rawValue
            }
        }
    }
    
    /// Whether to enable translation, the default is true.
    public var enablePan:Bool {
        get {
            (_enableHandler & ControlHandlerType.PAN.rawValue) != 0
        }
        set {
            if (newValue) {
                _enableHandler |= ControlHandlerType.PAN.rawValue
            } else {
                _enableHandler &= ~ControlHandlerType.PAN.rawValue
            }
        }
    }
    
    public required init(_ entity: Entity) {
        input = entity.engine.inputManager
        canvas = entity.engine.canvas
        super.init(entity)
    }
    
    public override func onAwake() {
        camera = entity.getComponent()
        cameraTransform = entity.transform
        _spherical.setYAxis(_up)
        _atTheBack = false
    }
    
    public override func onUpdate(_ deltaTime: Float) {
        /** Update _sphericalDelta, _scale and _panOffset. */
        _updateInputDelta(deltaTime)
        /** Update camera's transform. */
        _updateTransform()
    }
    
    private func _updateInputDelta(_ deltaTime: Float) {
        var delta = Vector3()
        var curHandlerType:Int = ControlHandlerType.None.rawValue
        for handler in inputDevices {
            let handlerType = handler.onUpdateHandler(input)
            if ((handlerType.rawValue & _enableHandler) != 0) {
                curHandlerType |= handlerType.rawValue
                handler.onUpdateDelta(self, &delta)
                switch (handlerType) {
                case ControlHandlerType.ROTATE:
                    _rotate(delta)
                    break
                case ControlHandlerType.ZOOM:
                    _zoom(delta)
                    break
                case ControlHandlerType.PAN:
                    _pan(delta)
                    break
                default:
                    break
                }
            }
        }
        if (enableDamping) {
            if ((_enableHandler & ControlHandlerType.ZOOM.rawValue) != 0
                && curHandlerType ^ ControlHandlerType.ZOOM.rawValue != 0) {
                _zoomFrag *= 1 - zoomFactor
            }
            if ((_enableHandler & ControlHandlerType.ROTATE.rawValue) != 0
                && curHandlerType ^ ControlHandlerType.ROTATE.rawValue != 0) {
                _sphericalDump.theta *= 1 - dampingFactor
                _sphericalDelta.theta = _sphericalDump.theta
                _sphericalDump.phi *= 1 - dampingFactor
                _sphericalDelta.phi = _sphericalDump.phi
            }
        }
        if (curHandlerType == ControlHandlerType.None.rawValue && autoRotate) {
            let rotateAngle = (autoRotateSpeed / 1000) * deltaTime
            _sphericalDelta.theta -= rotateAngle
        }
    }
    
    private func _rotate(_ delta: Vector3) {
        let radianLeft = ((2 * Float.pi * delta.x) / Float(canvas.bounds.width)) * rotateSpeed
        _sphericalDelta.theta -= radianLeft
        let radianUp = ((2 * Float.pi * delta.y) / Float(canvas.bounds.height)) * rotateSpeed
        _sphericalDelta.phi -= radianUp
        if (enableDamping) {
            _sphericalDump.theta = -radianLeft
            _sphericalDump.phi = -radianUp
        }
    }
    
    private func _zoom(_ delta: Vector3) {
        if (delta.y > 0) {
            _scale /= pow(0.95, zoomSpeed)
        } else if (delta.y < 0) {
            _scale *= pow(0.95, zoomSpeed)
        }
    }
    
    private func _pan(_ delta: Vector3) {
        let height = Float(canvas.bounds.height)
        let targetDistance = Vector3.distance(left: cameraTransform.position, right: target) * (camera.fieldOfView / 2) * (Float.pi / 180)
        let distanceLeft = -2 * delta.x * (targetDistance / height)
        let distanceUp = 2 * delta.y * (targetDistance / height)
        let worldMatrix = cameraTransform.worldMatrix
        var panOffset = _panOffset.internalValue
        panOffset.x += worldMatrix.elements.columns.0[0] * distanceLeft + worldMatrix.elements.columns.1[0] * distanceUp
        panOffset.y += worldMatrix.elements.columns.0[1] * distanceLeft + worldMatrix.elements.columns.1[1] * distanceUp
        panOffset.z += worldMatrix.elements.columns.0[2] * distanceLeft + worldMatrix.elements.columns.1[2] * distanceUp
        _panOffset = Vector3(panOffset)
    }
    
    private func _updateTransform() {
        var _tempVec3 = cameraTransform.position - target
        _ = _spherical.setFromVec3(_tempVec3, atTheBack: _atTheBack)
        _spherical.theta += _sphericalDelta.theta
        _spherical.phi += _sphericalDelta.phi
        _spherical.theta = max(minAzimuthAngle, min(maxAzimuthAngle, _spherical.theta))
        _spherical.phi = max(minPolarAngle, min(maxPolarAngle, _spherical.phi))
        _ = _spherical.makeSafe()
        if (_scale != 1) {
            _zoomFrag = _spherical.radius * (_scale - 1)
        }
        _spherical.radius += _zoomFrag
        _spherical.radius = max(minDistance, min(maxDistance, _spherical.radius))
        _atTheBack = _spherical.setToVec3(&_tempVec3)
        cameraTransform.worldPosition = target.add(right: _panOffset) + _tempVec3
        _tempVec3 = up
        _tempVec3 *= _atTheBack ? -1 : 1
        cameraTransform.lookAt(targetPosition: target, worldUp: _tempVec3)
        /** Reset cache value. */
        _zoomFrag = 0
        _scale = 1
        _ = _sphericalDelta.set(0, 0, 0)
        _ = _panOffset.set(x: 0, y: 0, z: 0)
    }
}
