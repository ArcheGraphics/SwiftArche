//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import vox_math

/// Entity, be used as components container.
public final class Entity: EngineObject {
    private var _layer: Layer = .Layer0
    
    /// The name of entity.
    public var name: String
    /// Transform component.
    public var transform: Transform!
    
    /// The layer the entity belongs to.
    public var layer: Layer {
        get {
            _layer
        }
        set {
            if _layer != newValue {
                _layer = newValue
                let colliders = getComponents(Collider.self)
                for col in colliders {
                    col.setGroup(UInt16(_layer.rawValue.nonzeroBitCount))
                }
            }
        }
    }

    internal var _isActiveInHierarchy: Bool = false
    internal var _components: [Component] = []
    internal var _scripts: DisorderedArray<Script> = DisorderedArray()
    internal var _children: [Entity] = []
    internal var _scene: Scene!
    internal var _isRoot: Bool = false
    internal var _isActive: Bool = true
    internal var _siblingIndex: Int = -1

    private var _parent: Entity? = nil
    private var _activeChangedComponents: [Component] = []

    /// Create a entity.
    /// - Parameters:
    ///   - engine: The engine the entity belongs to.
    ///   - name: The name
    public init(_ engine: Engine, _ name: String = "") {
        self.name = name
        super.init(engine)

        transform = addComponent(Transform.self)
        _inverseWorldMatFlag = transform.registerWorldChangeFlag()
    }
    
    deinit {
        destroy()
    }

    override public func destroy() {
        _components.forEach { v in
            v.destroy()
        }
        _components = []
        _children.forEach { v in
            v.destroy()
        }

        if (_isRoot) {
            _scene._removeFromEntityList(self)
            _isRoot = false
        } else {
            _removeFromParent()
        }
    }

    private var _invModelMatrix: Matrix = Matrix()
    private var _inverseWorldMatFlag: BoolUpdateFlag!

    /// Whether to activate locally.
    public var isActive: Bool {
        get {
            _isActive
        }
        set {
            if (newValue != _isActive) {
                _isActive = newValue
                if (newValue) {
                    let parent = _parent
                    if (parent?._isActiveInHierarchy ?? false || (_isRoot && _scene._isActiveInEngine)) {
                        _processActive()
                    }
                } else {
                    if (_isActiveInHierarchy) {
                        _processInActive()
                    }
                }
            }
        }
    }

    /// Whether it is active in the hierarchy.
    public var isActiveInHierarchy: Bool {
        get {
            _isActiveInHierarchy
        }
    }

    /// The parent entity.
    public var parent: Entity? {
        get {
            _parent
        }
        set {
            _setParent(newValue)
        }
    }

    /// The children entities
    public var children: [Entity] {
        get {
            _children
        }
    }

    /// Number of the children entities
    public var childCount: Int {
        get {
            _children.count
        }
    }

    /// The scene the entity belongs to.
    public var scene: Scene {
        get {
            _scene
        }
    }

    public var siblingIndex: Int {
        get {
            _siblingIndex
        }
        set {
            if (_siblingIndex == -1) {
                fatalError("The entity ${this.name} is not in the hierarchy")
            }

            if _isRoot {
                _setSiblingIndex(&_scene._rootEntities, newValue)
            } else {
                _setSiblingIndex(&_parent!._children, newValue)
            }
        }
    }

    /// Add component based on the component type.
    /// - Returns: The component which has been added.
    @discardableResult
    public func addComponent<T: Component>(_ type: T.Type) -> T {
        //todo ComponentsDependencies._addCheck(this, type)
        let component = T(self)
        _components.append(component)
        if (_isActiveInHierarchy) {
            component._setActive(true)
        }
        return component
    }

    /// Get component which match the type.
    /// - Returns: The first component which match type.
    public func getComponent<T: Component>(_ type: T.Type) -> T? {
        for i in 0..<_components.count {
            let component = _components[i]
            if (component is T) {
                return (component as! T)
            }
        }
        return nil
    }

    /// Get components which match the type.
    /// - Parameter results: The components which match type.
    /// - Returns: The components which match type.
    public func getComponents<T: Component>(_ type: T.Type) -> [T] {
        var results: [T] = []
        for i in 0..<_components.count {
            let component = _components[i]
            if (component is T) {
                results.append(component as! T)
            }
        }
        return results
    }

    /// Get the components which match the type of the entity and it's children.
    /// - Parameter results: The components collection.
    /// - Returns:  The components collection which match the type.
    public func getComponentsIncludeChildren<T: Component>(_ type: T.Type) -> [T] {
        var results: [T] = []
        _getComponentsInChildren(&results)
        return results
    }

