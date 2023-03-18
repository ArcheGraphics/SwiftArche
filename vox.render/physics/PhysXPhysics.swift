//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// PhysX object creation.
class PhysXPhysics {
    /// Physx physics object
    internal static var _pxPhysics: CPxPhysics!

    static func initialization() {
        _pxPhysics = CPxPhysics()
    }
    
    static func destroy() {
        _pxPhysics.destroy()
    }

    static func createPhysicsManager(_ onContactEnter: ((UInt32, UInt32, [ContactInfo]) -> Void)?,
                                     _ onContactExit: ((UInt32, UInt32, [ContactInfo]) -> Void)?,
                                     _ onContactStay: ((UInt32, UInt32, [ContactInfo]) -> Void)?,
                                     _ onTriggerEnter: ((UInt32, UInt32) -> Void)?,
                                     _ onTriggerExit: ((UInt32, UInt32) -> Void)?,
                                     _ onTriggerStay: ((UInt32, UInt32) -> Void)?,
                                     _ onJointBreak: ((UInt32, UInt32, String) -> Void)?) -> PhysXPhysicsManager {
        PhysXPhysicsManager(onContactEnter, onContactExit, onContactStay,
                onTriggerEnter, onTriggerExit, onTriggerStay, onJointBreak)
    }

    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> PhysXDynamicCollider {
        PhysXDynamicCollider(position, rotation)
    }

    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> PhysXStaticCollider {
        PhysXStaticCollider(position, rotation)
    }

    static func createCharacterController() -> PhysXCharacterController {
        PhysXCharacterController()
    }

    static func createPhysicsMaterial(_ staticFriction: Float,
                                      _ dynamicFriction: Float,
                                      _ bounciness: Float,
                                      _ frictionCombine: Int,
                                      _ bounceCombine: Int) -> PhysXPhysicsMaterial {
        PhysXPhysicsMaterial(staticFriction, dynamicFriction, bounciness,
                CombineMode(rawValue: frictionCombine)!,
                CombineMode(rawValue: bounceCombine)!)
    }

    //MARK: - Collider Shape

    static func createBoxColliderShape(_ uniqueID: UInt32, _ size: Vector3,
                                       _ material: PhysXPhysicsMaterial) -> PhysXBoxColliderShape {
        PhysXBoxColliderShape(uniqueID, size, material)
    }

    static func createSphereColliderShape(_ uniqueID: UInt32, _ radius: Float,
                                          _ material: PhysXPhysicsMaterial) -> PhysXSphereColliderShape {
        PhysXSphereColliderShape(uniqueID, radius, material)
    }

    static func createPlaneColliderShape(_ uniqueID: UInt32,
                                         _ material: PhysXPhysicsMaterial) -> PhysXPlaneColliderShape {
        PhysXPlaneColliderShape(uniqueID, material)
    }

    static func createCapsuleColliderShape(_ uniqueID: UInt32, _ radius: Float, _ height: Float,
                                           _ material: PhysXPhysicsMaterial) -> PhysXCapsuleColliderShape {
        PhysXCapsuleColliderShape(uniqueID, radius, height, material)
    }

    static func createMeshColliderShape(_ uniqueID: UInt32,
                                        _ material: PhysXPhysicsMaterial) -> PhysXMeshColliderShape {
        PhysXMeshColliderShape(uniqueID, material)
    }

    //MARK: - Joint

    static func createFixedJoint(_ collider: PhysXCollider) -> PhysXFixedJoint {
        PhysXFixedJoint(collider)
    }

    static func createHingeJoint(_ collider: PhysXCollider) -> PhysXHingeJoint {
        PhysXHingeJoint(collider)
    }

    static func createSpringJoint(_ collider: PhysXCollider) -> PhysXSpringJoint {
        PhysXSpringJoint(collider)
    }
}
