//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import vox_math

public class Scene: EngineObject {
    /// Scene name.
    public var name: String

    /// The background of the scene.
    public var background: Background = Background()
    /// Scene-related shader data.
    public var shaderData: ShaderData

    /** If cast shadows. */
    public var castShadows: Bool = true
    /** The resolution of the shadow maps. */
    public var shadowResolution: ShadowResolution = ShadowResolution.Medium
    /** The splits of two cascade distribution. */
    public var shadowTwoCascadeSplits: Float = 1.0 / 3.0
    /** The splits of four cascade distribution. */
    public var shadowFourCascadeSplits: Vector3 = Vector3(1.0 / 15, 3.0 / 15.0, 7.0 / 15.0)
    /** Max Shadow distance. */
    public var shadowDistance: Float = 50

    var _activeCameras: [Camera] = []
    var _isActiveInEngine: Bool = false
    var _globalShaderMacro: ShaderMacroCollection = ShaderMacroCollection()
    var _rootEntities: [Entity] = []
    var _sunLight: Light?

    private var _shadowCascades: ShadowCascadesMode = ShadowCascadesMode.NoCascades
    private var _ambientLight: AmbientLight?

    /// Number of cascades to use for directional light shadows.
    public var shadowCascades: ShadowCascadesMode {
        get {
            _shadowCascades
        }
        set {
            if _shadowCascades != newValue {
                shaderData.enableMacro(CASCADED_COUNT, (newValue.rawValue, .int))
                _shadowCascades = newValue
            }
        }
    }

    /// Ambient light.
    public var ambientLight: AmbientLight? {
        get {
            _ambientLight
        }
        set {
            if (newValue == nil) {
                logger.warning("The scene must have one ambient light")
                return
            }

            let lastAmbientLight = _ambientLight
            if (lastAmbientLight !== newValue) {
                lastAmbientLight?._removeFromScene(self)
                newValue!._addToScene(self)
                _ambientLight = newValue
            }
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

    /// Create scene.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Name
    public init(_ engine: Engine, _ name: String = "") {
        self.name = name
        shaderData = ShaderData(engine.device)
        super.init(engine)
    }

    deinit {
        if _isActiveInEngine {
            _engine.sceneManager.activeScene = nil
        }
        engine.sceneManager._allScenes.removeAll { (v: Scene) in
            v === self
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
        let children = _rootEntities
        for i in 0..<children.count {
            let child = children[i]
            if (child.name == name) {
                return child
            }
        }

        for i in 0..<children.count {
            let child = children[i]
            let entity = child.findByName(name)
            if (entity != nil) {
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
            var findEntity = getRootEntity(i)
            if (findEntity!.name != splits[0]) {
                continue
            }
            for j in 1..<splits.count {
                findEntity = Entity._findChildByName(findEntity!, String(splits[j]))
                if findEntity == nil {
                    break
                }
            }
            return findEntity
        }
        return nil
    }
}

//MARK:- Internal Members

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
    
    func _updateShaderData() {
        let lightManager = _engine._lightManager

        lightManager._updateShaderData(shaderData)
        let sunLightIndex = lightManager._getSunLightIndex()
        if (sunLightIndex != -1) {
            _sunLight = lightManager._directLights.get(sunLightIndex)
        }

        if (castShadows && _sunLight != nil && _sunLight!.shadowType != ShadowType.None) {
            shaderData.enableMacro(CASCADED_SHADOW_MAP)
            shaderData.enableMacro(SHADOW_MODE, (_sunLight!.shadowType.rawValue, .int))
        } else {
            shaderData.disableMacro(CASCADED_SHADOW_MAP)
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

//MARK:- Private Members

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
}

