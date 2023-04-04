//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import Math

/// Used to implement transformation related functions.
public class Transform: Component {
    @Serialized("position", default: Vector3())
    private var _position: Vector3
    @Serialized("rotation", default: Quaternion())
    private var _rotationQuaternion: Quaternion
    @Serialized("scale", default: Vector3(1, 1, 1))
    private var _scale: Vector3

    private var _rotation: Vector3 = .init()
    private var _worldPosition: Vector3 = .init()
    private var _worldRotation: Vector3 = .init()
    private var _worldRotationQuaternion: Quaternion = .init()
    private var _lossyWorldScale: Vector3 = .init(1, 1, 1)
    private var _localMatrix: Matrix = .init()
    private var _worldMatrix: Matrix = .init()
    private var _isParentDirty: Bool = true
    private var _parentTransformCache: Transform? = nil
    private var _dirtyFlag: Int = TransformModifyFlags.WmWpWeWqWs.rawValue

    var _updateFlagManager: UpdateFlagManager = .init()
}

// MARK: - Get/Set Property

public extension Transform {
    /// Get the forward direction in world space.
    var worldForward: Vector3 {
        let e = worldMatrix.elements
        return Vector3(-e.columns.2[0], -e.columns.2[1], -e.columns.2[2]).normalized
    }

    /// Get the right direction in world space.
    var worldRight: Vector3 {
        let e = worldMatrix.elements
        return Vector3(e.columns.0[0], e.columns.0[1], e.columns.0[2]).normalized
    }

    /// Get the up direction in world space.
    var worldUp: Vector3 {
        let e = worldMatrix.elements
        return Vector3(e.columns.1[0], e.columns.1[1], e.columns.1[2]).normalized
    }

