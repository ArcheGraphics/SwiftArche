//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Contains static methods to help in determining intersections, containment, etc.
public class CollisionUtil {
    /// Calculate the intersection point of three plane.
    /// - Parameters:
    ///   - p1: Plane 1
    ///   - p2: Plane 2
    ///   - p3: Plane 3
    /// - Returns: intersection point
    public static func intersectionPointThreePlanes(p1: Plane, p2: Plane, p3: Plane) -> Vector3 {
        let p1Nor = p1.normal
        let p2Nor = p2.normal
        let p3Nor = p3.normal

        var tempVec30 = Vector3.cross(left: p2Nor, right: p3Nor)
        var tempVec31 = Vector3.cross(left: p3Nor, right: p1Nor)
        var tempVec32 = Vector3.cross(left: p1Nor, right: p2Nor)

        let a = -Vector3.dot(left: p1Nor, right: tempVec30)
        let b = -Vector3.dot(left: p2Nor, right: tempVec31)
        let c = -Vector3.dot(left: p3Nor, right: tempVec32)

        tempVec30 *= p1.distance / a
        tempVec31 *= p2.distance / b
        tempVec32 *= p3.distance / c

        return tempVec30 + tempVec31 + tempVec32
    }


    /// Calculate the distance from a point to a plane.
    /// - Parameters:
    ///   - plane: The plane
    ///   - point: The point
    /// - Returns: The distance from a point to a plane
    public static func distancePlaneAndPoint(plane: Plane, point: Vector3) -> Float {
        Vector3.dot(left: plane.normal, right: point) + plane.distance
    }

    /// Get the intersection type between a plane and a point.
    /// - Parameters:
    ///   - plane: The plane
    ///   - point: The point
    /// - Returns: The intersection type
    public static func intersectsPlaneAndPoint(plane: Plane, point: Vector3) -> PlaneIntersectionType {
        let distance = CollisionUtil.distancePlaneAndPoint(plane: plane, point: point)
        if (distance > 0) {
            return PlaneIntersectionType.Front
        }
        if (distance < 0) {
            return PlaneIntersectionType.Back
        }
        return PlaneIntersectionType.Intersecting
    }


    /// Get the intersection type between a plane and a box (AABB).
    /// - Parameters:
    ///   - plane: The plane
    ///   - box: The box
    /// - Returns: The intersection type
    public static func intersectsPlaneAndBox(plane: Plane, box: BoundingBox) -> PlaneIntersectionType {
        let min = box.min
        let max = box.max
        let normal = plane.normal
        var front = SIMD3<Float>()
        var back = SIMD3<Float>()

        if (normal.x >= 0) {
            front.x = max.x
            back.x = min.x
        } else {
            front.x = min.x
            back.x = max.x
        }
        if (normal.y >= 0) {
            front.y = max.y
            back.y = min.y
        } else {
            front.y = min.y
            back.y = max.y
        }
        if (normal.z >= 0) {
            front.z = max.z
            back.z = min.z
        } else {
            front.z = min.z
            back.z = max.z
        }

        if (CollisionUtil.distancePlaneAndPoint(plane: plane, point: Vector3(front)) < 0) {
            return PlaneIntersectionType.Back
        }

        if (CollisionUtil.distancePlaneAndPoint(plane: plane, point: Vector3(back)) > 0) {
            return PlaneIntersectionType.Front
        }

        return PlaneIntersectionType.Intersecting
    }

    /// Get the intersection type between a plane and a sphere.
    /// - Parameters:
    ///   - plane: The plane
    ///   - sphere: The sphere
    /// - Returns: The intersection type
    public static func intersectsPlaneAndSphere(plane: Plane, sphere: BoundingSphere) -> PlaneIntersectionType {
        let center = sphere.center
        let radius = sphere.radius
        let distance = CollisionUtil.distancePlaneAndPoint(plane: plane, point: center)
        if (distance > radius) {
            return PlaneIntersectionType.Front
        }
        if (distance < -radius) {
            return PlaneIntersectionType.Back
        }
        return PlaneIntersectionType.Intersecting
    }

