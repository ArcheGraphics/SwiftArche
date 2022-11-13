//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class Camera: Component {
    struct CameraData {
        var u_viewMat = Matrix()
        var u_projMat = Matrix()
        var u_VPMat = Matrix()
        var u_viewInvMat = Matrix()
        var u_projInvMat = Matrix()
        var u_cameraPos = Vector3()
    }

    private var _cameraData = CameraData()
    private static var _cameraProperty = "u_camera"

    /// Shader data.
    public var shaderData: ShaderData

    /// Rendering priority - A Camera with higher priority will be rendered on top of a camera with lower priority.
    public var priority: Int = 0

    /// Whether to enable frustum culling, it is enabled by default.
    public var enableFrustumCulling: Bool = true

    /// Determining what to clear when rendering by a Camera.
    /// defaultValue `CameraClearFlags.ColorDepth`
    public var clearFlags: CameraClearFlags = .All

    /// Culling mask - which layers the camera renders.
    /// - Remark Support bit manipulation, corresponding to Entity's layer.
    public var cullingMask: Layer = Layer.Everything

    var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection()
    var _frustum: BoundingFrustum = BoundingFrustum()
    var _renderPipeline: RenderPipeline!
    var _cameraInfo = CameraInfo()

    private var _isProjMatSetting = false
    private var _nearClipPlane: Float = 0.1
    private var _farClipPlane: Float = 100
    private var _fieldOfView: Float = 45
    private var _orthographicSize: Float = 10
    private var _isProjectionDirty = true
    private var _isInvProjMatDirty: Bool = true
    private var _isFrustumProjectDirty: Bool = true
    private var _customAspectRatio: Float?
    private var _renderTarget: MTLRenderPassDescriptor? = nil

    private var _frustumViewChangeFlag: BoolUpdateFlag
    private var _transform: Transform
    private var _isViewMatrixDirty: BoolUpdateFlag
    private var _isInvViewProjDirty: BoolUpdateFlag
    private var _viewport: Vector4 = Vector4(0, 0, 1, 1)
    private var _lastAspectSize: Vector2 = Vector2(0, 0)
    private var _invViewProjMat: Matrix = Matrix();

    /// Near clip plane - the closest point to the camera when rendering occurs.
    public var nearClipPlane: Float {
        get {
            _nearClipPlane
        }
        set {
            _nearClipPlane = newValue
            _projMatChange()
        }
    }

    /// Far clip plane - the furthest point to the camera when rendering occurs.
    public var farClipPlane: Float {
        get {
            _farClipPlane
        }
        set {
            _farClipPlane = newValue
            _projMatChange()
        }
    }

    /// The camera's view angle. activating when camera use perspective projection.
    public var fieldOfView: Float {
        get {
            _fieldOfView
        }
        set {
            _fieldOfView = newValue
            _projMatChange()
        }
    }


    /// Aspect ratio. The default is automatically calculated by the viewport's aspect ratio. If it is manually set,
    /// the manual value will be kept. Call resetAspectRatio() to restore it.
    public var aspectRatio: Float {
        get {
            let canvas = _entity.engine.canvas
            return _customAspectRatio ?? (Float(canvas.bounds.size.width) * _viewport.z) / (Float(canvas.bounds.size.height) * _viewport.w)
        }
        set {
            _customAspectRatio = newValue
            _projMatChange()
        }
    }

    /// Viewport, normalized expression, the upper left corner is (0, 0), and the lower right corner is (1, 1).
    /// - Remark: Re-assignment is required after modification to ensure that the modification takes effect.
    public var viewport: Vector4 {
        get {
            _viewport
        }
        set {
            _viewport = newValue
            _projMatChange()
        }
    }


    /// Whether it is orthogonal, the default is false. True will use orthographic projection, false will use perspective projection.
    public var isOrthographic: Bool {
        get {
            _cameraInfo.isOrthographic
        }
        set {
            _cameraInfo.isOrthographic = newValue
            _projMatChange()
        }
    }

    /// Half the size of the camera in orthographic mode.
    public var orthographicSize: Float {
        get {
            _orthographicSize
        }
        set {
            _orthographicSize = newValue
            _projMatChange()
        }
    }

    /// View matrix.
    public var viewMatrix: Matrix {
        get {
            if (_isViewMatrixDirty.flag) {
                _isViewMatrixDirty.flag = false
                _cameraInfo.viewMatrix = Matrix.rotationTranslation(quaternion: _transform.worldRotationQuaternion, translation: _transform.worldPosition);
                _ = _cameraInfo.viewMatrix.invert()
            }
            return _cameraInfo.viewMatrix
        }
    }

    /// The projection matrix is calculated by the relevant parameters of the camera by default.
    /// If it is manually set, the manual value will be maintained. Call resetProjectionMatrix() to restore it.
    public var projectionMatrix: Matrix {
        get {
            let canvas = _entity.engine.canvas
            if ((!_isProjectionDirty || _isProjMatSetting) &&
                    _lastAspectSize.x == Float(canvas.bounds.size.width) &&
                    _lastAspectSize.y == Float(canvas.bounds.size.height)
               ) {
                return _cameraInfo.projectionMatrix
            }
            _isProjectionDirty = false
            _lastAspectSize = Vector2(Float(canvas.bounds.size.width), Float(canvas.bounds.size.height))
            let aspectRatio = aspectRatio
            if (!_cameraInfo.isOrthographic) {
                _cameraInfo.projectionMatrix = Matrix.perspective(
                        fovy: MathUtil.degreeToRadian(_fieldOfView),
                        aspect: aspectRatio,
                        near: _nearClipPlane,
                        far: _farClipPlane)
            } else {
                let width = _orthographicSize * aspectRatio
                let height = _orthographicSize
                _cameraInfo.projectionMatrix = Matrix.ortho(left: -width, right: width, bottom: -height, top: height,
                        near: _nearClipPlane, far: _farClipPlane)
            }
            return _cameraInfo.projectionMatrix
        }
        set {
            _cameraInfo.projectionMatrix = newValue
            _isProjMatSetting = true
            _projMatChange()
        }
    }

    /// Whether to enable HDR.
    public var enableHDR: Bool {
        get {
            fatalError("not implementation")
        }
        set {
            fatalError("not implementation")
        }
    }

    /// RenderTarget. After setting, it will be rendered to the renderTarget. If it is empty, it will be rendered to the main canvas.
    public var renderTarget: MTLRenderPassDescriptor? {
        get {
            _renderTarget
        }
        set {
            _renderTarget = newValue
        }
    }


    /// Create the Camera component.
    /// - Parameter entity: Entity
    public required init(_ entity: Entity) {
        _transform = entity.transform
        _isViewMatrixDirty = _transform.registerWorldChangeFlag()
        _isInvViewProjDirty = _transform.registerWorldChangeFlag()
        _frustumViewChangeFlag = _transform.registerWorldChangeFlag()
        shaderData = ShaderData(entity.engine.device)

        super.init(entity)
        _renderPipeline = RenderPipeline(self)
    }

    override func _onEnable() {
        entity.scene._attachRenderCamera(self)
    }

    override func _onDisable() {
        entity.scene._detachRenderCamera(self)
    }
}

