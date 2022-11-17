//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// PhysX object creation.
class PhysXPhysics {
    /// Physx physics object
    internal static var _pxPhysics: CPxPhysics!

    static func initialization() {
        _pxPhysics = CPxPhysics()
        _pxPhysics.initExtensions()
    }

    static func createPhysicsManager(_ onContactEnter: ((Int, Int) -> Void)?,
                                     _ onContactExit: ((Int, Int) -> Void)?,
                                     _ onContactStay: ((Int, Int) -> Void)?,
                                     _ onTriggerEnter: ((Int, Int) -> Void)?,
                                     _ onTriggerExit: ((Int, Int) -> Void)?,
                                     _ onTriggerStay: ((Int, Int) -> Void)?) -> PhysXPhysicsManager {
        PhysXPhysicsManager(onContactEnter, onContactExit, onContactStay,
                onTriggerEnter, onTriggerExit, onTriggerStay)
    }

    static func createDynamicCollider(_ position: Vector3, _ rotation: Quaternion) -> PhysXDynamicCollider {
        PhysXDynamicCollider(position, rotation)
    }

    static func createStaticCollider(_ position: Vector3, _ rotation: Quaternion) -> PhysXStaticCollider {
        PhysXStaticCollider(position, rotation)
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

    static func createBoxColliderShape(_ uniqueID: Int, _ size: Vector3,
                                       _ material: PhysXPhysicsMaterial) -> PhysXBoxColliderShape {
        PhysXBoxColliderShape(uniqueID, size, material)
    }

    static func createSphereColliderShape(_ uniqueID: Int, _ radius: Float,
                                          _ material: PhysXPhysicsMaterial) -> PhysXSphereColliderShape {
        PhysXSphereColliderShape(uniqueID, radius, material)
    }

    static func createPlaneColliderShape(_ uniqueID: Int,
                                         _ material: PhysXPhysicsMaterial) -> PhysXPlaneColliderShape {
        PhysXPlaneColliderShape(uniqueID, material)
    }

    static func createCapsuleColliderShape(_ uniqueID: Int, _ radius: Float, _ height: Float,
                                           _ material: PhysXPhysicsMaterial) -> PhysXCapsuleColliderShape {
        PhysXCapsuleColliderShape(uniqueID, radius, height, material)
    }

    //MARK: - Joint

    static func createFixedJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXFixedJoint {
        PhysXFixedJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    static func createHingeJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                 _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXHingeJoint {
        PhysXHingeJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    static func createSphericalJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                     _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXSphericalJoint {
        PhysXSphericalJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    static func createSpringJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                  _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXSpringJoint {
        PhysXSpringJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    static func createTranslationalJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXTranslationalJoint {
        PhysXTranslationalJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    static func createConfigurableJoint(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
                                        _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) -> PhysXConfigurableJoint {
        PhysXConfigurableJoint((actor0 ?? nil), position0, rotation0, (actor1 ?? nil), position1, rotation1)
    }

    //MARK: - Character Controller

    static func createBoxCharacterControllerDesc() -> PhysXBoxCharacterControllerDesc {
        PhysXBoxCharacterControllerDesc()
    }

    static func createCapsuleCharacterControllerDesc() -> PhysXCapsuleCharacterControllerDesc {
        PhysXCapsuleCharacterControllerDesc()
    }

    static func createBoxObstacle() -> PhysXBoxObstacle {
        PhysXBoxObstacle()
    }

    static func createCapsuleObstacle() -> PhysXCapsuleObstacle {
        PhysXCapsuleObstacle()
    }
}
