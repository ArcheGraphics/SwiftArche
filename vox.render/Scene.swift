//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

public class Scene: EngineObject {
    private static let _fogProperty = "u_fog"

    /// Scene name.
    public var name: String

    /// The background of the scene.
    public var background: Background = Background()
    /// Scene-related shader data.
    public var shaderData: ShaderData

    /// If cast shadows.
    @MirrorUI
    public var castShadows: Bool = true
    /// The resolution of the shadow maps.
    @MirrorUI
    public var shadowResolution: ShadowResolution = ShadowResolution.High
    /// The splits of two cascade distribution.
    @MirrorUI
    public var shadowTwoCascadeSplits: Float = 1.0 / 3.0
    /// The splits of four cascade distribution.
    @MirrorUI
    public var shadowFourCascadeSplits: Vector3 = Vector3(1.0 / 15, 3.0 / 15.0, 7.0 / 15.0)
    /// Max Shadow distance.
    @MirrorUI
    public var shadowDistance: Float = 50
    /// Number of cascades to use for directional light shadows.
    @MirrorUI
    public var shadowCascades: ShadowCascadesMode = ShadowCascadesMode.NoCascades
    
    var _activeCameras: [Camera] = []
    var _isActiveInEngine: Bool = false
    var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection()
    var _rootEntities: [Entity] = []
    var _sunLight: Light?

    private var _ambientLight: AmbientLight!
    private var _postprocessManager: PostprocessManager!
    private var _fogData = FogData(color: vector_float4(0.5, 0.5, 0.5, 1.0), params: vector_float4())

    /// Get the post-process manager.
    public var postprocessManager: PostprocessManager {
        get {
            _postprocessManager
        }
    }

    /// Ambient light.
    public var ambientLight: AmbientLight {
        get {
            _ambientLight
        }
        set {
            let lastAmbientLight = _ambientLight
            if (lastAmbientLight !== newValue) {
                lastAmbientLight?._removeFromScene(self)
                newValue._addToScene(self)
                _ambientLight = newValue
            }
        }
    }
    
    /// Fog start.
    @MirrorUI
    public var fogStart: Float = 0

    /// Fog end.
    @MirrorUI
    public var fogEnd: Float = 300

    /// Fog density.
    @MirrorUI
    public var fogDensity: Float = 0.01

    /// Fog mode.
    /// - Remarks:
    /// If set to `FogMode.None`, the fog will be disabled.
    /// If set to `FogMode.Linear`, the fog will be linear and controlled by `fogStart` and `fogEnd`.
    /// If set to `FogMode.Exponential`, the fog will be exponential and controlled by `fogDensity`.
    /// If set to `FogMode.ExponentialSquared`, the fog will be exponential squared and controlled by `fogDensity`.
    @MirrorUI
    public var fogMode: FogMode = FogMode.None

    /// Fog color.
    public var fogColor: Color {
        get {
            Color(_fogData.color).toGamma()
        }
        set {
            _fogData.color = newValue.toLinear().internalValue
            shaderData.setData(Scene._fogProperty, _fogData)
        }
    }

    /// Count of root entities.
    public var rootEntitiesCount: Int {
        get {
            _rootEntities.count
        }
    }

