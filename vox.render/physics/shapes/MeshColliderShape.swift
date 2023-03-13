//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape mesh.
public class MeshColliderShape: ColliderShape {
    private var _isConvex = false
    private var _mesh: ModelMesh?
    private var _cookingOptions: UInt8 = 0

    public var isConvex: Bool {
        get {
            _isConvex
        }
        set {
            if _isConvex != newValue {
                _isConvex = newValue
                if _mesh != nil {
                    _cook()
                }
            }
        }
    }

    public var mesh: ModelMesh? {
        get {
            _mesh
        }
        set {
            if _mesh !== newValue {
                _mesh = newValue
                _cook()
            }
        }
    }

    public var cookingOptions: UInt8 {
        get {
            _cookingOptions
        }
        set {
            if _cookingOptions != newValue {
                _cookingOptions = newValue
                (_nativeShape as! PhysXMeshColliderShape).setCookParamter(newValue)
            }
        }
    }
    
    public var colliderPoints: [Vector3] {
        get {
            (_nativeShape as! PhysXMeshColliderShape).position
        }
    }
    
    public var colliderWireframeIndices: [UInt32] {
        get {
            (_nativeShape as! PhysXMeshColliderShape).wireframeIndices
        }
    }

    public override init() {
        super.init()
        _nativeShape = PhysXPhysics.createMeshColliderShape(
                _id,
                _material._nativeMaterial
        )
    }
    
    /// special API should not change cookingOptions after call
    public func cookConvexHull(_ convexHull: inout ConvexHull) {
        (_nativeShape as! PhysXMeshColliderShape).cookConvexHull(&convexHull)
    }

    private func _cook() {
        if let mesh = _mesh {
            var points = mesh.getPositions()!
            if isConvex {
                (_nativeShape as! PhysXMeshColliderShape).createConvexMesh(&points)
            } else {
                let indices16: [UInt16]? = mesh.getIndices()
                let indices32: [UInt32]? = mesh.getIndices()
                if var indices = indices16 {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(&points, &indices)
                } else if var indices = indices32 {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(&points, &indices)
                } else {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(&points)
                }
            }
        }
    }
}
