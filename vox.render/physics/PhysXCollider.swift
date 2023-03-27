//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Abstract class of physical collider.
class PhysXCollider {
    internal var _pxActor: CPxRigidActor!

    func setVisualize(_ value: Bool) {
        _pxActor.setVisualize(value)
    }
    
    func addShape(_ shape: PhysXColliderShape) {
        _pxActor.attachShape(with: shape._pxShape)
    }

    func removeShape(_ shape: PhysXColliderShape) {
        _pxActor.detachShape(with: shape._pxShape)
    }

    func setWorldTransform(_ position: Vector3, _ rotation: Quaternion) {
        _pxActor.setGlobalPose(position.internalValue, rotation: rotation.normalized.internalValue)
    }

    func getWorldTransform(_ outPosition: inout Vector3, _ outRotation: inout Quaternion) {
        var position = SIMD3<Float>()
        var rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        _pxActor.getGlobalPose(&position, rotation: &rotation)
        outPosition = Vector3(position)
        outRotation = Quaternion(rotation)
    }

    func getGroup() -> UInt16 {
        _pxActor.getGroup()
    }

    func setGroup(_ collisionGroup: UInt16) {
        _pxActor.setGroup(collisionGroup)
    }
}