    /// Add child entity.
    /// - Parameter child: The child entity which want to be added.
    public func addChild(_ child: Entity) {
        if (child._isRoot) {
            child._scene._removeFromEntityList(child)
            child._isRoot = false

            _addToChildrenList(nil, child)
            child._parent = self

            let newScene = _scene
            if (child._scene !== newScene) {
                Entity._traverseSetOwnerScene(child, newScene)
            }

            if (_isActiveInHierarchy) {
                if !child._isActiveInHierarchy && child._isActive {
                    child._processActive()
                }
            } else {
                if child._isActiveInHierarchy {
                    child._processInActive()
                }
            }

            child.transform._parentChange()
        } else {
            child._setParent(self, nil)
        }
    }

    public func addChild(_ index: Int, _ child: Entity) {
        if (child._isRoot) {
            child._scene._removeFromEntityList(child)
            child._isRoot = false

            _addToChildrenList(index, child)
            child._parent = self

            let newScene = _scene
            if (child._scene !== newScene) {
                Entity._traverseSetOwnerScene(child, newScene)
            }

            if (_isActiveInHierarchy) {
                if !child._isActiveInHierarchy && child._isActive {
                    child._processActive()
                }
            } else {
                if child._isActiveInHierarchy {
                    child._processInActive()
                }
            }
            child.transform._parentChange()
        } else {
            child._setParent(self, index)
        }
    }

    /// Remove child entity.
    /// - Parameter child: The child entity which want to be removed.
    public func removeChild(_ child: Entity) {
        child._setParent(nil)
    }

    /// Find child entity by index.
    /// - Parameter index: The index of the child entity.
    /// - Returns: The component which be found.
    public func getChild(_ index: Int) -> Entity {
        _children[index]
    }

    /// Find child entity by name.
    /// - Parameter name: The name of the entity which want to be found.
    /// - Returns: The component which be found.
    public func findByName(_ name: String) -> Entity? {
        if (self.name == name) {
          return self
        }
        for child in _children {
          let target = child.findByName(name)
          if target != nil {
            return target
          }
        }
        return nil
    }

    /// Find the entity by path.
    /// - Parameter path: The path fo the entity eg: /entity.
    /// - Returns: The component which be found.
    public func findByPath(_ path: String) -> Entity? {
        let splits = path.split(separator: "/")
        var result: [Entity] = [self]
        for split in splits {
            result = Entity._findChildByName(result, String(split))
        }
        if result.isEmpty {
            return nil
        } else {
            return result[0] // only have single right animation node in the path
        }
    }

    /// Create child entity.
    /// - Parameter name: The child entity's name.
    /// - Returns: The child entity.
    public func createChild(_ name: String = "") -> Entity {
        let child = Entity(engine, name)
        child.layer = layer
        child.parent = self
        return child
    }

    /// Clear children entities.
    public func clearChildren() {
        for child in _children {
            child._parent = nil
            if child._isActiveInHierarchy {
                child._processInActive()
            }
            Entity._traverseSetOwnerScene(child, nil) // Must after child._processInActive().
        }
        _children = []
    }

    /// Clone
    /// - Returns: Cloned entity.
    public func clone() -> Entity {
        let cloneEntity = Entity(_engine, name)

        cloneEntity._isActive = _isActive
        cloneEntity.transform.localMatrix = transform.localMatrix

        let children = _children
        for i in 0..<_children.count {
            let child = children[i]
            cloneEntity.addChild(child.clone())
        }

        let components = _components
        for i in 0..<components.count {
            let sourceComp = components[i]
            if (!(sourceComp is Transform)) {
                // todo
                // let targetComp = cloneEntity.addComponent(<new (entity: Entity) => Component>sourceComp.constructor)
                // ComponentCloner.cloneComponent(sourceComp, targetComp)
            }
        }

        return cloneEntity
    }
}

//MARK: - Internal Methods

extension Entity {
    internal func _removeComponent(_ component: Component) {
        _components.removeAll { value in
            value === component
        }
    }

    internal func _addScript(_ script: Script) {
        script._entityScriptsIndex = _scripts.count
        _scripts.add(script)
    }

    internal func _removeScript(_ script: Script) {
        let replaced = _scripts.deleteByIndex(script._entityScriptsIndex)
        if replaced != nil {
            replaced!._entityScriptsIndex = script._entityScriptsIndex
        }
        script._entityScriptsIndex = -1
    }

    internal func _removeFromParent() {
        let oldParent = _parent
        if (oldParent != nil) {
            oldParent!._children.remove(at: _siblingIndex)
            for index in _siblingIndex..<oldParent!._children.count {
                oldParent!._children[index]._siblingIndex = oldParent!._children[index]._siblingIndex - 1
            }
            _parent = nil
            _siblingIndex = -1
        }
    }