    /// Local position.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var position: Vector3 {
        get {
            _position
        }
        set {
            _position = newValue
            _setDirtyFlagTrue(TransformModifyFlags.LocalMatrix.rawValue)
            _updateWorldPositionFlag()
        }
    }

    /// World position.
    /// - Remark:  Need to re-assign after modification to ensure that the modification takes effect.
    var worldPosition: Vector3 {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.WorldPosition.rawValue) {
                if _getParentTransform() != nil {
                    _worldPosition = worldMatrix.getTranslation()
                } else {
                    _worldPosition = _position
                }
                _setDirtyFlagFalse(TransformModifyFlags.WorldPosition.rawValue)
            }
            return _worldPosition
        }
        set {
            _worldPosition = newValue
            let parent = _getParentTransform()
            if parent != nil {
                let _tempMat41 = Matrix.invert(a: parent!.worldMatrix)
                _position = Vector3.transformCoordinate(v: newValue, m: _tempMat41)
            } else {
                _position = newValue
            }
            position = _position
            _setDirtyFlagFalse(TransformModifyFlags.WorldPosition.rawValue)
        }
    }

    /// Local rotation, defining the rotation value in degrees.
    /// Rotations are performed around the Y axis, the X axis, and the Z axis, in that order.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect
    var rotation: Vector3 {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.LocalEuler.rawValue) {
                _rotation = _rotationQuaternion.toEuler()
                _rotation *= MathUtil.radToDegreeFactor // radians to degrees
                _setDirtyFlagFalse(TransformModifyFlags.LocalEuler.rawValue)
            }
            return _rotation
        }
        set {
            _rotation = newValue
            _setDirtyFlagTrue(TransformModifyFlags.LocalMatrix.rawValue | TransformModifyFlags.LocalQuat.rawValue)
            _setDirtyFlagFalse(TransformModifyFlags.LocalEuler.rawValue)
            _updateWorldRotationFlag()
        }
    }

    /// World rotation, defining the rotation value in degrees.
    /// Rotations are performed around the Y axis, the X axis, and the Z axis, in that order.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldRotation: Vector3 {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.WorldEuler.rawValue) {
                _worldRotation = worldRotationQuaternion.toEuler()
                _worldRotation *= MathUtil.radToDegreeFactor // Radian to angle
                _setDirtyFlagFalse(TransformModifyFlags.WorldEuler.rawValue)
            }
            return _worldRotation
        }
        set {
            _worldRotation = newValue
            _worldRotationQuaternion = Quaternion.rotationEuler(
                x: MathUtil.degreeToRadian(newValue.x),
                y: MathUtil.degreeToRadian(newValue.y),
                z: MathUtil.degreeToRadian(newValue.z)
            )
            worldRotationQuaternion = _worldRotationQuaternion
            _setDirtyFlagFalse(TransformModifyFlags.WorldEuler.rawValue)
        }
    }

    /// Local rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var rotationQuaternion: Quaternion {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.LocalQuat.rawValue) {
                _rotationQuaternion = Quaternion.rotationEuler(
                    x: MathUtil.degreeToRadian(_rotation.x),
                    y: MathUtil.degreeToRadian(_rotation.y),
                    z: MathUtil.degreeToRadian(_rotation.z)
                )
                _setDirtyFlagFalse(TransformModifyFlags.LocalQuat.rawValue)
            }
            return _rotationQuaternion
        }
        set {
            _rotationQuaternion = newValue
            _setDirtyFlagTrue(TransformModifyFlags.LocalMatrix.rawValue | TransformModifyFlags.LocalEuler.rawValue)
            _setDirtyFlagFalse(TransformModifyFlags.LocalQuat.rawValue)
            _updateWorldRotationFlag()
        }
    }

    /// World rotation, defining the rotation by using a unit quaternion.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldRotationQuaternion: Quaternion {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.WorldQuat.rawValue) {
                let parent = _getParentTransform()
                if parent != nil {
                    _worldRotationQuaternion = parent!.worldRotationQuaternion * rotationQuaternion
                } else {
                    _worldRotationQuaternion = rotationQuaternion
                }
                _setDirtyFlagFalse(TransformModifyFlags.WorldQuat.rawValue)
            }
            return _worldRotationQuaternion
        }
        set {
            _worldRotationQuaternion = newValue
            let parent = _getParentTransform()
            if parent != nil {
                let invParentQuaternion = parent!.worldRotationQuaternion.invert
                _rotationQuaternion = invParentQuaternion * newValue
            } else {
                _rotationQuaternion = newValue
            }
            rotationQuaternion = _rotationQuaternion
            _setDirtyFlagFalse(TransformModifyFlags.WorldQuat.rawValue)
        }
    }

    /// Local scaling.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var scale: Vector3 {
        get {
            _scale
        }
        set {
            _scale = newValue
            _setDirtyFlagTrue(TransformModifyFlags.LocalMatrix.rawValue)
            _updateWorldScaleFlag()
        }
    }

    /// Local lossy scaling.
    /// - Remark: The value obtained may not be correct under certain conditions(for example, the parent node has scaling,
    /// and the child node has a rotation), the scaling will be tilted. Vector3 cannot be used to correctly represent the scaling. Must use Matrix3x3.
    var lossyWorldScale: Vector3 {
        if _isContainDirtyFlag(TransformModifyFlags.WorldScale.rawValue) {
            if _getParentTransform() != nil {
                let scaleMat = _getScaleMatrix()
                let e = scaleMat.elements
                _lossyWorldScale = Vector3(e.columns.0[0], e.columns.1[1], e.columns.2[2])
            } else {
                _lossyWorldScale = _scale
            }
            _setDirtyFlagFalse(TransformModifyFlags.WorldScale.rawValue)
        }
        return _lossyWorldScale
    }

    /// Local matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var localMatrix: Matrix {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.LocalMatrix.rawValue) {
                _localMatrix = Matrix.affineTransformation(scale: _scale, rotation: rotationQuaternion, translation: _position)
                _setDirtyFlagFalse(TransformModifyFlags.LocalMatrix.rawValue)
            }
            return _localMatrix
        }
        set {
            _localMatrix = newValue
            _ = _localMatrix.decompose(translation: &_position, rotation: &_rotationQuaternion, scale: &_scale)
            position = _position
            rotationQuaternion = _rotationQuaternion
            scale = _scale
            _setDirtyFlagTrue(TransformModifyFlags.LocalEuler.rawValue)
            _setDirtyFlagFalse(TransformModifyFlags.LocalMatrix.rawValue)
            _updateAllWorldFlag()
        }
    }

    /// World matrix.
    /// - Remark: Need to re-assign after modification to ensure that the modification takes effect.
    var worldMatrix: Matrix {
        get {
            if _isContainDirtyFlag(TransformModifyFlags.WorldMatrix.rawValue) {
                let parent = _getParentTransform()
                if parent != nil {
                    _worldMatrix = parent!.worldMatrix * localMatrix
                } else {
                    _worldMatrix = localMatrix
                }
                _setDirtyFlagFalse(TransformModifyFlags.WorldMatrix.rawValue)
            }
            return _worldMatrix
        }
        set {
            _worldMatrix = newValue
            let parent = _getParentTransform()
            if parent != nil {
                _localMatrix = Matrix.invert(a: parent!.worldMatrix) * newValue
            } else {
                _localMatrix = newValue
            }
            localMatrix = _localMatrix
            _setDirtyFlagFalse(TransformModifyFlags.WorldMatrix.rawValue)
        }
    }
}

// MARK: - Public Methods

public extension Transform {
    /// Translate along the passed Vector3.
    /// - Parameters:
    ///   - translation: Direction and distance of translation
    ///   - relativeToLocal: Relative to local space
    func translate(_ translation: Vector3, _ relativeToLocal: Bool = true) {
        _translate(translation, relativeToLocal)
    }

