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
    private var _pxScene: CPxScene!
    private var _onContactEnter: ((Int, Int) -> Void)!
    private var _onContactExit: ((Int, Int) -> Void)!
    private var _onContactStay: ((Int, Int) -> Void)!
    private var _onTriggerEnter: ((Int, Int) -> Void)!
    private var _onTriggerExit: ((Int, Int) -> Void)!
    private var _onTriggerStay: ((Int, Int) -> Void)!

    private var _currentEvents: DisorderedArray<TriggerEvent> = DisorderedArray()
    private var _eventMap: [Int: [Int: TriggerEvent]] = [:]
    private var _eventPool: [TriggerEvent] = []

    init(_ onContactEnter: ((Int, Int) -> Void)?,
         _ onContactExit: ((Int, Int) -> Void)?,
         _ onContactStay: ((Int, Int) -> Void)?,
         _ onTriggerEnter: ((Int, Int) -> Void)?,
         _ onTriggerExit: ((Int, Int) -> Void)?,
         _ onTriggerStay: ((Int, Int) -> Void)?) {
        _onContactEnter = onContactEnter
        _onContactExit = onContactExit
        _onContactStay = onContactStay
        _onTriggerEnter = onTriggerEnter
        _onTriggerExit = onTriggerExit
        _onTriggerStay = onTriggerStay

        _pxScene = PhysXPhysics._pxPhysics.createScene({ (obj1: CPxShape?, obj2: CPxShape?) in },
                onContactExit: { (obj1: CPxShape?, obj2: CPxShape?) in },
                onContactStay: { (obj1: CPxShape?, obj2: CPxShape?) in },
                onTriggerEnter: { [self] (obj1: CPxShape?, obj2: CPxShape?) in
                    let index1 = Int(obj1!.getQueryFilterData(0))
                    let index2 = Int(obj2!.getQueryFilterData(0))
                    let event = index1 < index2 ? _getTrigger(index1, index2) : _getTrigger(index2, index1)
                    event.state = TriggerEventState.Enter
                    _currentEvents.add(event)
                },
                onTriggerExit: { [self] (obj1: CPxShape?, obj2: CPxShape?) in
                    let index1 = Int(obj1!.getQueryFilterData(0))
                    let index2 = Int(obj2!.getQueryFilterData(0))
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
        _eventMap[colliderShape._id] = [:]
    }

    func removeColliderShape(_ colliderShape: PhysXColliderShape) {
        _eventMap.removeValue(forKey: colliderShape._id)
    }

    func addCollider(_ collider: PhysXCollider) {
        _pxScene.addActor(with: collider._pxActor)
    }

    func removeCollider(_ collider: PhysXCollider) {
        _pxScene.removeActor(with: collider._pxActor)
    }

    func addCharacterController(_ characterController: PhysXCharacterController) {
        _eventMap[characterController._id] = [:]
    }

    func removeCharacterController(_ characterController: PhysXCharacterController) {
        _eventMap.removeValue(forKey: characterController._id)
    }

    func createControllerManager() -> PhysXCharacterControllerManager {
        let manager = PhysXCharacterControllerManager()
        manager._pxControllerManager = _pxScene.createControllerManager()
        return manager
    }

    func update(_ elapsedTime: Float) {
        _simulate(elapsedTime)
        _fetchResults()
        _fireEvent()
    }

    func raycast(_ ray: Ray, _ distance: Float,
                 _ outHitResult: ((Int, Float, Vector3, Vector3) -> Void)?) -> Bool {
        var outIndex: Int32 = 0
        var outDistance: Float = 0

        var outPosition = SIMD3<Float>()
        var outNormal = SIMD3<Float>()
        let result = _pxScene.raycastSingle(
                with: ray.origin.internalValue,
                unitDir: ray.direction.internalValue,
                distance: distance,
                outPosition: &outPosition,
                outNormal: &outNormal,
                outDistance: &outDistance,
                outIndex: &outIndex
        )

        if (result && outHitResult != nil) {
            outHitResult!(Int(outIndex), outDistance, Vector3(outPosition), Vector3(outNormal))
        }

        return result
    }

    private func _simulate(_ elapsedTime: Float) {
        _pxScene.simulate(elapsedTime)
    }

    private func _fetchResults(_ block: Bool = true) {
        _pxScene.fetchResults(block)
    }

    private func _getTrigger(_ index1: Int, _ index2: Int) -> TriggerEvent {
        let event = _eventPool.count != 0 ? _eventPool.popLast() : TriggerEvent(index1, index2)
        _eventMap[index1]![index2] = event!
        return event!
    }

    private func _fireEvent() {
        var i = 0
        var n = _currentEvents.length
        while i < n {
            let event = _currentEvents.get(i)!
            if (event.state == TriggerEventState.Enter) {
                _onTriggerEnter!(event.index1, event.index2)
                event.state = TriggerEventState.Stay
                i += 1
            } else if (event.state == TriggerEventState.Stay) {
                _onTriggerStay!(event.index1, event.index2)
                i += 1
            } else if (event.state == TriggerEventState.Exit) {
                _onTriggerExit!(event.index1, event.index2)
                _ = _currentEvents.deleteByIndex(i)
                _eventPool.append(event)
                n -= 1
            }
        }
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
    var index1: Int
    var index2: Int
    var needUpdate: Bool = false

    required init() {
        index1 = 0
        index2 = 0
        state = .Exit
    }

    init(_ index1: Int, _ index2: Int) {
        self.index1 = index1
        self.index2 = index2
        state = .Exit
    }
}