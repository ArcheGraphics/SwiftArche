//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// A physics manager is a collection of bodies and constraints which can interact.
public class PhysicsManager {
    private var _engine: Engine
    private var _restTime: Float = 0
    private var _colliders: DisorderedArray<Collider> = DisorderedArray()
    private var _gravity: Vector3 = Vector3(0, -9.81, 0)
    private var _nativePhysicsManager: PhysXPhysicsManager!
    private var _physicalObjectsMap: [UInt32: ColliderShape] = [:]

    /// The fixed time step in seconds at which physics are performed.
    public var fixedTimeStep: Float = 1 / 60

    /// The max sum of time step in seconds one frame.
    public var maxSumTimeStep: Float = 1 / 3

    /// The gravity of physics scene.
    public var gravity: Vector3 {
        get {
            _gravity
        }
        set {
            _gravity = newValue
            _nativePhysicsManager.setGravity(gravity)
        }
    }

    init(engine: Engine) {
        _engine = engine
        PhysXPhysics.initialization()
        _nativePhysicsManager = PhysXPhysics.createPhysicsManager(
                { (obj1: UInt32, obj2: UInt32, info: [ContactInfo]) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionEnter(Collision(shape: shape2!, contacts: info))
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionEnter(Collision(shape: shape1!, contacts: info))
                    }
                },
                { (obj1: UInt32, obj2: UInt32, info: [ContactInfo]) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionExit(Collision(shape: shape2!, contacts: info))
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionExit(Collision(shape: shape1!, contacts: info))
                    }
                },
                { (obj1: UInt32, obj2: UInt32, info: [ContactInfo]) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionStay(Collision(shape: shape2!, contacts: info))
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onCollisionStay(Collision(shape: shape1!, contacts: info))
                    }
                },
                { (obj1: UInt32, obj2: UInt32) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerEnter(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerEnter(shape1!)
                    }
                },
                { (obj1: UInt32, obj2: UInt32) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerExit(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerExit(shape1!)
                    }
                },
                { (obj1: UInt32, obj2: UInt32) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var scripts = shape1!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerStay(shape2!)
                    }

                    scripts = shape2!.collider!.entity._scripts
                    for i in 0..<scripts.count {
                        scripts.get(i)!.onTriggerStay(shape1!)
                    }
                },
                { (obj1: UInt32, obj2: UInt32, name: String) in
                    let shape1 = self._physicalObjectsMap[obj1]
                    let shape2 = self._physicalObjectsMap[obj2]

                    var joints: [Joint] = shape1!.collider!.entity.getComponents()
                    for i in 0..<joints.count {
                        if joints[i].name == name {
                            joints[i].destroy()
                        }
                    }

                    joints = shape2!.collider!.entity.getComponents()
                    for i in 0..<joints.count {
                        if joints[i].name == name {
                            joints[i].destroy()
                        }
                    }
                }
        )
    }

    /// Call on every frame to update pose of objects.
    func _update(_  deltaTime: Float) {
        let componentsManager = _engine._componentsManager

        let simulateTime = deltaTime + _restTime
        let step: Int = Int(floor(min(maxSumTimeStep, simulateTime) / fixedTimeStep))
        _restTime = simulateTime - Float(step) * fixedTimeStep
        for _ in 0..<step {
            componentsManager.callScriptOnPhysicsUpdate()
            _callColliderOnUpdate()
            _nativePhysicsManager.update(fixedTimeStep)
            _callColliderOnLateUpdate()
        }
    }

    /// Add ColliderShape into the manager.
    /// - Parameter colliderShape: The Collider Shape.
    func _addColliderShape(_  colliderShape: ColliderShape) {
        _physicalObjectsMap[colliderShape.id] = colliderShape
        _nativePhysicsManager.addColliderShape(colliderShape._nativeShape)
    }

    /// Remove ColliderShape.
    /// - Parameter colliderShape: The Collider Shape.
    func _removeColliderShape(_ colliderShape: ColliderShape) {
        _physicalObjectsMap.removeValue(forKey: colliderShape.id)
        _nativePhysicsManager.removeColliderShape(colliderShape._nativeShape)
    }

    /// Add collider into the manager.
    /// - Parameter collider: StaticCollider or DynamicCollider.
    func _addCollider(_  collider: Collider) {
        if (collider._index == -1) {
            collider._index = _colliders.count
            _colliders.add(collider)
        }
        _nativePhysicsManager.addCollider(collider._nativeCollider)
    }

    /// Remove collider.
    /// - Parameter collider: StaticCollider or DynamicCollider.
    func _removeCollider(_  collider: Collider) {
        let replaced = _colliders.deleteByIndex(collider._index)
        if replaced != nil {
            replaced!._index = collider._index
        }
        collider._index = -1
        _nativePhysicsManager.removeCollider(collider._nativeCollider)
    }

    /// Add CharacterController into the manager.
    /// - Parameter controller: The Character Controller.
    func _addCharacterController(_  controller: CharacterController) {
        if (controller._index == -1) {
            controller._index = _colliders.count
            _colliders.add(controller)
        }
        _nativePhysicsManager.addCharacterController(controller._nativeCollider as! PhysXCharacterController)
    }

    /// Remove CharacterController.
    /// - Parameter controller: The Character Controller.
    func _removeCharacterController(_ controller: CharacterController) {
        let replaced = _colliders.deleteByIndex(controller._index)
        if replaced != nil {
            replaced!._index = controller._index
        }
        controller._index = -1
        _nativePhysicsManager.removeCharacterController(controller._nativeCollider as! PhysXCharacterController)
    }

    func _callColliderOnUpdate() {
        let elements = _colliders._elements
        for i in 0..<_colliders.count {
            elements[i]!._onUpdate()
        }
    }

    func _callColliderOnLateUpdate() {
        let elements = _colliders._elements
        for i in 0..<_colliders.count {
            elements[i]!._onLateUpdate()
        }
    }
}