    /// Translate along the passed X, Y, Z value.
    /// - Parameters:
    ///   - x: Translate direction and distance along x axis
    ///   - y: Translate direction and distance along y axis
    ///   - z: Translate direction and distance along z axis
    ///   - relativeToLocal: Relative to local space
    func translate(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool = true) {
        _translate(Vector3(x, y, z), relativeToLocal)
    }

    /// Rotate around the passed Vector3.
    /// - Parameters:
    ///   - rotation: Euler angle in degrees
    ///   - relativeToLocal: Relative to local space
    func rotate(_ rotation: Vector3, _ relativeToLocal: Bool = true) {
        _rotateXYZ(rotation.x, rotation.y, rotation.z, relativeToLocal)
    }

    /// Rotate around the passed Vector3.
    /// - Parameters:
    ///   - x: Rotation along x axis, in degrees
    ///   - y: Rotation along y axis, in degrees
    ///   - z: Rotation along z axis, in degrees
    ///   - relativeToLocal: Relative to local space
    func rotate(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool = true) {
        _rotateXYZ(x, y, z, relativeToLocal)
    }

    /// Rotate around the specified axis according to the specified angle.
    /// - Parameters:
    ///   - axis: Rotate axis
    ///   - angle: Rotate angle in degrees
    ///   - relativeToLocal: Relative to local space
    func rotateByAxis(axis: Vector3, angle: Float, relativeToLocal: Bool = true) {
        let _tempQuat0 = Quaternion(axis: axis, rad: angle * MathUtil.degreeToRadFactor)
        _rotateByQuat(_tempQuat0, relativeToLocal)
    }

    /// Rotate and ensure that the world front vector points to the target world position.
    /// - Parameters:
    ///   - targetPosition: Target world position
    ///   - worldUp: Up direction in world space, default is Vector3(0, 1, 0)
    func lookAt(targetPosition: Vector3, worldUp: Vector3? = nil) {
        var zAxis = worldPosition - targetPosition
        var axisLen = zAxis.length()
        if axisLen <= MathUtil.zeroTolerance {
            // The current position and the target position are almost the same.
            return
        }
        zAxis /= axisLen
        var xAxis = Vector3()
        if worldUp != nil {
            xAxis = Vector3.cross(left: worldUp!, right: zAxis)
        } else {
            xAxis = Vector3(zAxis.z, 0, -zAxis.x)
        }
        axisLen = xAxis.length()
        if axisLen <= MathUtil.zeroTolerance {
            // @todo:
            // 1.worldUp is（0,0,0）
            // 2.worldUp is parallel to zAxis
            return
        }
        xAxis /= axisLen
        let yAxis = Vector3.cross(left: zAxis, right: xAxis)

        var rotMat = Matrix()
        rotMat.elements.columns.0[0] = xAxis.x
        rotMat.elements.columns.0[1] = xAxis.y
        rotMat.elements.columns.0[2] = xAxis.z

        rotMat.elements.columns.1[0] = yAxis.x
        rotMat.elements.columns.1[1] = yAxis.y
        rotMat.elements.columns.1[2] = yAxis.z

        rotMat.elements.columns.2[0] = zAxis.x
        rotMat.elements.columns.2[1] = zAxis.y
        rotMat.elements.columns.2[2] = zAxis.z
        worldRotationQuaternion = rotMat.getRotation()
    }

    /// Register world transform change flag.
    /// - Returns: Change flag
    func registerWorldChangeFlag() -> BoolUpdateFlag {
        let flag = BoolUpdateFlag()
        _updateFlagManager.addFlag(flag: flag)
        return flag
    }
}

// MARK: - Private Methods

extension Transform {
    internal func _parentChange() {
        _isParentDirty = true
        _updateAllWorldFlag()
    }

