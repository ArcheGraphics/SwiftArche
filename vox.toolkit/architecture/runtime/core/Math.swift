//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// A collection of math functions that are useful when working with 3d meshes.
public class Math {
    /// Epsilon to use when comparing vertex positions for equality.
    static let k_FltCompareEpsilon: Float = 0.0001

    /// The minimum distance a handle must move on an axis before considering that axis as engaged.
    internal static let handleEpsilon: Float = 0.0001

    /// Get a point on the circumference of a circle.
    /// - Parameters:
    ///   - radius: The radius of the circle.
    ///   - angleInDegrees: Where along the circle should the point be projected. Angle is in degrees.
    ///   - origin: origin
    /// - Returns: a point on the circumference of a circle.
    internal static func PointInCircumference(radius: Float, angleInDegrees: Float, origin: Vector2) -> Vector2 {
        // Convert from degrees to radians via multiplication by PI/180
        let x = Float(radius * MathUtil.cos(MathUtil.degreeToRadFactor * angleInDegrees)) + origin.x
        let y = Float(radius * MathUtil.sin(MathUtil.degreeToRadFactor * angleInDegrees)) + origin.y

        return Vector2(x, y)
    }

    /// Get a point on the circumference of an ellipse.
    /// - Parameters:
    ///   - xRadius: The radius of the circle on the x-axis.
    ///   - yRadius: The radius of the circle on the y-axis.
    ///   - angleInDegrees: Where along the circle should the point be projected. Angle is in degrees.
    ///   - origin: The center point of the ellipse
    ///   - tangent: Out: the resulting at the computed position
    /// - Returns: a point on the circumference of an ellipse.
    internal static func PointInEllipseCircumference(xRadius: Float, yRadius: Float, angleInDegrees: Float,
                                                     origin: Vector2, tangent: inout Vector2) -> Vector2 {
        Vector2()
    }

    /// Get a point on the circumference of an ellipse.
    /// - Parameters:
    ///   - xRadius: The radius of the circle on the x-axis.
    ///   - yRadius: The radius of the circle on the y-axis.
    ///   - angleInDegrees: Where along the circle should the point be projected. Angle is in degrees.
    ///   - origin: The center point of the ellipse
    ///   - tangent: Out: the resulting at the computed position
    /// - Returns: a point on the circumference of an ellipse.
    internal static func PointInEllipseCircumferenceWithConstantAngle(xRadius: Float, yRadius: Float,
                                                                      angleInDegrees: Float, origin: Vector2,
                                                                      tangent: inout Vector2) -> Vector2 {
        Vector2()
    }

    /// Provided a radius, latitudinal and longitudinal angle, return a position.
    internal static func PointInSphere(radius: Float, latitudeAngle: Float, longitudeAngle: Float) -> Vector3 {
        Vector3()
    }

    /// Find the signed angle from direction a to direction b.
    /// - Parameters:
    ///   - a: The direction from which to rotate.
    ///   - b: The direction to rotate towards.
    /// - Returns: A signed angle in degrees from direction a to direction b.
    internal static func SignedAngle(a: Vector2, b: Vector2) -> Float {
        0
    }

    /// Squared distance between two points. This is the same as `(b - a).sqrMagnitude`.
    /// - Parameters:
    ///   - a: First point.
    ///   - b: Second point.
    /// - Returns: Squared distance
    public static func SqrDistance(a: Vector3, b: Vector3) -> Float {
        0
    }


    /// Get the area of a triangle.
    /// - Remark:
    /// http://www.iquilezles.org/blog/?p=1579
    /// - Parameters:
    ///   - x: First vertex position of the triangle.
    ///   - y: Second vertex position of the triangle.
    ///   - z: Third vertex position of the triangle.
    /// - Returns: The area of the triangle.
    public static func TriangleArea(x: Vector3, y: Vector3, z: Vector3) -> Float {
        0
    }

    /// Returns the Area of a polygon.
    internal static func PolygonArea(vertices: [Vector3], indexes: [Int]) -> Float {
        0
    }

    internal static func Perpendicular(value: Vector2) -> Vector2 {
        Vector2()
    }

    /// Reflects a point across a line segment.
    /// - Parameters:
    ///   - point: The point to reflect.
    ///   - lineStart: First point of the line segment.
    ///   - lineEnd: Second point of the line segment.
    /// - Returns: The reflected point.
    public static func ReflectPoint(point: Vector2, lineStart: Vector2, lineEnd: Vector2) -> Vector2 {
        Vector2()
    }

    internal static func SqrDistanceRayPoint(ray: Ray, point: Vector3) -> Float {
        0
    }

