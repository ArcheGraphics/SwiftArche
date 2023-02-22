//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Filtering flags for scene queries.
enum QueryFlag: Int {
    case STATIC = 1
    case DYNAMIC = 2
    case ANY_HIT = 8
    case NO_BLOCK = 32
}

/// A manager is a collection of bodies and constraints which can interact.
class PhysXPhysicsManager {
    var _pxControllerManager: CPxControllerManager?
    private var _pxScene: CPxScene!

    private var _onContactEnter: ((UInt32, UInt32) -> Void)!
    private var _onContactExit: ((UInt32, UInt32) -> Void)!
    private var _onContactStay: ((UInt32, UInt32) -> Void)!
    private var _onTriggerEnter: ((UInt32, UInt32) -> Void)!
    private var _onTriggerExit: ((UInt32, UInt32) -> Void)!
    private var _onTriggerStay: ((UInt32, UInt32) -> Void)!

    private var _currentEvents: DisorderedArray<TriggerEvent> = DisorderedArray()
    private var _eventMap: [UInt32: [UInt32: TriggerEvent]] = [:]
    private var _eventPool: [TriggerEvent] = []
    private var _queryPool: [LocationHit] = []

    init(_ onContactEnter: ((UInt32, UInt32) -> Void)?,
         _ onContactExit: ((UInt32, UInt32) -> Void)?,
         _ onContactStay: ((UInt32, UInt32) -> Void)?,
         _ onTriggerEnter: ((UInt32, UInt32) -> Void)?,
         _ onTriggerExit: ((UInt32, UInt32) -> Void)?,
         _ onTriggerStay: ((UInt32, UInt32) -> Void)?) {
        _onContactEnter = onContactEnter
        _onContactExit = onContactExit
        _onContactStay = onContactStay
        _onTriggerEnter = onTriggerEnter
        _onTriggerExit = onTriggerExit
        _onTriggerStay = onTriggerStay

        _queryPool = [LocationHit](repeating: LocationHit(), count: 8)

        _pxScene = PhysXPhysics._pxPhysics.createScene(
                {
                    [self] (index1: UInt32, index2: UInt32) in
                    _onContactEnter(index1, index2)
                },
                onContactExit: {
                    [self] (index1: UInt32, index2: UInt32) in
                    _onContactExit(index1, index2)
                },
                onContactStay: {
                    [self] (index1: UInt32, index2: UInt32) in
                    _onContactStay(index1, index2)
                },
                onTriggerEnter: {
                    [self] (index1: UInt32, index2: UInt32) in
                    let event = index1 < index2 ? _getTrigger(index1, index2) : _getTrigger(index2, index1)
                    event.state = TriggerEventState.Enter
                    _currentEvents.add(event)
                },
                onTriggerExit: {
                    [self] (index1: UInt32, index2: UInt32) in
                    let event: TriggerEvent
                    if (index1 < index2) {
                        let subMap = _eventMap[index1]
                        event = subMap![index2]!
                        _eventMap[index1]!.removeValue(forKey: index2)
                    } else {
                        let subMap = _eventMap[index2]
                        event = subMap![index1]!
                        _eventMap[index2]!.removeValue(forKey: index1)
                    }
                    event.state = TriggerEventState.Exit
                }
        )
    }

    func setGravity(_ gravity: Vector3) {
        _pxScene.setGravity(gravity.internalValue)
    }

    func addColliderShape(_ colliderShape: PhysXColliderShape) {
        _eventMap[colliderShape._id!] = [:]
    }

    func removeColliderShape(_ colliderShape: PhysXColliderShape) {
        for i in 0..<_currentEvents.count {
            let event = _currentEvents.get(i)!
            if (event.index1 == colliderShape._id || event.index2 == colliderShape._id) {
                _ = _currentEvents.deleteByIndex(i)
                _eventPool.append(event)
            }
        }
        _eventMap.removeValue(forKey: colliderShape._id!)
    }

    func addCollider(_ collider: PhysXCollider) {
        _pxScene.addActor(with: collider._pxActor)
    }

    func removeCollider(_ collider: PhysXCollider) {
        _pxScene.removeActor(with: collider._pxActor)
    }

    func addCharacterController(_ characterController: PhysXCharacterController) {
        let lastPXManager = characterController._pxManager
        let shape = characterController._shape
        if (shape != nil) {
            if (lastPXManager !== self) {
                if lastPXManager != nil {
                    characterController._destroyPXController()
                }
                characterController._createPXController(self, shape!)
            }
            _pxScene.addActor(with: characterController._pxController.getActor())
        }
        characterController._pxManager = self
    }

    func removeCharacterController(_ characterController: PhysXCharacterController) {
        if (characterController._shape != nil) {
            _pxScene.removeActor(with: characterController._pxController.getActor())
        }
        characterController._pxManager = nil
    }

    func update(_ elapsedTime: Float) {
        _simulate(elapsedTime)
        _fetchResults()
        _fireEvent()
    }

    func _getControllerManager() -> CPxControllerManager {
        if (_pxControllerManager == nil) {
            _pxControllerManager = _pxScene.createControllerManager()
        }
        return _pxControllerManager!
    }

    private func _simulate(_ elapsedTime: Float) {
        _pxScene.simulate(elapsedTime)
    }

    private func _fetchResults(_ block: Bool = true) {
        _pxScene.fetchResults(block)
    }