    internal func _isFrontFaceInvert() -> Bool {
        let scale = lossyWorldScale
        var isInvert = scale.x < 0
        if scale.y < 0 {
            isInvert = !isInvert
        }
        if scale.z < 0 {
            isInvert = !isInvert
        }
        return isInvert
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldPositionFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWp.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWp.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateWorldPositionFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldRotationQuaternion: Will trigger the world rotation (in quaternion) update of itself and all parent entities.
    /// Get worldRotation: Will trigger the world rotation(in euler and quaternion) update of itself and world rotation(in quaternion) update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldRotationFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWeWq.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWeWq.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateWorldPositionAndRotationFlag() // Rotation update of parent entity will trigger world position and rotation update of all child entity.
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldRotationQuaternion: Will trigger the world rotation (in quaternion) update of itself and all parent entities.
    /// Get worldRotation: Will trigger the world rotation(in euler and quaternion) update of itself and world rotation(in quaternion) update of all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix or worldRotationQuaternion) to be false.
    private func _updateWorldPositionAndRotationFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWpWeWq.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWpWeWq.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateWorldPositionAndRotationFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldScale: Will trigger the scaling update of itself and all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix) to be false.
    private func _updateWorldScaleFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWs.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateWorldPositionAndScaleFlag()
            }
        }
    }

    /// Get worldMatrix: Will trigger the worldMatrix update of itself and all parent entities.
    /// Get worldPosition: Will trigger the worldMatrix, local position update of itself and the worldMatrix update of all parent entities.
    /// Get worldScale: Will trigger the scaling update of itself and all parent entities.
    /// In summary, any update of related variables will cause the dirty mark of one of the full process (worldMatrix) to be false.
    private func _updateWorldPositionAndScaleFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWpWs.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWpWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateWorldPositionAndScaleFlag()
            }
        }
    }

    /// Update all world transform property dirty flag, the principle is the same as above.
    private func _updateAllWorldFlag() {
        if !_isContainDirtyFlags(TransformModifyFlags.WmWpWeWqWs.rawValue) {
            _worldAssociatedChange(TransformModifyFlags.WmWpWeWqWs.rawValue)
            let nodeChildren = _entity._children
            for i in 0 ..< nodeChildren.count {
                nodeChildren[i].transform._updateAllWorldFlag()
            }
        }
    }

    private func _getParentTransform() -> Transform? {
        if !_isParentDirty {
            return _parentTransformCache
        }
        var parentCache: Transform?
        var parent = _entity.parent
        while parent != nil {
            let transform = parent!.transform
            if transform != nil {
                parentCache = transform
                break
            } else {
                parent = parent!.parent
            }
        }
        _parentTransformCache = parentCache
        _isParentDirty = false
        return parentCache
    }

    private func _getScaleMatrix() -> Matrix3x3 {
        let invRotation = worldRotationQuaternion.invert
        let invRotationMat = Matrix3x3.rotationQuaternion(quaternion: invRotation)
        return invRotationMat * Matrix3x3(worldMatrix)
    }

    private func _isContainDirtyFlags(_ targetDirtyFlags: Int) -> Bool {
        (_dirtyFlag & targetDirtyFlags) == targetDirtyFlags
    }

    private func _isContainDirtyFlag(_ type: Int) -> Bool {
        (_dirtyFlag & type) != 0
    }

    private func _setDirtyFlagTrue(_ type: Int) {
        _dirtyFlag |= type
    }

    private func _setDirtyFlagFalse(_ type: Int) {
        _dirtyFlag &= ~type
    }

    private func _worldAssociatedChange(_ type: Int) {
        _dirtyFlag |= type
        _updateFlagManager.dispatch(type: TransformModifyFlags.WorldMatrix.rawValue)
    }

    private func _rotateByQuat(_ rotateQuat: Quaternion, _ relativeToLocal: Bool) {
        if relativeToLocal {
            _rotationQuaternion = rotationQuaternion * rotateQuat
            rotationQuaternion = _rotationQuaternion
        } else {
            _worldRotationQuaternion = worldRotationQuaternion * rotateQuat
            worldRotationQuaternion = _worldRotationQuaternion
        }
    }

    private func _translate(_ translation: Vector3, _ relativeToLocal: Bool = true) {
        if relativeToLocal {
            _worldPosition += Vector3.transformByQuat(v: translation, quaternion: worldRotationQuaternion)
        } else {
            _worldPosition += translation
        }
        worldPosition = _worldPosition
    }

    private func _rotateXYZ(_ x: Float, _ y: Float, _ z: Float, _ relativeToLocal: Bool = true) {
        let radFactor = MathUtil.degreeToRadFactor
        let rotQuat = Quaternion.rotationEuler(x: x * radFactor, y: y * radFactor, z: z * radFactor)
        _rotateByQuat(rotQuat, relativeToLocal)
    }
}

// MARK: - Dirty flag of transform.

enum TransformModifyFlags: Int {
    case LocalEuler = 0x1
    case LocalQuat = 0x2
    case WorldPosition = 0x4
    case WorldEuler = 0x8
    case WorldQuat = 0x10
    case WorldScale = 0x20
    case LocalMatrix = 0x40
    case WorldMatrix = 0x80

    /// WorldMatrix | WorldPosition
    case WmWp = 0x84
    /// WorldMatrix | WorldEuler | WorldQuat
    case WmWeWq = 0x98
    /// WorldMatrix | WorldPosition | WorldEuler | WorldQuat
    case WmWpWeWq = 0x9C
    /// WorldMatrix | WorldScale
    case WmWs = 0xA0
    /// WorldMatrix | WorldPosition | WorldScale
    case WmWpWs = 0xA4
    /// WorldMatrix | WorldPosition | WorldEuler | WorldQuat | WorldScale
    case WmWpWeWqWs = 0xBC
}
