//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public final class Scene: NSObject, Serializable {
    private static let _fogColorProperty = "u_fogColor"
    private static let _fogParamProperty = "u_fogParam"

    /// Scene name.
    @Serialized(default: "scene")
    public var name: String

    /// The background of the scene.
    public var background: Background = .init()
    /// Scene-related shader data.
    public var shaderData: ShaderData = .init(group: .Scene)

    /// If cast shadows.
    @Serialized(default: true)
    public var castShadows: Bool

    /// The resolution of the shadow maps.
    @Serialized(default: .High)
    public var shadowResolution: ShadowResolution

    /// The splits of two cascade distribution.
    @Serialized(default: 1.0 / 3.0)
    public var shadowTwoCascadeSplits: Float

    /// The splits of four cascade distribution.
    @Serialized(default: Vector3(1.0 / 4, 1.0 / 4, 1.0 / 4))
    public var shadowFourCascadeSplits: Vector3

    /// Max Shadow distance.
    @Serialized(default: 50)
    public var shadowDistance: Float

    /// Number of cascades to use for directional light shadows.
    @Serialized(default: .NoCascades)
    public var shadowCascades: ShadowCascadesMode

    @Serialized("rootEntities", default: [])
    var _rootEntities: [Entity]

    var _activeCameras: [Camera] = []
    var _isActiveInEngine: Bool = false
    var _globalShaderMacro: ShaderMacroCollection = .init()
    var _sunLight: Light?

    private var _ambientLight: AmbientLight!
    private var _postprocessManager: PostprocessManager!
    private var _fogParams = Vector4()

    /// Get the post-process manager.
    public var postprocessManager: PostprocessManager {
        _postprocessManager
    }

    /// Ambient light.
    public var ambientLight: AmbientLight {
        get {
            _ambientLight
        }
        set {
            let lastAmbientLight = _ambientLight
            if lastAmbientLight !== newValue {
                lastAmbientLight?._removeFromScene(self)
                newValue._addToScene(self)
                _ambientLight = newValue
            }
        }
    }

    /// Fog start.
    @Serialized(default: 0)
    public var fogStart: Float {
        didSet {
            _computeLinearFogParams(fogStart, fogEnd)
        }
    }

    /// Fog end.
    @Serialized(default: 300)
    public var fogEnd: Float {
        didSet {
            _computeLinearFogParams(fogStart, fogEnd)
        }
    }

    /// Fog density.
    @Serialized(default: 0.01)
    public var fogDensity: Float {
        didSet {
            _computeExponentialFogParams(fogDensity)
        }
    }

    /// Fog mode.
    /// - Remarks:
    /// If set to `FogMode.None`, the fog will be disabled.
    /// If set to `FogMode.Linear`, the fog will be linear and controlled by `fogStart` and `fogEnd`.
    /// If set to `FogMode.Exponential`, the fog will be exponential and controlled by `fogDensity`.
    /// If set to `FogMode.ExponentialSquared`, the fog will be exponential squared and controlled by `fogDensity`.
    @Serialized(default: .None)
    public var fogMode: FogMode {
        didSet {
            if fogMode != .None {
                shaderData.enableMacro(FOG_MODE.rawValue, (fogMode.rawValue, .int))
            }
        }
    }

    /// Fog color.
    @Serialized(default: Color(0.5, 0.5, 0.5))
    public var fogColor: Color {
        didSet {
            shaderData.setData(with: Scene._fogColorProperty, data: fogColor.toLinear().internalValue)
        }
    }

    /// Count of root entities.
    public var rootEntitiesCount: Int {
        _rootEntities.count
    }

    /// Root entity collection.
    public var rootEntities: [Entity] {
        _rootEntities
    }

    /// Create scene.
    /// - Parameters:
    ///   - name: Name
    override public init() {
        super.init()

        ambientLight = AmbientLight()
        _postprocessManager = PostprocessManager(self)
        Engine.sceneManager._allScenes.append(self)

        shaderData.enableMacro(FOG_MODE.rawValue, (fogMode.rawValue, .int))
        shaderData.enableMacro(CASCADED_COUNT.rawValue, (shadowCascades.rawValue, .int))
        _computeLinearFogParams(fogStart, fogEnd)
        _computeExponentialFogParams(fogDensity)

        var desc = MTLArgumentDescriptor()
        desc.index = 0
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: Scene._fogColorProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 1
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: Scene._fogParamProperty, descriptor: desc)
        shaderData.createArgumentBuffer(with: "u_fog")
    }

    deinit {
        destroy()
    }

    func destroy() {
        if _isActiveInEngine {
            Engine.sceneManager.activeScene = nil
        }
        Engine.sceneManager._allScenes.removeAll { (v: Scene) in
            v === self
        }
        _rootEntities.forEach { v in
            v.destroy()
        }
        _rootEntities = []
    }

    /// Create root entity.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    public func createRootEntity(_ name: String = "") -> Entity {
        let entity = Entity(name)
        addRootEntity(entity)
        return entity
    }

    /// Append an entity.
    /// - Parameter entity: The root entity to add
    public func addRootEntity(_ entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if !isRoot {
            entity._isRoot = true
            entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if oldScene !== self {
            if (oldScene != nil) && isRoot {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: nil, rootEntity: entity)
            Entity._traverseSetOwnerScene(entity, self)
        } else if !isRoot {
            _addToRootEntityList(index: nil, rootEntity: entity)
        }

        // process entity active/inActive
        if _isActiveInEngine {
            if !entity._isActiveInHierarchy && entity._isActive {
                entity._processActive()
            }
        } else {
            if entity._isActiveInHierarchy {
                entity._processInActive()
            }
        }
    }

    /// Append an entity.
    /// - Parameters:
    ///   - index: specified index
    ///   - entity: The root entity to add
    public func addRootEntity(index: Int, entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if !isRoot {
            entity._isRoot = true
            entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if oldScene !== self {
            if (oldScene != nil) && isRoot {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: index, rootEntity: entity)
            Entity._traverseSetOwnerScene(entity, self)
        } else if !isRoot {
            _addToRootEntityList(index: index, rootEntity: entity)
        }

        // process entity active/inActive
        if _isActiveInEngine {
            if !entity._isActiveInHierarchy && entity._isActive {
                entity._processActive()
            }
        } else {
            if entity._isActiveInHierarchy {
                entity._processInActive()
            }
        }
    }

    /// Remove an entity.
    /// - Parameter entity: The root entity to remove
    public func removeRootEntity(_ entity: Entity) {
        if entity._isRoot && entity._scene === self {
            _removeFromEntityList(entity)
            entity._isRoot = false
            if _isActiveInEngine && entity._isActiveInHierarchy {
                entity._processInActive()
            }
            Entity._traverseSetOwnerScene(entity, nil)
        }
    }

    /// Get root entity from index.
    /// - Parameter index: Index
    /// - Returns: Entity
    public func getRootEntity(_ index: Int = 0) -> Entity? {
        _rootEntities[index]
    }

    /// Find entity globally by name.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    public func findEntityByName(_ name: String) -> Entity? {
        for root in _rootEntities {
            let entity = root.findByName(name)
            if entity != nil {
                return entity
            }
        }
        return nil
    }

    /// Find entity globally by name,use ‘/’ symbol as a path separator.
    /// - Parameter path: Entity's path
    /// - Returns: Entity
    public func findEntityByPath(_ path: String) -> Entity? {
        let splits = path.split(separator: "/")
        for i in 0 ..< rootEntitiesCount {
            if let findEntity = getRootEntity(i) {
                if findEntity.name != splits[0] {
                    continue
                }

                var result: [Entity] = [findEntity]
                for j in 1 ..< splits.count {
                    result = Entity._findChildByName(result, String(splits[j]))
                    if result.isEmpty {
                        break
                    }
                }

                if !result.isEmpty {
                    return result[0]
                }
            }
        }
        return nil
    }
}