    /// Root entity collection.
    public var rootEntities: [Entity] {
        get {
            _rootEntities
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    public required init(from decoder: Decoder) throws {
        let engine = decoder.userInfo[CodingUserInfoKey(rawValue: "engine")!] as! Engine
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        shaderData = ShaderData(engine)
        super.init(engine)
        
        registerCallback()
    }

    /// Create scene.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Name
    public init(_ engine: Engine, _ name: String = "") {
        self.name = name
        shaderData = ShaderData(engine)
        super.init(engine)

        ambientLight = AmbientLight()
        _postprocessManager = PostprocessManager(self)
        engine.sceneManager._allScenes.append(self)

        shaderData.enableMacro(FOG_MODE.rawValue, (fogMode.rawValue, .int))
        shaderData.enableMacro(CASCADED_COUNT.rawValue, (shadowCascades.rawValue, .int))
        _computeLinearFogParams(fogStart, fogEnd)
        _computeExponentialFogParams(fogDensity)
        
        registerCallback()
    }
    
    deinit {
        destroy()
    }
    
    func registerCallback() {
        $shadowCascades.didSet = { [weak self] newValue in
            if newValue != .NoCascades {
                self?.shaderData.enableMacro(CASCADED_COUNT.rawValue, (newValue.rawValue, .int))
            }
        }
        $fogMode.didSet = { [weak self] newValue in
            if newValue != .None {
                self?.shaderData.enableMacro(FOG_MODE.rawValue, (newValue.rawValue, .int))
            }
        }
        $fogStart.didSet = { [weak self] newValue in
            self!._computeLinearFogParams(newValue, (self?.fogEnd)!)
        }
        $fogEnd.didSet = { [weak self] newValue in
            self!._computeLinearFogParams((self?.fogStart)!, newValue)
        }
        $fogDensity.didSet = { [weak self] newValue in
            self!._computeExponentialFogParams(newValue)
        }
    }

    override func destroy() {
        if _isActiveInEngine {
            _engine.sceneManager.activeScene = nil
        }
        engine.sceneManager._allScenes.removeAll { (v: Scene) in
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
        let entity = Entity(_engine, name)
        addRootEntity(entity)
        return entity
    }

    /// Append an entity.
    /// - Parameter entity: The root entity to add
    public func addRootEntity(_ entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if (!isRoot) {
            entity._isRoot = true
            entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if (oldScene !== self) {
            if ((oldScene != nil) && isRoot) {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: nil, rootEntity: entity)
            Entity._traverseSetOwnerScene(entity, self)
        } else if (!isRoot) {
            _addToRootEntityList(index: nil, rootEntity: entity)
        }

        // process entity active/inActive
        if (_isActiveInEngine) {
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
        if (!isRoot) {
            entity._isRoot = true
            entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if (oldScene !== self) {
            if ((oldScene != nil) && isRoot) {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: index, rootEntity: entity)
            Entity._traverseSetOwnerScene(entity, self)
        } else if (!isRoot) {
            _addToRootEntityList(index: index, rootEntity: entity)
        }

        // process entity active/inActive
        if (_isActiveInEngine) {
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
        if (entity._isRoot && entity._scene === self) {
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
        for i in 0..<rootEntitiesCount {
            if let findEntity = getRootEntity(i) {
                if (findEntity.name != splits[0]) {
                    continue
                }
                
                var result: [Entity] = [findEntity]
                for j in 1..<splits.count {
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

//MARK: - Internal Members

extension Scene {
    internal func _attachRenderCamera(_ camera: Camera) {
        let index = _activeCameras.firstIndex { cam in
            cam === camera
        }
        if (index == nil) {
            _activeCameras.append(camera)
        } else {
            logger.warning("Camera already attached.")
        }
    }

    internal func _detachRenderCamera(_ camera: Camera) {
        _activeCameras.removeAll { cam in
            cam === camera
        }
    }

    func _processActive(_ active: Bool) {
        _isActiveInEngine = active
        let rootEntities = _rootEntities
        for i in 0..<rootEntities.count {
            let entity = rootEntities[i]
            if (entity._isActive) {
                active ? entity._processActive() : entity._processInActive()
            }
        }
    }

    func postprocess(_ commandBuffer: MTLCommandBuffer) {
        _postprocessManager.render(commandBuffer)
    }

    func _updateShaderData() {
        let lightManager = _engine._lightManager

        lightManager._updateShaderData(shaderData)
        let sunLightIndex = lightManager._getSunLightIndex()
        if (sunLightIndex != -1) {
            _sunLight = lightManager._directLights.get(sunLightIndex)
        }

        if (castShadows && _sunLight != nil && _sunLight!.shadowType != ShadowType.None) {
            shaderData.enableMacro(CASCADED_SHADOW_MAP.rawValue)
            shaderData.enableMacro(SHADOW_MODE.rawValue, (_sunLight!.shadowType.rawValue, .int))
        } else {
            shaderData.disableMacro(CASCADED_SHADOW_MAP.rawValue)
        }

        // union scene and camera macro.
        ShaderMacroCollection.unionCollection(
                engine._macroCollection,
                shaderData._macroCollection,
                _globalShaderMacro
        )
    }

    func _removeFromEntityList(_ entity: Entity) {
        _rootEntities.remove(at: entity._siblingIndex)
        for index in entity._siblingIndex..<rootEntities.count {
            _rootEntities[index]._siblingIndex = _rootEntities[index]._siblingIndex - 1
        }
        entity._siblingIndex = -1
    }
}

//MARK: - Private Members

extension Scene {
    private func _addToRootEntityList(index: Int?, rootEntity: Entity) {
        let rootEntityCount = _rootEntities.count
        if (index == nil) {
            rootEntity._siblingIndex = rootEntityCount
            _rootEntities.append(rootEntity)
        } else {
            if (index! < 0 || index! > rootEntityCount) {
                fatalError()
            }
            rootEntity._siblingIndex = index!
            _rootEntities[index!] = rootEntity
            for i in index! + 1..<rootEntityCount + 1 {
                _rootEntities[i]._siblingIndex = _rootEntities[i]._siblingIndex + 1
            }
        }
    }

    private func _computeLinearFogParams(_ fogStart: Float, _ fogEnd: Float) {
        let fogRange = fogEnd - fogStart
        _fogData.params.x = -1 / fogRange
        _fogData.params.y = fogEnd / fogRange
        shaderData.setData(Scene._fogProperty, _fogData)
    }

    private func _computeExponentialFogParams(_ density: Float) {
        _fogData.params.z = density / log(2)
        _fogData.params.w = density / sqrt(log(2))
        shaderData.setData(Scene._fogProperty, _fogData)
    }
}

extension Scene: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
