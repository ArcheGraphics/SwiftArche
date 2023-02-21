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
        _initialize(material._pxMaterial, uniqueID)
        _setLocalPose()
    }
    
    var position: [Vector3] {
        get {
            var valueInternal = [simd_float3](repeating: simd_float3(), count: Int((_pxGeometry as! CPxMeshGeometry).positionCount()))
            (_pxGeometry as! CPxMeshGeometry).getPosition(&valueInternal)
            
            var value: [Vector3] = []
            value.reserveCapacity(valueInternal.count)
            for v in valueInternal {
                value.append(Vector3(v))
            }
            return value
        }
    }
    
    var wireframeIndices: [UInt32] {
        get {
            var value = [UInt32](repeating: 0, count: Int((_pxGeometry as! CPxMeshGeometry).indicesCount()))
            (_pxGeometry as! CPxMeshGeometry).getWireframeIndices(&value)
            return value
        }
    }

    func createConvexMesh(_ points: inout [Vector3]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: &points, pointsCount: UInt32(points.count),
                                                     indices: nil, indicesCount: 0, isUint16: false, isConvex: true)
        _initialize(_pxMaterial, _id)
        _setLocalPose()
    }

    func createTriangleMesh(_ points: inout [Vector3]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: &points, pointsCount: UInt32(points.count),
                                                     indices: nil, indicesCount: 0, isUint16: false, isConvex: false)
        _initialize(_pxMaterial, _id)
        _setLocalPose()
    }

    func createTriangleMesh(_ points: inout [Vector3], _ indices: inout [UInt16]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: &points, pointsCount: UInt32(points.count),
                                                     indices: &indices, indicesCount: UInt32(indices.count), isUint16: true, isConvex: false)
        _initialize(_pxMaterial, _id)
        _setLocalPose()
    }

    func createTriangleMesh(_ points: inout [Vector3], _ indices: inout [UInt32]) {
        (_pxGeometry as! CPxMeshGeometry).createMesh(PhysXPhysics._pxPhysics, points: &points, pointsCount: UInt32(points.count),
                                                     indices: &indices, indicesCount: UInt32(indices.count), isUint16: false, isConvex: false)
        _initialize(_pxMaterial, _id)
        _setLocalPose()
    }
    
    func setCookParamter(_ param: UInt8) {
        (_pxGeometry as! CPxMeshGeometry).setCookParameter(PhysXPhysics._pxPhysics, value: param)
        _initialize(_pxMaterial, _id)
        _setLocalPose()
    }

    override func setWorldScale(_ scale: Vector3) {
        (_pxGeometry as! CPxMeshGeometry).setScaleWith(scale.x, hy: scale.y, hz: scale.z)
    }
}
