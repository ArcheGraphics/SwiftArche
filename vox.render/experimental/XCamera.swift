//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A Camera objec used for rendering standard perspective or parallel setups.
/// The camera object has only six writable properties:
///  `position`, `direction`, and `up` define the orientation and position of the camera
///  `nearPlane` and `farPlane` define the projection planes.
///  `viewAngle` defines the view angle in radians.
///  All other properties are generated from these values.
class XCamera {
    /// Internally generated camera data used/defined by the renderer
    var _cameraParams = XCameraParams()
    /// Boolean value that denotes if the internal data structure needs rebuilding
    var _cameraParamsDirty: Bool = false

    /// The camera uses either perspective or parallel projection, depending on a defined angle OR a defined width.
    /// Full view angle inradians for perspective view 0 for parallel view.
    var _viewAngle: Float = 0
    /// Width of back plane for parallel view 0 for perspective view.
    var _width: Float = 0
    /// Direction of the camera is normalized.
    var _direction = Vector3()
    /// Position of the camera/observer point.
    var _position = Vector3()
    /// Up direction of the camera perpendicular to _direction.
    var _up = Vector3()
    /// Distance of the near plane to _position in world space.
    var _nearPlane: Float = 0
    /// Distance of the far plane to _position in world space.
    var _farPlane: Float = 0
    /// Aspect ratio of the horizontal against the vertical (widescreen gives < 1.0 value).
    var _aspectRatio: Float = 0
    /// Offset projection (used by TAA or to stabilize cascaded shadow maps).
    var _projectionOffset = Vector2()
    /// Corners of the camera frustum in world space.
    var _frustumCorners = [Vector3](repeating: Vector3(), count: 8)

    /// Internally generated data maps to `_cameraParams`.
    var cameraParams: XCameraParams {
        _cameraParams
    }

    /// Left of the camera./
    var left: Vector3 {
        Vector3.cross(left: _direction, right: _up)
    }

    /// // Right of the camera.
    var right: Vector3 {
        -left
    }

    /// Down direction of the camera./
    var down: Vector3 {
        -up
    }

    /// Facing direction of the camera (alias of direction).
    var forward: Vector3 {
        direction
    }

    /// Backwards direction of the camera./
    var backward: Vector3 {
        -direction
    }

    var frustumCorners: [Vector3] {
        if _cameraParamsDirty {
            updateState()
        }
        return _frustumCorners
    }

    /// Returns true if perspective (viewAngle != 0, width == 0).
    var isPerspective: Bool {
        _viewAngle != 0.0
    }

    /// Returns true if perspective (width != 0, viewAngle == 0)./
    var isParallel: Bool {
        _viewAngle == 0.0
    }

    /// Position/observer point of the camera./
    var position: Vector3 {
        get {
            _position
        }
        set {
            _position = newValue
            _cameraParamsDirty = true
        }
    }

    /// Facing direction of the camera./
    var direction: Vector3 {
        get {
            _direction
        }
        set {
            orthogonalize(fromNewUp: newValue)
            _cameraParamsDirty = true
        }
    }

    /// Up direction of the camera perpendicular to direction.
    var up: Vector3 {
        get {
            _up
        }
        set {
            orthogonalize(fromNewForward: newValue)
            _cameraParamsDirty = true
        }
    }

    var width: Float {
        get {
            _width
        }
        set {
            assert(_viewAngle == 0)
            _width = newValue
            _cameraParamsDirty = true
        }
    }

    /// Full viewing angle in radians./
    var viewAngle: Float {
        get {
            _viewAngle
        }
        set {
            assert(_width == 0)
            _viewAngle = newValue
            _cameraParamsDirty = true
        }
    }

    /// Aspect ratio in width / height./
    var aspectRatio: Float {
        get {
            _aspectRatio
        }
        set {
            _aspectRatio = newValue
            _cameraParamsDirty = true
        }
    }

    /// Distance from near plane to observer point (position)./
    var nearPlane: Float {
        get {
            _nearPlane
        }
        set {
            _nearPlane = newValue
            _cameraParamsDirty = true
        }
    }

    /// Distance from far plane to observer point (position)./
    var farPlane: Float {
        get {
            _farPlane
        }
        set {
            _farPlane = newValue
            _cameraParamsDirty = true
        }
    }