extension Camera {
    /// Restore the automatic calculation of projection matrix through fieldOfView, nearClipPlane and farClipPlane.
    public func resetProjectionMatrix() {
        _isProjMatSetting = false
        _projMatChange()
    }

    /// Restore the automatic calculation of the aspect ratio through the viewport aspect ratio.
    public func resetAspectRatio() {
        _customAspectRatio = nil
        _projMatChange()
    }

    /// Transform a point from world space to viewport space.
    /// - Parameters:
    ///   - point: Point in world space
    /// - Returns: A point in the viewport space, X and Y are the viewport space coordinates, Z is the viewport depth,
    //    the near clipping plane is 0, the far clipping plane is 1, and W is the world unit distance from the camera
    public func worldToViewportPoint(_ point: Vector3) -> Vector3 {
        let cameraPoint = Vector3.transformCoordinate(v: point, m: viewMatrix);
        let viewportPoint = Vector3.transformToVec4(v: cameraPoint, m: projectionMatrix);

        let w = viewportPoint.w;
        return Vector3((viewportPoint.x / w + 1.0) * 0.5, (1.0 - viewportPoint.y / w) * 0.5, -cameraPoint.z);
    }

    /// Transform a point from viewport space to world space.
    /// - Parameters:
    ///   - point: Point in viewport space, X and Y are the viewport space coordinates, Z is the viewport depth.
    ///   The near clipping plane is 0, and the far clipping plane is 1
    /// - Returns: Point in world space
    public func viewportToWorldPoint(_ point: Vector3) -> Vector3 {
        let nf = 1 / (nearClipPlane - farClipPlane);

        var z: Float;
        if (isOrthographic) {
            z = -point.z * 2 * nf;
            z += (farClipPlane + nearClipPlane) * nf;
        } else {
            let pointZ = point.z;
            z = -pointZ * (nearClipPlane + farClipPlane) * nf;
            z += 2 * nearClipPlane * farClipPlane * nf;
            z = z / pointZ;
        }

        return _innerViewportToWorldPoint(point.x, point.y, (z + 1.0) / 2.0, invViewProjMat);
    }

