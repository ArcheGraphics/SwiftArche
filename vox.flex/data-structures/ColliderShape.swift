//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ColliderShape {
    public enum ShapeType: Int {
        case Sphere = 0,
             Box = 1,
             Capsule = 2,
             Heightmap = 3,
             TriangleMesh = 4,
             EdgeMesh = 5,
             SignedDistanceField = 6
    }

    public var center: Vector4
    /// box: size of the box in each axis.
    /// sphere: radius of sphere (x,y,z),
    /// capsule: radius (x), height(y), direction (z, can be 0, 1 or 2).
    /// heightmap: width (x axis), height (y axis) and depth (z axis) in world units
    public var size: Vector4
    public var type: ShapeType
    public var contactOffset: Float

    public var dataIndex: Int
    /// index of the associated rigidbody in the collision world./
    public var rigidbodyIndex: Int
    /// index of the associated material in the collision world./
    public var materialIndex: Int

    /// bitwise category/mask./
    public var filter: Int
    /// for now, only used for trigger (1) or regular collider (0)./
    public var flags: Int
    /// whether the collider is 2D (1) or 3D (0)./
    public var is2D: Int
}