    /// Offset projection (used by TAA or to stabilize cascaded shadow maps)./
    var projectionOffset: Vector2 {
        get {
            _projectionOffset
        }
        set {
            _projectionOffset = newValue
            _cameraParamsDirty = true
        }
    }

    /// Updates internal state from the various properties.
    func updateState() {
        // Generate the view matrix from a matrix lookat.
        _cameraParams.viewMatrix = XCamera.sInvMatrixLookat(inEye: _position.internalValue,
                                                            inTo: (_position + _direction).internalValue,
                                                            inUp: _up.internalValue)

        let px = _projectionOffset.x
        let py = _projectionOffset.y

        // Generate projection matrix from viewing angle and plane distances.
        if _viewAngle != 0 {
            let va_tan = 1.0 / tanf(_viewAngle * 0.5)
            let ys = va_tan
            let xs = ys / _aspectRatio
            let zs = _farPlane / (_farPlane - _nearPlane)
            _cameraParams.projectionMatrix = float4x4(
                SIMD4<Float>(xs, 0, 0, 0),
                SIMD4<Float>(0, ys, 0, 0),
                SIMD4<Float>(px, py, zs, 1),
                SIMD4<Float>(0, 0, -_nearPlane * zs, 0)
            )
        } else {
            let ys = 2.0 / _width
            let xs = ys / _aspectRatio
            let zs = 1.0 / (_farPlane - _nearPlane)
            _cameraParams.projectionMatrix = float4x4(
                SIMD4<Float>(xs, 0, 0, 0),
                SIMD4<Float>(0, ys, 0, 0),
                SIMD4<Float>(0, 0, zs, 0),
                SIMD4<Float>(px, py, -_nearPlane * zs, 1)
            )
        }

        // Derived matrices.
        _cameraParams.viewProjectionMatrix = _cameraParams.projectionMatrix * _cameraParams.viewMatrix
        _cameraParams.invProjectionMatrix = simd_inverse(_cameraParams.projectionMatrix)
        _cameraParams.invViewProjectionMatrix = simd_inverse(_cameraParams.viewProjectionMatrix)
        _cameraParams.invViewMatrix = simd_inverse(_cameraParams.viewMatrix)

        let transp_vpm = simd_transpose(_cameraParams.viewProjectionMatrix)
        _cameraParams.worldFrustumPlanes.0 = XCamera.sPlaneNormalize(transp_vpm.columns.3 + transp_vpm.columns.0) // Left plane eq.
        _cameraParams.worldFrustumPlanes.1 = XCamera.sPlaneNormalize(transp_vpm.columns.3 - transp_vpm.columns.0) // Right plane eq.
        _cameraParams.worldFrustumPlanes.2 = XCamera.sPlaneNormalize(transp_vpm.columns.3 + transp_vpm.columns.1) // Up plane eq.
        _cameraParams.worldFrustumPlanes.3 = XCamera.sPlaneNormalize(transp_vpm.columns.3 - transp_vpm.columns.1) // Down plane eq.
        _cameraParams.worldFrustumPlanes.4 = XCamera.sPlaneNormalize(transp_vpm.columns.3 + transp_vpm.columns.2) // Near plane eq.
        _cameraParams.worldFrustumPlanes.5 = XCamera.sPlaneNormalize(transp_vpm.columns.3 - transp_vpm.columns.2) // Far plane eq.

        // Inverse Column.
        _cameraParams.invProjZ = SIMD4<Float>(
            _cameraParams.invProjectionMatrix.columns.2.z,
            _cameraParams.invProjectionMatrix.columns.2.w,
            _cameraParams.invProjectionMatrix.columns.3.z,
            _cameraParams.invProjectionMatrix.columns.3.w
        )

        let invScale = _farPlane - _nearPlane
        let bias = -_nearPlane

        _cameraParams.invProjZNormalized = SIMD4<Float>(
            _cameraParams.invProjZ.x + (_cameraParams.invProjZ.y * bias),
            _cameraParams.invProjZ.y * invScale,
            _cameraParams.invProjZ.z + (_cameraParams.invProjZ.w * bias),
            _cameraParams.invProjZ.w * invScale
        )

        // Update frustum corners.
        // Get the 8 points of the view frustum in world space.
        _frustumCorners[0] = Vector3(-1.0, 1.0, 0.0)
        _frustumCorners[1] = Vector3(1.0, 1.0, 0.0)
        _frustumCorners[2] = Vector3(1.0, -1.0, 0.0)
        _frustumCorners[3] = Vector3(-1.0, -1.0, 0.0)
        _frustumCorners[4] = Vector3(-1.0, 1.0, 1.0)
        _frustumCorners[5] = Vector3(1.0, 1.0, 1.0)
        _frustumCorners[6] = Vector3(1.0, -1.0, 1.0)
        _frustumCorners[7] = Vector3(-1.0, -1.0, 1.0)

        let invViewProjMatrix = _cameraParams.invViewProjectionMatrix

        for j in 0 ..< 8 {
            let corner = invViewProjMatrix * SIMD4<Float>(_frustumCorners[j].x, _frustumCorners[j].y, _frustumCorners[j].z, 1.0)
            _frustumCorners[j] = Vector3(corner.xyz / corner.w)
        }

        // Data are updated and no longer dirty.
        _cameraParamsDirty = false
    }

