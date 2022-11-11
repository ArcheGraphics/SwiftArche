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

    /** If cast shadows. */
    public var castShadows: Bool = true;
    /** The resolution of the shadow maps. */
    public var shadowResolution: ShadowResolution = ShadowResolution.Medium;
    /** The splits of two cascade distribution. */
    public var shadowTwoCascadeSplits: Float = 1.0 / 3.0;
    /** The splits of four cascade distribution. */
    public var shadowFourCascadeSplits: Vector3 = Vector3(1.0 / 15, 3.0 / 15.0, 7.0 / 15.0);
    /** Max Shadow distance. */
    public var shadowDistance: Float = 50;

    var _isActiveInEngine: Bool = false
    var _rootEntities: [Entity] = []

    private var _shadowCascades: ShadowCascadesMode = ShadowCascadesMode.NoCascades;

    /// Count of root entities.
    var rootEntitiesCount: Int {
        get {
            _rootEntities.count
        }
    }

    /// Root entity collection.
    var rootEntities: [Entity] {
        get {
            _rootEntities
        }
    }

    /// Create scene.
    /// - Parameters:
    ///   - engine: Engine
    ///   - name: Name
    init(_ engine: Engine, _ name: String = "") {
        self.name = name
        super.init(engine)
    }

    /// Create root entity.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    func createRootEntity(_ name: String? = nil) -> Entity {
        let entity = Entity(_engine, name)
        addRootEntity(entity)
        return entity
    }

    /// Append an entity.
    /// - Parameter entity: The root entity to add
    func addRootEntity(_ entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if (!isRoot) {
            entity._isRoot = true
            _ = entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if (oldScene !== self) {
            if ((oldScene != nil) && isRoot) {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: nil, rootEntity: entity);
            Entity._traverseSetOwnerScene(entity, self)
        } else if (!isRoot) {
            _addToRootEntityList(index: nil, rootEntity: entity);
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
    func addRootEntity(index: Int, entity: Entity) {
        let isRoot = entity._isRoot

        // let entity become root
        if (!isRoot) {
            entity._isRoot = true
            _ = entity._removeFromParent()
        }

        // add or remove from scene's rootEntities
        let oldScene = entity._scene
        if (oldScene !== self) {
            if ((oldScene != nil) && isRoot) {
                oldScene!._removeFromEntityList(entity)
            }
            _addToRootEntityList(index: index, rootEntity: entity);
            Entity._traverseSetOwnerScene(entity, self)
        } else if (!isRoot) {
            _addToRootEntityList(index: index, rootEntity: entity);
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
    func removeRootEntity(_ entity: Entity) {
        if (entity._isRoot && entity._scene === self) {
            _removeFromEntityList(entity)
            entity._isRoot = false;
            if _isActiveInEngine && entity._isActiveInHierarchy {
                entity._processInActive()
            }
            Entity._traverseSetOwnerScene(entity, nil)
        }
    }

    /// Get root entity from index.
    /// - Parameter index: Index
    /// - Returns: Entity
    func getRootEntity(_ index: Int = 0) -> Entity? {
        _rootEntities[index]
    }

    /// Find entity globally by name.
    /// - Parameter name: Entity name
    /// - Returns: Entity
    func findEntityByName(_ name: String) -> Entity? {
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
    func findEntityByPath(_ path: String) -> Entity? {
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

    /// Destroy this scene.
    override func destroy() {
        if (_destroyed) {
            return;
        }

        _destroy();

        engine.sceneManager._allScenes.removeAll { (v: Scene) in
            return v === self
        }
    }
}

//MARK:- Internal Members

extension Scene {
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

    // todo

    func _updateShaderData() {
    }

    func _removeFromEntityList(_ entity: Entity) {
        _rootEntities.remove(at: entity._siblingIndex)
        for index in entity._siblingIndex..<rootEntities.count {
            _rootEntities[index]._siblingIndex = _rootEntities[index]._siblingIndex - 1;
        }
        entity._siblingIndex = -1;
    }

    func _destroy() {
        if _isActiveInEngine {
            _engine.sceneManager.activeScene = nil
        }
        while (rootEntitiesCount > 0) {
            _rootEntities[0].destroy();
        }
    }

}

//MARK:- Private Members

extension Scene {
    private func _addToRootEntityList(index: Int?, rootEntity: Entity) {
        let rootEntityCount = _rootEntities.count;
        if (index == nil) {
            rootEntity._siblingIndex = rootEntityCount;
            _rootEntities.append(rootEntity);
        } else {
            if (index! < 0 || index! > rootEntityCount) {
                fatalError()
            }
            rootEntity._siblingIndex = index!;
            _rootEntities[index!] = rootEntity
            for i in index! + 1..<rootEntityCount + 1 {
                _rootEntities[i]._siblingIndex = _rootEntities[i]._siblingIndex + 1;
            }
        }
    }
}

