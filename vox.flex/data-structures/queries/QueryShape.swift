//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct QueryShape {
    public enum QueryType: Int {
        case Sphere = 0
        case Box = 1
        case Ray = 2
    }

    /// box: center of the box in solver space.
    /// sphere: center of the sphere in solver space,.
    /// ray: start of the ray in solver space
    public var center: Vector4

    /// box: size of the box in each axis.
    /// sphere: radius of sphere (x,y,z),
    /// ray: end of the line segment in solver space.
    public var size: Vector4
    public var type: QueryType
    public var contactOffset: Float
    /// minimum distance around the shape to look for./
    public var maxDistance: Float
    public var filter: Int

    public init(type: QueryType, center: Vector3, size: Vector3,
                contactOffset: Float, distance: Float, filter: Int)
    {
        self.type = type
        self.center = Vector4(center, 0)
        self.size = Vector4(size, 0)
        self.contactOffset = contactOffset
        maxDistance = distance
        self.filter = filter
    }
}
