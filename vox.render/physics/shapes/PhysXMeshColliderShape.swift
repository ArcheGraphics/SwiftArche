//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Mesh collider shape in PhysX.
class PhysXMeshColliderShape: PhysXColliderShape {
    /// Init PhysXCollider and alloc PhysX objects.
    /// - Parameters:
    ///   - uniqueID: UniqueID mark collider
    ///   - radius: Size of SphereCollider
    ///   - material: Material of PhysXCollider
    init(_ uniqueID: UInt32, _ material: PhysXPhysicsMaterial) {
        super.init()

        _pxGeometry = CPxMeshGeometry(PhysXPhysics._pxPhysics)
        _initialize(material, uniqueID)
        _setLocalPose()
    }

    func createConvexMesh(_ points: [Vector3]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: nil, isUint16: false, isConvex: true)
    }

    func createConvexMesh(_ points: [Vector3], _ indices: [UInt16]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: indices, isUint16: true, isConvex: true)
    }

    func createConvexMesh(_ points: [Vector3], _ indices: [UInt32]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: indices, isUint16: false, isConvex: true)
    }

    func createTriangleMesh(_ points: [Vector3]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: nil, isUint16: false, isConvex: false)
    }

    func createTriangleMesh(_ points: [Vector3], _ indices: [UInt16]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: indices, isUint16: true, isConvex: false)
    }

    func createTriangleMesh(_ points: [Vector3], _ indices: [UInt32]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: points,
                                                     indices: indices, isUint16: false, isConvex: false)
    }
    
    func setCookParamter(_ param: UInt8) {
        (_pxGeometry as! CPxMeshGeometry).setCookParameter(PhysXPhysics._pxPhysics, value: param)
    }

    override func setWorldScale(_ scale: Vector3) {
        (_pxGeometry as! CPxMeshGeometry).setScaleWith(scale.x, hy: scale.y, hz: scale.z)
    }
}
