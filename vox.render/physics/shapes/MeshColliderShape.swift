//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape mesh.
public class MeshColliderShape: ColliderShape {
    private var _mesh: ModelMesh?

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

    @Serialized(default: false)
    public var isConvex: Bool {
        didSet {
            if isConvex != oldValue {
                if _mesh != nil {
                    _cook()
                }
            }
        }
    }

    @Serialized(default: 0)
    public var cookingOptions: UInt8 {
        didSet {
            (_nativeShape as! PhysXMeshColliderShape).setCookParamter(cookingOptions)
        }
    }

    public var colliderPoints: [Vector3] {
        (_nativeShape as! PhysXMeshColliderShape).position
    }

    public var colliderWireframeIndices: [UInt32] {
        (_nativeShape as! PhysXMeshColliderShape).wireframeIndices
    }

    public required init() {
        super.init()
        _nativeShape = PhysXPhysics.createMeshColliderShape(
            _id,
            material._nativeMaterial
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