    /// Get the intersection type between a ray and a plane.
    /// - Parameters:
    ///   - ray: The ray
    ///   - plane: The plane
    /// - Returns: The distance from ray to plane if intersecting, -1 otherwise
    public static func intersectsRayAndPlane(ray: Ray, plane: Plane) -> Float {
        let normal = plane.normal
        let zeroTolerance = MathUtil.zeroTolerance

        let dir = Vector3.dot(left: normal, right: ray.direction)
        // Parallel
        if (abs(dir) < zeroTolerance) {
            return -1
        }

        let position = Vector3.dot(left: normal, right: ray.origin)
        var distance = (-plane.distance - position) / dir

        if (distance < 0) {
            if (distance < -zeroTolerance) {
                return -1
            }

            distance = 0
        }

        return distance
    }

    /// Get the intersection type between a ray and a box (AABB).
    /// - Parameters:
    ///   - ray: The ray
    ///   - box: The box
    /// - Returns: The distance from ray to box if intersecting, -1 otherwise
    public static func intersectsRayAndBox(ray: Ray, box: BoundingBox) -> Float {
        let zeroTolerance = MathUtil.zeroTolerance
        let origin = ray.origin
        let direction = ray.direction
        let min = box.min
        let max = box.max
        let dirX = direction.x
        let dirY = direction.y
        let dirZ = direction.z
        let oriX = origin.x
        let oriY = origin.y
        let oriZ = origin.z
        var distance: Float = 0.0
        var tmax = Float.greatestFiniteMagnitude

        if (abs(dirX) < zeroTolerance) {
            if (oriX < min.x || oriX > max.x) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirX
            var t1 = (min.x - oriX) * inverse
            var t2 = (max.x - oriX) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        if (abs(dirY) < zeroTolerance) {
            if (oriY < min.y || oriY > max.y) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirY
            var t1 = (min.y - oriY) * inverse
            var t2 = (max.y - oriY) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        if (abs(dirZ) < zeroTolerance) {
            if (oriZ < min.z || oriZ > max.z) {
                return -1
            }
        } else {
            let inverse = 1.0 / dirZ
            var t1 = (min.z - oriZ) * inverse
            var t2 = (max.z - oriZ) * inverse

            if (t1 > t2) {
                let temp = t1
                t1 = t2
                t2 = temp
            }

            distance = Swift.max(t1, distance)
            tmax = Swift.min(t2, tmax)

            if (distance > tmax) {
                return -1
            }
        }

        return distance
    }

    /// Get the intersection type between a ray and a sphere.
    /// - Parameters:
    ///   - ray: The ray
    ///   - sphere: The sphere
    /// - Returns: The distance from ray to sphere if intersecting, -1 otherwise
    public static func intersectsRayAndSphere(ray: Ray, sphere: BoundingSphere) -> Float {
        let origin = ray.origin
        let direction = ray.direction
        let center = sphere.center
        let radius = sphere.radius

        let m = origin - center
        let b = Vector3.dot(left: m, right: direction)
        let c = Vector3.dot(left: m, right: m) - radius * radius

        if (b > 0 && c > 0) {
            return -1
        }

        let discriminant = b * b - c
        if (discriminant < 0) {
            return -1
        }

        var distance = -b - sqrt(discriminant)
        if (distance < 0) {
            distance = 0
        }

        return distance
    }

    /// Check whether the boxes intersect.
    /// - Parameters:
    ///   - boxA: The first box to check
    ///   - boxB: The second box to check
    /// - Returns: True if the boxes intersect, false otherwise
    public static func intersectsBoxAndBox(boxA: BoundingBox, boxB: BoundingBox) -> Bool {
        if (boxA.min.x > boxB.max.x || boxB.min.x > boxA.max.x) {
            return false
        }

        if (boxA.min.y > boxB.max.y || boxB.min.y > boxA.max.y) {
            return false
        }

        return !(boxA.min.z > boxB.max.z || boxB.min.z > boxA.max.z)
    }

    /// Check whether the spheres intersect.
    /// - Parameters:
    ///   - sphereA: The first sphere to check
    ///   - sphereB: The second sphere to check
    /// - Returns: True if the spheres intersect, false otherwise
    public static func intersectsSphereAndSphere(sphereA: BoundingSphere, sphereB: BoundingSphere) -> Bool {
        let radiisum = sphereA.radius + sphereB.radius
        return Vector3.distanceSquared(left: sphereA.center, right: sphereB.center) < radiisum * radiisum
    }

    /// Check whether the sphere and the box intersect.
    /// - Parameters:
    ///   - sphere: The sphere to check
    ///   - box: The box to check
    /// - Returns: True if the sphere and the box intersect, false otherwise
    public static func intersectsSphereAndBox(sphere: BoundingSphere, box: BoundingBox) -> Bool {
        let center = sphere.center

        let closestPoint = Vector3(
                max(box.min.x, min(center.x, box.max.x)),
                max(box.min.y, min(center.y, box.max.y)),
                max(box.min.z, min(center.z, box.max.z))
        )

        let distance = Vector3.distanceSquared(left: center, right: closestPoint)
        return distance <= sphere.radius * sphere.radius
    }

    /// Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
    /// - Parameters:
    ///   - frustum: The frustum
    ///   - box:  The box
    /// - Returns: True if bounding box intersects with this frustum, false otherwise
    public static func intersectsFrustumAndBox(frustum: BoundingFrustum, box: BoundingBox) -> Bool {
        let min = box.min
        let max = box.max

        for i in 0..<6 {
            let plane = frustum.getPlane(face: FrustumFace(rawValue: i) ?? FrustumFace.Top)
            let normal = plane.normal
            let back = Vector3(normal.x >= 0 ? max.x : min.x,
                    normal.y >= 0 ? max.y : min.y,
                    normal.z >= 0 ? max.z : min.z)
            if (Vector3.dot(left: plane.normal, right: back) < -plane.distance) {
                return false
            }
        }

        return true
    }

    /// Get the containment type between a frustum and a box (AABB).
    /// - Parameters:
    ///   - frustum: The frustum
    ///   - box: The box
    /// - Returns: The containment type
    public static func frustumContainsBox(frustum: BoundingFrustum, box: BoundingBox) -> ContainmentType {
        let min = box.min
        let max = box.max
        var front = SIMD3<Float>()
        var back = SIMD3<Float>()
        var result = ContainmentType.Contains

        for i in 0..<6 {
            let plane = frustum.getPlane(face: FrustumFace(rawValue: i) ?? FrustumFace.Top)
            let normal = plane.normal

            if (normal.x >= 0) {
                front.x = max.x
                back.x = min.x
            } else {
                front.x = min.x
                back.x = max.x
            }
            if (normal.y >= 0) {
                front.y = max.y
                back.y = min.y
            } else {
                front.y = min.y
                back.y = max.y
            }
            if (normal.z >= 0) {
                front.z = max.z
                back.z = min.z
            } else {
                front.z = min.z
                back.z = max.z
            }

            if (CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: Vector3(front)) == PlaneIntersectionType.Back) {
                return ContainmentType.Disjoint
            }

            if (CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: Vector3(back)) == PlaneIntersectionType.Back) {
                result = ContainmentType.Intersects
            }
        }

        return result
    }

    /// Get the containment type between a frustum and a sphere.
    /// - Parameters:
    ///   - frustum: The frustum
    ///   - sphere: The sphere
    /// - Returns: The containment type
    public static func frustumContainsSphere(frustum: BoundingFrustum, sphere: BoundingSphere) -> ContainmentType {
        var result = ContainmentType.Contains

        for i in 0..<6 {
            let plane = frustum.getPlane(face: FrustumFace(rawValue: i) ?? FrustumFace.Top)
            let intersectionType = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere)
            if (intersectionType == PlaneIntersectionType.Back) {
                return ContainmentType.Disjoint
            } else if (intersectionType == PlaneIntersectionType.Intersecting) {
                result = ContainmentType.Intersects
                break
            }
        }

        return result
    }
}
