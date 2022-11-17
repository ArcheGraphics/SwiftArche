//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXCharacterController {
    var _id: UInt32!
    var _pxController: CPxController!
    var _pxManager: PhysXPhysicsManager!
    var _shape: PhysXColliderShape!

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _pxController.move(disp.internalValue, minDist, elapsedTime)
    }

    func setWorldPosition(_ position: Vector3) {
        if _pxController != nil {
            _pxController.setPosition(position.internalValue)
        }
    }

    func getWorldPosition() -> Vector3 {
        Vector3(_pxController.getPosition())
    }

    func setStepOffset(_ offset: Float) {
        _pxController.setStepOffset(offset)
    }

    func setNonWalkableMode(_ flag: Int) {
        _pxController.setNonWalkableMode(CPxControllerNonWalkableMode(UInt32(flag)))
    }

    func setUpDirection(_ up: Vector3) {
        _pxController.setUpDirection(up.internalValue)
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        _pxController.setSlopeLimit(slopeLimit)
    }

    func addShape(shape: PhysXColliderShape) {
        if _pxManager != nil {
            _createPXController(_pxManager, shape)
        }
        _shape = shape
        shape._controllers.add(self)
    }

    func removeShape(shape: PhysXColliderShape) {
        _destroyPXController()
        _shape = nil
        shape._controllers.delete(self)
    }

    func _createPXController(_ pxManager: PhysXPhysicsManager, _ shape: PhysXColliderShape) {
        if (shape is PhysXBoxColliderShape) {
            let desc = CPxBoxControllerDesc()
            desc.halfHeight = (shape as! PhysXBoxColliderShape)._halfSize.x
            desc.halfSideExtent = (shape as! PhysXBoxColliderShape)._halfSize.y
            desc.halfForwardExtent = (shape as! PhysXBoxColliderShape)._halfSize.z
            desc.material = shape._pxMaterial
            _pxController = pxManager._getControllerManager().createController(desc)
        } else if (shape is PhysXCapsuleColliderShape) {
            let desc = CPxCapsuleControllerDesc()
            desc.radius = (shape as! PhysXCapsuleColliderShape)._radius
            desc.height = (shape as! PhysXCapsuleColliderShape)._halfHeight * 2
            desc.climbingMode = CPxCapsuleClimbingMode(1) // constraint mode
            desc.material = shape._pxMaterial
            _pxController = pxManager._getControllerManager().createController(desc)
        } else {
            fatalError("unsupported shape type")
        }

        _pxController.setQueryFilterData(shape._id, w1: 0, w2: 0, w3: 0)
    }

    func _destroyPXController() {
        if (_pxController != nil) {
            _pxController = nil
        }
    }
}
