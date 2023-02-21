//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Physical collider shape mesh.
public class MeshColliderShape: ColliderShape {
    private var _isConvex = true
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

    public override init() {
        super.init()
        _nativeShape = PhysXPhysics.createMeshColliderShape(
                _id,
                _material._nativeMaterial
        )
    }

    private func _cook() {
        if let mesh = _mesh {
            let points = mesh.getPositions()!
            let indices16: [UInt16]? = mesh.getIndices()
            let indices32: [UInt32]? = mesh.getIndices()
            if let indices = indices16 {
                if isConvex {
                    (_nativeShape as! PhysXMeshColliderShape).createConvexMesh(points, indices)
                } else {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(points, indices)
                }
            } else if let indices = indices32 {
                if isConvex {
                    (_nativeShape as! PhysXMeshColliderShape).createConvexMesh(points, indices)
                } else {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(points, indices)
                }
            } else {
                if isConvex {
                    (_nativeShape as! PhysXMeshColliderShape).createConvexMesh(points)
                } else {
                    (_nativeShape as! PhysXMeshColliderShape).createTriangleMesh(points)
                }
            }
        }
    }
}