    /// Rotates camera around axis updating many properties at once.
    func rotateOnAxis(_ inAxis: Vector3, radians inRadians: Float) {
        // Generate rotation matrix along inAxis.
        let axis = inAxis.normalized
        let ct = cosf(inRadians)
        let st = sinf(inRadians)
        let ci = 1 - ct
        let x = axis.x
        let y = axis.y
        let z = axis.z
        let mat = Matrix3x3(m11: ct + x * x * ci, m12: y * x * ci + z * st, m13: z * x * ci - y * st,
                            m21: x * y * ci - z * st, m22: ct + y * y * ci, m23: z * y * ci + x * st,
                            m31: x * z * ci + y * st, m32: y * z * ci - x * st, m33: ct + z * z * ci)

        // Apply to basis vectors.
        _direction = mat * _direction
        _up = mat * _up
        _cameraParamsDirty = true
    }

    /// Faces the camera towards a point with a given up vector.
    func face(point: Vector3, withUp up: Vector3) {
        _direction = (point - _position).normalized
        let right = Vector3.cross(left: _direction, right: up).normalized
        _up = Vector3.cross(left: right, right: _direction)
    }

    /// Faces the camera towards a direction with a given up vector.
    func face(direction forward: Vector3, withUp up: Vector3) {
        _direction = forward.normalized
        let right = Vector3.cross(left: _direction, right: up).normalized
        _up = Vector3.cross(left: right, right: _direction)
    }

    /// Helper function called after up updated. Adjusts forward/direction to stay orthogonal when
    ///  creating a more defined basis, do not set axis independently, but use `rotate()` or `setBasis()`
    ///  functions to update all at once.
    private func orthogonalize(fromNewUp newUp: Vector3) {
        _up = newUp.normalized
        let right = Vector3.cross(left: _direction, right: _up).normalized
        _direction = Vector3.cross(left: _up, right: right)
    }

    /// Helper function called after forward updated.  Adjusts up to stay orthogonal when creating a
    ///  more defined basis, do not set axis independently, but use `rotate()` or `setBasis()` functions
    ///  to update all at once.
    private func orthogonalize(fromNewForward newForward: Vector3) {
        _direction = newForward.normalized
        let right = Vector3.cross(left: _direction, right: _up).normalized
        _up = Vector3.cross(left: right, right: _direction)
    }

    /// Generate look-at matrix. First generate the full matrix basis, then write out an inverse transform matrix.
    static func sInvMatrixLookat(inEye: SIMD3<Float>, inTo: SIMD3<Float>, inUp: SIMD3<Float>) -> float4x4 {
        let z = normalize(inTo - inEye)
        let x = normalize(cross(inUp, z))
        let y = cross(z, x)
        let t = SIMD3<Float>(-dot(x, inEye), -dot(y, inEye), -dot(z, inEye))
        return float4x4(SIMD4<Float>(x.x, y.x, z.x, 0),
                        SIMD4<Float>(x.y, y.y, z.y, 0),
                        SIMD4<Float>(x.z, y.z, z.z, 0),
                        SIMD4<Float>(t.x, t.y, t.z, 1))
    }

    /// Helper function to normalize a plane equation so the plane direction is normalized to 1 this
    ///  results in `dot(x, plane.xyz)+plane.w` giving the actual distance to the plane.
    static func sPlaneNormalize(_ inPlane: SIMD4<Float>) -> SIMD4<Float> {
        return inPlane / length(inPlane.xyz)
    }
}
