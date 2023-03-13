//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

/// Renderable component.
public class Renderer: Component {
    /// ShaderData related to renderer.
    public var shaderData: ShaderData
    /// Whether it is clipped by the frustum, needs to be turned on camera.enableFrustumCulling.
    public var isCulled: Bool = false
    /// Whether cast shadow.
    public var castShadows: Bool = true
    /// The render priority of the renderer, lower values are rendered first and higher values are rendered last.
    public var priority: Int = 0

    var _distanceForSort: Float = 0
    var _onUpdateIndex: Int = -1
    var _rendererIndex: Int = -1
    var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection()
    var _bounds: BoundingBox = BoundingBox(Vector3(), Vector3())

    var _materials: [Material?] = []
    var _dirtyUpdateFlag: Int = 0
    var _receiveShadows: Bool = true

    static private let _renderProperty = "u_renderer"
    private var _rendererData = RendererData()

    /// Whether receive shadow.
    public var receiveShadows: Bool {
        get {
            _receiveShadows
        }
        set {
            if (_receiveShadows != newValue) {
                if (newValue) {
                    shaderData.enableMacro(NEED_RECEIVE_SHADOWS.rawValue)
                } else {
                    shaderData.disableMacro(NEED_RECEIVE_SHADOWS.rawValue)
                }
                _receiveShadows = newValue
            }
        }
    }

    /// Material count.
    public var materialCount: Int {
        get {
            _materials.count
        }
    }

    /// The bounding volume of the renderer.
    public var bounds: BoundingBox {
        get {
            if (_dirtyUpdateFlag & RendererUpdateFlags.WorldVolume.rawValue != 0) {
                _updateBounds(&_bounds)
                _dirtyUpdateFlag &= ~RendererUpdateFlags.WorldVolume.rawValue
            }
            return _bounds
        }
    }

    public required init(_ entity: Entity) {
        shaderData = ShaderData(entity.engine)
        super.init(entity)
        _registerEntityTransformListener()
        shaderData.enableMacro(NEED_RECEIVE_SHADOWS.rawValue)
    }

    override func _onDestroy() {
        let listener = ListenerUpdateFlag()
        listener.listener = _onTransformChanged
        entity.transform._updateFlagManager.removeFlag(flag: listener)
        _materials = []
    }

    /// Get the first material by index.
    /// - Parameter index: Material index
    /// - Returns: Material
    public func getMaterial(_ index: Int = 0) -> Material? {
        return _materials[index]
    }

    /// Set the first material.
    /// - Parameter material: The first material
    public func setMaterial(_ material: Material) {
        setMaterial(0, material)
    }

    /// Set material by index.
    /// - Parameters:
    ///   - index: Material index
    ///   - material: The material
    public func setMaterial(_ index: Int, _ material: Material) {
        if (index >= _materials.count) {
            _materials.reserveCapacity(index + 1)
            for _ in _materials.count...index {
                _materials.append(nil)
            }
        }
        _materials[index] = material
    }

    /// Get all materials.
    /// - Returns: All materials
    public func getMaterials() -> [Material?] {
        _materials
    }

    /// Set all materials.
    /// - Parameter materials: All materials
    public func setMaterials(_ materials: [Material]) {
        let count = materials.count

        if _materials.count != count {
            _materials.reserveCapacity(count)
            for _ in _materials.count..<count {
                _materials.append(nil)
            }
        }

        for i in 0..<count {
            _materials[i] = materials[i]
        }
    }

    func update(_ deltaTime: Float) {
    }

    override func _onEnable() {
        let componentsManager = engine._componentsManager
        componentsManager.addRenderer(self)
    }

    override func _onDisable() {
        let componentsManager = engine._componentsManager
        componentsManager.removeRenderer(self)
    }

    func _prepareRender(_ cameraInfo: CameraInfo, _ renderPipeline: DevicePipeline) {
        var boundsCenter = bounds.getCenter()

        if (cameraInfo.isOrthographic) {
            boundsCenter = boundsCenter - cameraInfo.position
            _distanceForSort = Vector3.dot(left: boundsCenter, right: cameraInfo.forward)
        } else {
            _distanceForSort = Vector3.distanceSquared(left: boundsCenter, right: cameraInfo.position)
        }

        _updateShaderData(cameraInfo)
        _render(renderPipeline)

        // union camera global macro and renderer macro.
        ShaderMacroCollection.unionCollection(
                renderPipeline.camera._globalShaderMacro,
                shaderData._macroCollection,
                _globalShaderMacro
        )
    }

    func _updateShaderData(_ cameraInfo: CameraInfo) {
        _updateTransformShaderData(cameraInfo, entity.transform.worldMatrix)
    }

    func _updateTransformShaderData(_ cameraInfo: CameraInfo, _ worldMatrix: Matrix) {
        _rendererData.u_modelMat = worldMatrix.elements
        _rendererData.u_localMat = entity.transform.localMatrix.elements
        var normalMatrix = Matrix.invert(a: worldMatrix)
        _rendererData.u_normalMat = normalMatrix.transpose().elements

        shaderData.setDynamicData(Renderer._renderProperty, _rendererData)
    }

    func _registerEntityTransformListener() {
        let listener = ListenerUpdateFlag()
        listener.listener = _onTransformChanged
        entity.transform._updateFlagManager.addFlag(flag: listener)
    }

    func _updateBounds(_ worldBounds: inout BoundingBox) {
    }

    func _render(_ devicePipeline: DevicePipeline) {
    }

    func _onTransformChanged(type: Int?, object: AnyObject?) -> Void {
        _dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume.rawValue
    }
}

enum RendererUpdateFlags: Int {
    /// Include world position and world bounds.
    case WorldVolume = 0x1
}