//MARK: - Raycast

extension PhysicsManager {
    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    public func raycast(_ ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                        layerMask: Layer = Layer.Everything) -> Bool {
        let onRaycast = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        return _nativePhysicsManager.hasRaycast(ray, distance, onRaycast)
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    public func raycast(_ ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                        layerMask: Layer = Layer.Everything) -> HitResult? {
        let onRaycast = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        var hitResult = HitResult()
        let result = _nativePhysicsManager.raycast(ray, distance, onRaycast, { [self](info) in
            hitResult.colliderShape = _physicalObjectsMap[info.index]
            hitResult.collider = hitResult.colliderShape!._collider
            hitResult.entity = hitResult.collider!.entity
            hitResult.distance = info.distance
            hitResult.normal = Vector3(info.normal)
            hitResult.point = Vector3(info.position)
        })

        if (result) {
            return hitResult
        } else {
            return nil
        }
    }

    public func raycastAll(_ ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                           layerMask: Layer = Layer.Everything) -> [HitResult] {
        let onRaycast = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        let result = _nativePhysicsManager.raycastAll(ray, distance, onRaycast)

        var hitResults: [HitResult] = []
        hitResults.reserveCapacity(result.count)
        for info in result {
            var hit = HitResult()
            hit.entity = _physicalObjectsMap[info.index]!._collider!.entity
            hit.distance = info.distance
            hit.normal = Vector3(info.normal)
            hit.point = Vector3(info.position)
            hitResults.append(hit)
        }
        return hitResults
    }
}

//MARK: - Sweep

extension PhysicsManager {
    public func sweep(_ shape: ColliderShape, ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                      layerMask: Layer = Layer.Everything) -> Bool {
        let onSweep = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        return _nativePhysicsManager.hasSweep(shape._nativeShape, ray, distance, onSweep)
    }

    /// Casts a ray through the Scene and returns the first hit.
    /// - Parameters:
    ///   - ray: The ray
    ///   - distance: The max distance the ray should check
    ///   - layerMask: Layer mask that is used to selectively ignore Colliders when casting
    ///   - outHitResult: If true is returned, outHitResult will contain more detailed collision information
    /// - Returns: Returns true if the ray intersects with a Collider, otherwise false.
    public func sweep(_ shape: ColliderShape, ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                      layerMask: Layer = Layer.Everything) -> HitResult? {
        let onSweep = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        var hitResult = HitResult()
        let result = _nativePhysicsManager.sweep(shape._nativeShape, ray, distance, onSweep, { [self](info) in
            hitResult.colliderShape = _physicalObjectsMap[info.index]
            hitResult.collider = hitResult.colliderShape!.collider
            hitResult.entity = hitResult.collider!.entity
            hitResult.distance = info.distance
            hitResult.normal = Vector3(info.normal)
            hitResult.point = Vector3(info.position)
        })

        if (result) {
            return hitResult
        } else {
            return nil
        }
    }

    public func sweepAll(_ shape: ColliderShape, ray: Ray, distance: Float = Float.greatestFiniteMagnitude,
                         layerMask: Layer = Layer.Everything) -> [HitResult] {
        let onSweep = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        let result = _nativePhysicsManager.sweepAll(shape._nativeShape, ray, distance, onSweep)

        var hitResults: [HitResult] = []
        hitResults.reserveCapacity(result.count)
        for info in result {
            var hit = HitResult()
            hit.entity = _physicalObjectsMap[info.index]!._collider!.entity
            hit.distance = info.distance
            hit.normal = Vector3(info.normal)
            hit.point = Vector3(info.position)
            hitResults.append(hit)
        }
        return hitResults
    }
}

//MARK: - Overlap

extension PhysicsManager {
    public func overlap(_ shape: ColliderShape, origin: Vector3,
                        layerMask: Layer = Layer.Everything) -> Bool {
        let onOverlap = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        return _nativePhysicsManager.hasOverlap(shape._nativeShape, origin, onOverlap)
    }

    public func overlapAll(_ shape: ColliderShape, origin: Vector3,
                           layerMask: Layer = Layer.Everything) -> [ColliderShape] {
        let onOverlap = { (obj: UInt32) -> Bool in
            let shape = self._physicalObjectsMap[obj]!
            return (shape.collider!.entity.layer.rawValue & layerMask.rawValue != 0) && shape.isSceneQuery
        }
        let result = _nativePhysicsManager.overlapAll(shape._nativeShape, origin, onOverlap)

        var hitResults: [ColliderShape] = []
        hitResults.reserveCapacity(result.count)
        for info in result {
            hitResults.append(_physicalObjectsMap[info.index]!)
        }
        return hitResults
    }
}