    /// Get the distance between a point and a finite line segment.
    /// - Remark:
    /// http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    /// - Parameters:
    ///   - point: The point.
    ///   - lineStart: Line start.
    ///   - lineEnd: Line end.
    /// - Returns: The distance from point to the nearest point on a line segment.
    public static func DistancePointLineSegment(point: Vector2, lineStart: Vector2, lineEnd: Vector2) -> Float {
        0
    }

    /// Get the distance between a point and a finite line segment.
    /// - Remark:
    /// http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    /// - Parameters:
    ///   - point: The point.
    ///   - lineStart: Line start.
    ///   - lineEnd: Line end.
    /// - Returns: The distance from point to the nearest point on a line segment.
    public static func DistancePointLineSegment(point: Vector3, lineStart: Vector3, lineEnd: Vector3) -> Float {
        0
    }

    /// Calculate the nearest point between two rays.
    /// - Parameters:
    ///   - a: First ray.
    ///   - b: Second ray.
    public static func GetNearestPointRayRay(a: Ray, b: Ray) -> Vector3 {
        Vector3()
    }

    internal static func GetNearestPointRayRay(ao: Vector3, ad: Vector3, bo: Vector3, bd: Vector3) -> Vector3 {
        Vector3()
    }

    // http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    // Returns 1 if the lines intersect, otherwise 0. In addition, if the lines
    // intersect the intersection point may be stored in the intersect var
    internal static func GetLineSegmentIntersect(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, intersect: inout Vector2) -> Bool {
        false
    }