// MARK: - Internal Members

extension Scene {
    func _attachRenderCamera(_ camera: Camera) {
        let index = _activeCameras.firstIndex { cam in
            cam === camera
        }
        if index == nil {
            _activeCameras.append(camera)
        } else {
            logger.warning("Camera already attached.")
        }
    }

    func _detachRenderCamera(_ camera: Camera) {
        _activeCameras.removeAll { cam in
            cam === camera
        }
    }

    func _processActive(_ active: Bool) {
        _isActiveInEngine = active
        let rootEntities = _rootEntities
        for i in 0 ..< rootEntities.count {
            let entity = rootEntities[i]
            if entity._isActive {
                active ? entity._processActive() : entity._processInActive()
            }
        }
    }

    func postprocess(_ commandBuffer: MTLCommandBuffer) {
        _postprocessManager.compute(with: commandBuffer)
    }

    func _updateShaderData() {
        let lightManager = Engine._lightManager

        lightManager._updateShaderData(shaderData)
        let sunLightIndex = lightManager._getSunLightIndex()
        if sunLightIndex != -1 {
            _sunLight = lightManager._directLights.get(sunLightIndex)
        }

        if castShadows, _sunLight != nil, _sunLight!.shadowType != ShadowType.None {
            shaderData.enableMacro(CASCADED_SHADOW_MAP.rawValue)
            shaderData.enableMacro(SHADOW_MODE.rawValue, (_sunLight!.shadowType.rawValue, .int))
        } else {
            shaderData.disableMacro(CASCADED_SHADOW_MAP.rawValue)
        }

        // union scene and camera macro.
        ShaderMacroCollection.unionCollection(
            Engine._macroCollection,
            shaderData._macroCollection,
            &_globalShaderMacro
        )
    }

    func _removeFromEntityList(_ entity: Entity) {
        _rootEntities.remove(at: entity._siblingIndex)
        for index in entity._siblingIndex ..< rootEntities.count {
            _rootEntities[index]._siblingIndex = _rootEntities[index]._siblingIndex - 1
        }
        entity._siblingIndex = -1
    }
}

// MARK: - Private Members

extension Scene {
    private func _addToRootEntityList(index: Int?, rootEntity: Entity) {
        let rootEntityCount = _rootEntities.count
        if index == nil {
            rootEntity._siblingIndex = rootEntityCount
            _rootEntities.append(rootEntity)
        } else {
            if index! < 0 || index! > rootEntityCount {
                fatalError()
            }
            rootEntity._siblingIndex = index!
            _rootEntities[index!] = rootEntity
            for i in index! + 1 ..< rootEntityCount + 1 {
                _rootEntities[i]._siblingIndex = _rootEntities[i]._siblingIndex + 1
            }
        }
    }

    private func _computeLinearFogParams(_ fogStart: Float, _ fogEnd: Float) {
        let fogRange = fogEnd - fogStart
        _fogParams.x = -1 / fogRange
        _fogParams.y = fogEnd / fogRange
        shaderData.setData(with: Scene._fogParamProperty, data: _fogParams)
    }

    private func _computeExponentialFogParams(_ density: Float) {
        _fogParams.z = density / log(2)
        _fogParams.w = density / sqrt(log(2))
        shaderData.setData(with: Scene._fogParamProperty, data: _fogParams)
    }
}