    /// Generate a ray by a point in viewport.
    /// - Parameters:
    ///   - point: Point in viewport space, which is represented by normalization
    ///   - out: Ray
    /// - Returns: Ray
    public func viewportPointToRay(_ point: Vector2, _ out: Ray) -> Ray {
        let invViewProjMat = invViewProjMat
        // Use the intersection of the near clipping plane as the origin point.
        out.origin = _innerViewportToWorldPoint(point.x, point.y, 0.0, invViewProjMat);
        // Use the intersection of the far clipping plane as the origin point.
        out.direction = _innerViewportToWorldPoint(point.x, point.y, 1.0, invViewProjMat);
        out.direction = out.direction - out.origin
        _ = out.direction.normalize();
        return out;
    }

    /// Transform the X and Y coordinates of a point from screen space to viewport space
    /// - Parameters:
    ///   - point: Point in screen space
    /// - Returns: Point in viewport space
    public func screenToViewportPoint(_ point: Vector2) -> Vector2 {
        let canvas = engine.canvas
        let viewport = viewport
        return Vector2((point.x / Float(canvas.bounds.size.width) - viewport.x) / viewport.z,
                (point.y / Float(canvas.bounds.size.height) - viewport.y) / viewport.w)
    }

    public func screenToViewportPoint(_ point: Vector3) -> Vector3 {
        let canvas = engine.canvas
        let viewport = viewport
        return Vector3((point.x / Float(canvas.bounds.size.width) - viewport.x) / viewport.z,
                (point.y / Float(canvas.bounds.size.height) - viewport.y) / viewport.w,
                point.z)
    }