    /// True or false lines, do lines intersect.
    internal static func GetLineSegmentIntersect(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> Bool {
        false
    }

    /// Casts a ray from outside the bounds to the polygon and checks how many edges are hit.
    /// - Parameters:
    ///   - polygon: A series of individual edges composing a polygon.  polygon length *must* be divisible by 2.
    ///   - point: point
    ///   - indexes: If present these indexes make up the border of polygon. If not, polygon is assumed to be in correct order.
    /// - Returns: True if the polygon contains point. False otherwise.
    internal static func PointInPolygon(_ polygon: [Vector2], point: Vector2, indexes: [Int]? = nil) -> Bool {
        false
    }

    /// Is the point within a polygon?
    /// - Remark:
    /// Assumes polygon has already been tested with AABB
    internal static func PointInPolygon(positions: [Vector2], polyBounds: Bounds2D, edges: [Edge], point: Vector2) -> Bool {
        false
    }

    /// Is the 2d point within a 2d polygon? This overload is provided as a convenience for 2d arrays coming from cam.WorldToScreenPoint (which includes a Z value).
    /// - Remark:
    /// Assumes polygon has already been tested with AABB
    internal static func PointInPolygon(positions: [Vector3], polyBounds: Bounds2D, edges: [Edge], point: Vector2) -> Bool {
        false
    }

    internal static func RectIntersectsLineSegment(rect: Rect, a: Vector2, b: Vector2) -> Bool {
        false
    }

    internal static func RectIntersectsLineSegment(rect: Rect, a: Vector3, b: Vector3) -> Bool {
        false
    }

    /// Test if a raycast intersects a triangle. Does not test for culling.
    /// - Remark:
    /// http://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
    /// http://www.cs.virginia.edu/~gfx/Courses/2003/ImageSynthesis/papers/Acceleration/Fast%20MinimumStorage%20RayTriangle%20Intersection.pdf
    /// - Parameters:
    ///   - InRay: InRay
    ///   - InTriangleA: First vertex position in the triangle.
    ///   - InTriangleB: Second vertex position in the triangle.
    ///   - InTriangleC: Third vertex position in the triangle.
    ///   - OutDistance: If triangle is intersected, this is the distance of intersection point from ray origin. Zero if not intersected.
    ///   - OutPoint: If triangle is intersected, this is the point of collision. Zero if not intersected.
    /// - Returns: True if ray intersects, false if not.
    public static func RayIntersectsTriangle(InRay: Ray, InTriangleA: Vector3, InTriangleB: Vector3, InTriangleC: Vector3,
                                             OutDistance: inout Float, OutPoint: inout  Vector3) -> Bool {
        false
    }

    /// Non-allocating version of Ray / Triangle intersection.
    internal static func RayIntersectsTriangle2(origin: Vector3,
                                                dir: Vector3,
                                                vert0: Vector3,
                                                vert1: Vector3,
                                                vert2: Vector3,
                                                distance: inout Float,
                                                normal: inout Vector3) -> Bool {
        false
    }

    /// Return the secant of a radian.
    /// Equivalent to: `1f / cos(x)`.
    /// - Parameter x: The radian to calculate the secant of.
    /// - Returns: The secant of radian x.
    public static func Secant(_ x: Float) -> Float {
        0
    }

    /// Calculate the unit vector normal of 3 points.
    /// Equivalent to: `B-A x C-A`
    /// - Parameters:
    ///   - p0: First point of the triangle.
    ///   - p1: Second point of the triangle.
    ///   - p2: Third point of the triangle.
    /// - Returns: Normal
    public static func Normal(p0: Vector3, p1: Vector3, p2: Vector3) -> Vector3 {
        Vector3()
    }

    /// Calculate the normal of a set of vertices. If indexes is null or not divisible by 3, the first 3 positions are used.  If indexes is valid, an average of each set of 3 is taken.
    internal static func Normal(vertices: [Vertex], indexes: [Int]? = nil) -> Vector3 {
        Vector3()
    }

    /// Finds the best normal for a face.
    /// - Parameters:
    ///   - mesh: The mesh that the target face belongs to.
    ///   - face: The face to calculate a normal for.
    /// - Returns: A normal that most closely matches the face orientation in model corrdinates.
    public static func Normal(mesh: ProBuilderMesh, face: Face) -> Vector3 {
        Vector3()
    }

    /// Returns the first normal, tangent, and bitangent for this face using the first triangle available for tangent and bitangent.
    /// - Parameters:
    ///   - mesh: The mesh that the target face belongs to.
    ///   - face: The face to calculate normal information for.
    /// - Returns: The normal, bitangent, and tangent for the face.
    public static func NormalTangentBitangent(mesh: ProBuilderMesh, face: Face) -> Normal {
        vox_toolkit.Normal()
    }

    /// Is the direction within epsilon of Up, Down, Left, Right, Forward, or Backwards?
    internal static func IsCardinalAxis(v: Vector3, epsilon: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }

    /// Return the largest axis in a Vector3.
    internal static func LargestValue(v: Vector3) -> Float {
        0
    }

    /// Return the largest axis in a Vector2.
    internal static func LargestValue(v: Vector2) -> Float {
        0
    }

    /// The smallest X and Y value found in an array of Vector2. May or may not belong to the same Vector2.
    internal static func SmallestVector2(_ v: [Vector2]) -> Vector2 {
        Vector2()
    }
    
    /// The smallest X and Y value found in an array of Vector2. May or may not belong to the same Vector2.
    /// - Parameters:
    ///   - v: v
    ///   - indexes: Indexes of v array to test.
    /// - Returns: smallestVector2
    internal static func SmallestVector2(v: [Vector2], indexes: [Int]) -> Vector2 {
        Vector2()
    }

    /// The largest X and Y value in an array.  May or may not belong to the same Vector2.
    internal static func LargestVector2(_ v: [Vector2]) -> Vector2 {
        Vector2()
    }

    internal static func LargestVector2(_ v: [Vector2], indexes: [Int]) -> Vector2 {
        Vector2()
    }


    /// Creates an AABB with a set of vertices.
    internal static func GetBounds(positions: [Vector3], indices: [Int]? = nil) -> BoundingBox {
        BoundingBox()
    }

    /// Gets the average of a vector array.
    /// - Parameters:
    ///   - array: The array
    ///   - indexes: If provided the average is the sum of all points contained in the indexes array. If not, the entire v array is used.
    /// - Returns: Average Vector3 of passed vertex array.
    public static func Average(array: [Vector2], indexes: [Int]? = nil) -> Vector2 {
        Vector2()
    }

    /// Gets the average of a vector array.
    /// - Parameters:
    ///   - array: The array.
    ///   - indexes: If provided the average is the sum of all points contained in the indexes array. If not, the entire v array is used.
    /// - Returns: Average Vector3 of passed vertex array.
    public static func Average(array: [Vector3], indexes: [Int]? = nil) -> Vector3 {
        Vector3()
    }

    /// Gets the average of a vector array.
    /// - Parameters:
    ///   - array: The array.
    ///   - indexes: If provided the average is the sum of all points contained in the indexes array. If not, the entire v array is used.
    /// - Returns: Average Vector4 of passed vertex array.
    public static func Average(array: [Vector4], indexes: [Int]? = nil) -> Vector4 {
        Vector4()
    }

    internal static func InvertScaleVector(_ scaleVector: Vector3) -> Vector3 {
        Vector3()
    }

    /// Clamp a int to a range.
    /// - Parameters:
    ///   - value: The value to clamp.
    ///   - lowerBound: The lowest value that the clamped value can be.
    ///   - upperBound: The highest value that the clamped value can be.
    /// - Returns: A value clamped with the range of lowerBound and upperBound.
    public static func Clamp(value: Int, lowerBound: Int, upperBound: Int) -> Int {
        0
    }


    /// Non-allocating cross product.
    internal static func Cross(a: Vector3, b: Vector3, res: inout Vector3) {
    }

    /// Vector subtraction without allocating a new vector.
    internal static func Subtract(a: Vector3, b: Vector3, res: inout Vector3) {
    }

    internal static func IsNumber(_ value: Float) -> Bool {
        return !(value.isInfinite || value.isNaN)
    }

    internal static func IsNumber(_ value: Vector2) -> Bool {
        return IsNumber(value.x) && IsNumber(value.y)
    }

    internal static func IsNumber(_ value: Vector3) -> Bool {
        return IsNumber(value.x) && IsNumber(value.y) && IsNumber(value.z)
    }

    internal static func IsNumber(_ value: Vector4) -> Bool {
        return IsNumber(value.x) && IsNumber(value.y) && IsNumber(value.z) && IsNumber(value.w)
    }

    internal static func MakeNonZero(_ value: Float, _ min: Float = 0.0001) -> Float {
        if (value.isNaN || value.isInfinite || MathUtil.abs(value) < min) {
            return min * MathUtil.sign(value)
        }
        return value
    }

    /// Compares two Vector2 values component-wise, allowing for a margin of error.
    /// - Parameters:
    ///   - a: First Vector2 value.
    ///   - b: Second Vector2 value.
    ///   - delta: The maximum difference between components allowed.
    /// - Returns: True if a and b components are respectively within delta distance of one another.
    internal static func Approx2(a: Vector2, b: Vector2, delta: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }

    /// Compares two Vector3 values component-wise, allowing for a margin of error.
    /// - Parameters:
    ///   - a: First Vector3 value.
    ///   - b: Second Vector3 value.
    ///   - delta: The maximum difference between components allowed.
    /// - Returns: True if a and b components are respectively within delta distance of one another.
    internal static func Approx3(a: Vector3, b: Vector3, delta: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }

    /// Compares two Vector4 values component-wise, allowing for a margin of error.
    /// - Parameters:
    ///   - a: First Vector4 value.
    ///   - b: Second Vector4 value.
    ///   - delta: The maximum difference between components allowed.
    /// - Returns: True if a and b components are respectively within delta distance of one another.
    internal static func Approx4(a: Vector4, b: Vector4, delta: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }

    /// Compares two Color values component-wise, allowing for a margin of error.
    /// - Parameters:
    ///   - a: First Color value.
    ///   - b: Second Color value.
    ///   - delta: The maximum difference between components allowed.
    /// - Returns: True if a and b components are respectively within delta distance of one another.
    internal static func ApproxC(a: Color, b: Color, delta: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }

    /// Compares two float values component-wise, allowing for a margin of error.
    /// - Parameters:
    ///   - a: First float value.
    ///   - b: Second float value.
    ///   - delta: The maximum difference between components allowed.
    /// - Returns: True if a and b components are respectively within delta distance of one another.
    internal static func Approx(a: Float, b: Float, delta: Float = Float.leastNonzeroMagnitude) -> Bool {
        false
    }
}

extension Vector2 {
    /// Returns a new point by rotating the Vector2 around an origin point.
    /// - Parameters:
    ///   - origin: Vector2 original point.
    ///   - theta: The pivot to rotate around.
    /// - Returns: How far to rotate in degrees.
    internal static func RotateAroundPoint(origin: Vector2, theta: Float) -> Vector2 {
        Vector2()
    }

    /// Scales a Vector2 using origin as the pivot point.
    public static func ScaleAroundPoint(origin: Vector2, scale: Vector2) -> Vector2 {
        Vector2()
    }

    /// Component-wise division.
    internal static func DivideBy(o: Vector2) -> Vector2 {
        Vector2()
    }
}

extension Vector3 {
    /// Component-wise division.
    internal static func DivideBy(o: Vector3) -> Vector3 {
        Vector3()
    }

    internal func Abs() -> Vector3 {
        return Vector3(MathUtil.abs(x), MathUtil.abs(y), MathUtil.abs(z))
    }

    internal func Sign() -> Vector3 {
        return Vector3(MathUtil.sign(x), MathUtil.sign(y), MathUtil.sign(z))
    }

    internal func Sum() -> Float {
        return MathUtil.abs(x) + MathUtil.abs(y) + MathUtil.abs(z)
    }
}
