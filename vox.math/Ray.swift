//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Represents a ray with an origin and a direction in 3D space.
public class Ray {
    /// The origin of the ray.
    public var origin: Vector3 = Vector3()
    /// The normalized direction of the ray.
    public var direction: Vector3 = Vector3()

    /// Constructor of Ray.
    /// - Parameters:
    ///   - origin: The origin vector
    ///   - direction: The direction vector
    public init(origin: Vector3? = nil, direction: Vector3? = nil) {
        if origin != nil {
            self.origin = origin!
        }
        if direction != nil {
            self.direction = direction!
        }
    }
}

extension Ray {
    /// Check if this ray intersects the specified plane.
    /// - Parameter plane: The specified plane
    /// - Returns: The distance from this ray to the specified plane if intersecting, -1 otherwise
    public func intersectPlane(plane: Plane) -> Float {
        CollisionUtil.intersectsRayAndPlane(ray: self, plane: plane)
    }

    /// Check if this ray intersects the specified sphere.
    /// - Parameter sphere: The specified sphere
    /// - Returns: The distance from this ray to the specified sphere if intersecting, -1 otherwise
    public func intersectSphere(sphere: BoundingSphere) -> Float {
        CollisionUtil.intersectsRayAndSphere(ray: self, sphere: sphere)
    }

    /// Check if this ray intersects the specified box (AABB).
    /// - Parameter box: The specified box
    /// - Returns: The distance from this ray to the specified box if intersecting, -1 otherwise
    public func intersectBox(box: BoundingBox) -> Float {
        CollisionUtil.intersectsRayAndBox(ray: self, box: box)
    }

    /// The coordinates of the specified distance from the origin in the ray direction.
    /// - Parameters:
    ///   - distance:  The specified distance
    /// - Returns: The out
    public func getPoint(distance: Float) -> Vector3 {
        direction * distance + origin
    }
}