    /// Transform the X and Y coordinates of a point from viewport space to screen space.
    /// - Parameters:
    ///   - point: Point in viewport space
    /// - Returns: Point in screen space
    public func viewportToScreenPoint(_ point: Vector2) -> Vector2 {
        let canvas = engine.canvas
        let x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.size.width)
        let y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.size.height)
        return Vector2(x, y)
    }

    public func viewportToScreenPoint(_ point: Vector3) -> Vector3 {
        let canvas = engine.canvas
        let x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.size.width)
        let y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.size.height)
        return Vector3(x, y, point.z)
    }

    public func viewportToScreenPoint(_ point: Vector4) -> Vector4 {
        let canvas = engine.canvas
        let x = (viewport.x + point.x * viewport.z) * Float(canvas.bounds.size.width)
        let y = (viewport.y + point.y * viewport.w) * Float(canvas.bounds.size.height)
        return Vector4(x, y, point.z, point.w)
    }

    /// Transform a point from world space to screen space.
    /// - Parameters:
    ///   - point: Point in world space
    /// - Returns: Point of screen space
    public func worldToScreenPoint(_ point: Vector3) -> Vector3 {
        viewportToScreenPoint(worldToViewportPoint(point))
    }

    /// Transform a point from screen space to world space.
    /// - Parameters:
    ///   - point: Screen space point
    ///   - out: Point in world space
    /// - Returns: Point in world space
    public func screenToWorldPoint(_ point: Vector3, _ out: Vector3) -> Vector3 {
        viewportToWorldPoint(screenToViewportPoint(point))
    }

    /// Generate a ray by a point in screen.
    /// - Parameters:
    ///   - point: Point in screen space, the unit is pixel
    ///   - out: Ray
    /// - Returns: Ray
    public func screenPointToRay(_ point: Vector2, _ out: Ray) -> Ray {
        viewportPointToRay(screenToViewportPoint(point), out)
    }

    /// Manually call the rendering of the camera.
    public func render() {
        _cameraInfo.viewProjectionMatrix = projectionMatrix * viewMatrix
        _cameraInfo.position = _transform.worldPosition
        if (_cameraInfo.isOrthographic) {
            _cameraInfo.forward = _transform.getWorldForward()
        }

        // compute cull frustum.
        if (enableFrustumCulling && (_frustumViewChangeFlag.flag || _isFrustumProjectDirty)) {
            _frustum.calculateFromMatrix(matrix: _cameraInfo.viewProjectionMatrix)
            _frustumViewChangeFlag.flag = false
            _isFrustumProjectDirty = false
        }

        _updateShaderData()

        // union scene and camera macro.
        ShaderMacroCollection.unionCollection(
                scene.shaderData._macroCollection,
                shaderData._macroCollection,
                _globalShaderMacro
        )

        _renderPipeline.render()
    }
}

extension Camera {
    private func _projMatChange() {
        _isFrustumProjectDirty = true
        _isProjectionDirty = true
        _isInvProjMatDirty = true
        _isInvViewProjDirty.flag = true
    }

    private func _innerViewportToWorldPoint(_ x: Float, _ y: Float, _ z: Float, _ invViewProjMat: Matrix) -> Vector3 {
        // Depth is a normalized value, 0 is nearPlane, 1 is farClipPlane.
        // Transform to clipping space matrix
        let clipPoint = Vector3(x * 2 - 1, 1 - y * 2, z * 2 - 1)
        return Vector3.transformCoordinate(v: clipPoint, m: invViewProjMat);
    }

    private func _updateShaderData() {
        _cameraData.u_viewInvMat = _transform.worldMatrix
        _cameraData.u_viewInvMat = _transform.worldMatrix
        _cameraData.u_viewMat = viewMatrix
        _cameraData.u_projInvMat = inverseProjectionMatrix
        _cameraData.u_projMat = projectionMatrix
        _cameraData.u_VPMat = projectionMatrix * viewMatrix
        shaderData.setData(Camera._cameraProperty, _cameraData)
    }

    /// The inverse matrix of view projection matrix.
    private var invViewProjMat: Matrix {
        get {
            if (_isInvViewProjDirty.flag) {
                _isInvViewProjDirty.flag = false
                _invViewProjMat = _transform.worldMatrix * inverseProjectionMatrix
            }
            return _invViewProjMat
        }
    }

    /// The inverse of the projection matrix.
    private var inverseProjectionMatrix: Matrix {
        get {
            if (_isInvProjMatDirty) {
                _isInvProjMatDirty = false
                _cameraData.u_projInvMat = Matrix.invert(a: projectionMatrix)
            }
            return _cameraData.u_projInvMat
        }
    }
}