    internal func _processActive() {
        if (!_activeChangedComponents.isEmpty) {
            fatalError("Note: can't set the 'main inActive entity' active in hierarchy, if the operation is in main inActive entity or it's children script's onDisable Event.")
        }
        _activeChangedComponents = _engine._componentsManager.getActiveChangedTempList()
        _setActiveInHierarchy(&_activeChangedComponents)
        _setActiveComponents(true)
    }

    internal func _processInActive() {
        if (!_activeChangedComponents.isEmpty) {
            fatalError("Note: can't set the 'main active entity' inActive in hierarchy, if the operation is in main active entity or it's children script's onEnable Event.")
        }
        _activeChangedComponents = _engine._componentsManager.getActiveChangedTempList()
        _setInActiveInHierarchy(&_activeChangedComponents)
        _setActiveComponents(false)
    }
}

//MARK: - Private Methods

extension Entity {
    private func _addToChildrenList(_ index: Int?, _ child: Entity) {
        let childCount = _children.count
        if (index == nil) {
            child._siblingIndex = childCount
            _children.append(child)
        } else {
            if (index! < 0 || index! > childCount) {
                fatalError()
            }
            child._siblingIndex = index!
            _children[index!] = child
            for i in index! + 1..<childCount + 1 {
                _children[i]._siblingIndex = _children[i]._siblingIndex + 1
            }
        }
    }

    private func _setParent(_ parent: Entity?, _ siblingIndex: Int? = nil) {
        let oldParent = _parent
        if (parent !== oldParent) {
            _removeFromParent()
            _parent = parent
            if (parent != nil) {
                parent!._addToChildrenList(siblingIndex, self)

                let parentScene = parent!._scene
                if (_scene !== parentScene) {
                    Entity._traverseSetOwnerScene(self, parentScene)
                }

                if (parent!._isActiveInHierarchy) {
                    if !_isActiveInHierarchy && _isActive {
                        _processActive()
                    }
                } else {
                    if _isActiveInHierarchy {
                        _processInActive()
                    }
                }
            } else {
                if _isActiveInHierarchy {
                    _processInActive()
                }
                if (oldParent != nil) {
                    Entity._traverseSetOwnerScene(self, nil)
                }
            }
            transform._parentChange()
        }
    }

    private func _getComponentsInChildren<T: Component>(_ results: inout [T]) {
        for component in _components {
            if (component is T) {
                results.append(component as! T)
            }
        }

        for child in _children {
            child._getComponentsInChildren(&results)
        }
    }

    private func _setActiveComponents(_ isActive: Bool) {
        for activeChangedComponent in _activeChangedComponents {
            activeChangedComponent._setActive(isActive)
        }

        _engine._componentsManager.putActiveChangedTempList(&_activeChangedComponents)
        _activeChangedComponents = []
    }

    private func _setActiveInHierarchy(_ activeChangedComponents: inout [Component]) {
        _isActiveInHierarchy = true
        for component in _components {
            if component.enabled || !component._awoken {
                activeChangedComponents.append(component)
            }
        }
        for child in _children {
            if child.isActive {
                child._setActiveInHierarchy(&activeChangedComponents)
            }
        }
    }

    private func _setInActiveInHierarchy(_ activeChangedComponents: inout [Component]) {
        _isActiveInHierarchy = false
        for component in _components {
            if component.enabled {
                activeChangedComponents.append(component)
            }
        }
        for child in _children {
            if child.isActive {
                child._setInActiveInHierarchy(&activeChangedComponents)
            }
        }
    }

    private func _setSiblingIndex(_ sibling: inout [Entity], _ target: Int) {
        let target = Swift.min(target, sibling.count - 1)
        if (target < 0) {
            fatalError()
        }
        if (_siblingIndex != target) {
            let oldIndex = _siblingIndex
            if (target < oldIndex) {
                for i in target...oldIndex {
                    let child = i == target ? self : sibling[i - 1]
                    sibling[i] = child
                    child._siblingIndex = i
                }
            } else {
                for i in oldIndex...target {
                    let child = i == target ? self : sibling[i + 1]
                    sibling[i] = child
                    child._siblingIndex = i
                }
            }
        }
    }
}

//MARK: - Static Methods

extension Entity {
    internal static func _findChildByName(_ root: [Entity], _ name: String) -> [Entity] {
        var result: [Entity] = []
        for entity in root {
            for child in entity._children {
                if (child.name == name) {
                    result.append(child)
                }
            }
        }
        return result
    }

    internal static func _traverseSetOwnerScene(_ entity: Entity, _ scene: Scene?) {
        entity._scene = scene
        for child in entity._children {
            _traverseSetOwnerScene(child, scene)
        }
    }
}

//MARK: - Depreciation
extension Entity {
    func getInvModelMatrix() -> Matrix {
        if (_inverseWorldMatFlag.flag) {
            _invModelMatrix = Matrix.invert(a: transform.worldMatrix)
            _inverseWorldMatFlag.flag = false
        }
        return _invModelMatrix
    }
}