    private func _getTrigger(_ index1: UInt32, _ index2: UInt32) -> TriggerEvent {
        var event: TriggerEvent
        if _eventPool.count != 0 {
            event = _eventPool.popLast()!
            event.index1 = index1
            event.index2 = index2
        } else {
            event = TriggerEvent(index1, index2)
        }
        _eventMap[index1]![index2] = event
        return event
    }

    private func _fireEvent() {
        for i in 0..<_currentEvents.count {
            let event = _currentEvents.get(i)!
            if (event.state == TriggerEventState.Enter) {
                _onTriggerEnter(event.index1, event.index2)
                event.state = TriggerEventState.Stay
            } else if (event.state == TriggerEventState.Stay) {
                _onTriggerStay(event.index1, event.index2)
            } else if (event.state == TriggerEventState.Exit) {
                _onTriggerExit(event.index1, event.index2)
                _ = _currentEvents.deleteByIndex(i)
                _eventPool.append(event)
            }
        }
    }
}

extension PhysXPhysicsManager {
    func raycast(_ ray: Ray, _ distance: Float,
                 _ onRaycast: @escaping (UInt32) -> Bool,
                 _ outHitResult: ((LocationHit) -> Void)? = nil) -> Bool {
        var locHit = LocationHit()
        let result = _pxScene.raycastSingle(
                with: ray.origin.internalValue,
                unitDir: ray.direction.internalValue,
                distance: distance,
                hit: &locHit,
                filterCallback: onRaycast
        )

        if (result && outHitResult != nil) {
            outHitResult!(locHit)
        }

        return result
    }

    func raycastAll(_ ray: Ray, _ distance: Float,
                    _ onRaycast: @escaping (UInt32) -> Bool) -> ArraySlice<LocationHit> {
        var result = _pxScene.raycastMultiple(with: ray.origin.internalValue,
                unitDir: ray.direction.internalValue,
                distance: distance, hit: &_queryPool,
                hitCount: UInt32(_queryPool.count),
                filterCallback: onRaycast)
        if (result == -1) {
            while (result == -1) {
                _queryPool = [LocationHit](repeating: LocationHit(), count: 2 * _queryPool.count)
                result = _pxScene.raycastMultiple(with: ray.origin.internalValue,
                        unitDir: ray.direction.internalValue,
                        distance: distance, hit: &_queryPool,
                        hitCount: UInt32(_queryPool.count),
                        filterCallback: onRaycast)
            }
        } else if (result == 0) {
            return []
        }

        return _queryPool[0..<Int(result)]
    }

    func sweep(_ shape: PhysXColliderShape, _ ray: Ray, _ distance: Float,
               _ onRaycast: @escaping (UInt32) -> Bool,
               _ outHitResult: ((LocationHit) -> Void)? = nil) -> Bool {
        var locHit = LocationHit()
        let result = _pxScene.sweepSingle(with: shape._pxShape,
                origin: ray.origin.internalValue,
                unitDir: ray.direction.internalValue,
                distance: distance, hit: &locHit,
                filterCallback: onRaycast)

        if (result && outHitResult != nil) {
            outHitResult!(locHit)
        }

        return result
    }

    func sweepAll(_ shape: PhysXColliderShape, _ ray: Ray, _ distance: Float,
                  _ onRaycast: @escaping (UInt32) -> Bool) -> ArraySlice<LocationHit> {
        var result = _pxScene.sweepMultiple(with: shape._pxShape,
                origin: ray.origin.internalValue,
                unitDir: ray.direction.internalValue,
                distance: distance, hit: &_queryPool,
                hitCount: UInt32(_queryPool.count),
                filterCallback: onRaycast)
        if (result == -1) {
            while (result == -1) {
                _queryPool = [LocationHit](repeating: LocationHit(), count: 2 * _queryPool.count)
                result = _pxScene.sweepMultiple(with: shape._pxShape,
                        origin: ray.origin.internalValue,
                        unitDir: ray.direction.internalValue,
                        distance: distance, hit: &_queryPool,
                        hitCount: UInt32(_queryPool.count),
                        filterCallback: onRaycast)
            }
        } else if (result == 0) {
            return []
        }

        return _queryPool[0..<Int(result)]
    }

    func overlapAll(_ shape: PhysXColliderShape, _ origin: Vector3,
                    _ onRaycast: @escaping (UInt32) -> Bool) -> ArraySlice<LocationHit> {
        var result = _pxScene.overlapMultiple(with: shape._pxShape, origin: origin.internalValue,
                hit: &_queryPool, hitCount: UInt32(_queryPool.count),
                filterCallback: onRaycast)
        if (result == -1) {
            while (result == -1) {
                _queryPool = [LocationHit](repeating: LocationHit(), count: 2 * _queryPool.count)
                result = _pxScene.overlapMultiple(with: shape._pxShape, origin: origin.internalValue,
                        hit: &_queryPool, hitCount: UInt32(_queryPool.count),
                        filterCallback: onRaycast)
            }
        } else if (result == 0) {
            return []
        }

        return _queryPool[0..<Int(result)]
    }
}

/// Physics state
enum TriggerEventState {
    case Enter
    case Stay
    case Exit
}

/// Trigger event to store interactive object ids and state.
class TriggerEvent {
    var state: TriggerEventState
    var index1: UInt32
    var index2: UInt32

    required init() {
        index1 = 0
        index2 = 0
        state = .Exit
    }

    init(_ index1: UInt32, _ index2: UInt32) {
        self.index1 = index1
        self.index2 = index2
        state = .Exit
    }
}
