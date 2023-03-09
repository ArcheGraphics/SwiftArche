//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Axis Aligned Bound Box (AABB).
public struct BoundingBox {
    private var m_Center = Vector3()
    private var m_Extents = Vector3()

    /// The center of the bounding box.
    public var center: Vector3 {
        get {
            m_Center
        }
        set {
            m_Center = newValue
        }
    }

    /// The total size of the box. This is always twice as large as the extents.
    public var size: Vector3 {
        get {
            m_Extents * 2
        }
        set {
            m_Extents = newValue * 0.5
        }
    }

    /// The extents of the Bounding Box. This is always half of the size of the Bounds.
    public var extents: Vector3 {
        get {
            m_Extents
        }
        set {
            m_Extents = newValue
        }
    }

    /// The minimal point of the box. This is always equal to center-extents.
    public var min: Vector3 {
        get {
            center - extents
        }
        set {
            setMinMax(newValue, max)
        }
    }

    /// The maximal point of the box. This is always equal to center+extents.
    public var max: Vector3 {
        get {
            center + extents
        }
        set {
            setMinMax(min, newValue)
        }
    }

    /// Constructor of BoundingBox.
    /// - Parameters:
    ///   - min: The minimum point of the box
    ///   - max: The maximum point of the box
    public init(_ min: Vector3? = nil, _ max: Vector3? = nil) {
        if let min {
            self.min = min
        }
        if let max {
            self.max = max
        }
    }
    
    /// Sets the bounds to the min and max value of the box.
    public mutating func setMinMax(_ min: Vector3, _ max: Vector3) {
      extents = (max - min) * 0.5
      center = min + extents;
    }
}

//MARK: - Static Methods

extension BoundingBox {
    /// Calculate a bounding box from the center point and the extent of the bounding box.
    /// - Parameters:
    ///   - center: The center point
    ///   - extent: The extent of the bounding box
    /// - Returns: The calculated bounding box
    public static func fromCenterAndExtent(center: Vector3, extent: Vector3) -> BoundingBox {
        BoundingBox(center - extent, center + extent)
    }

    /// Calculate a bounding box that fully contains the given points.
    /// - Parameters:
    ///   - points: The given points
    /// - Returns: The calculated bounding box
    public static func fromPoints(points: [Vector3]) -> BoundingBox {
        if (points.count == 0) {
            fatalError("points must be array and length must > 0")
        }

        var out = BoundingBox(Vector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude),
                Vector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude))
        for point in points {
            out.setMinMax(Vector3.min(left: out.min, right: point),
                          Vector3.max(left: out.max, right: point))
        }
        return out
    }

    /// Calculate a bounding box from a given sphere.
    /// - Parameters:
    ///   - sphere: The given sphere
    /// - Returns: The calculated bounding box
    public static func fromSphere(sphere: BoundingSphere) -> BoundingBox {
        let center = sphere.center
        let radius = sphere.radius
        return BoundingBox(Vector3(center.x - radius, center.y - radius, center.z - radius),
                Vector3(center.x + radius, center.y + radius, center.z + radius))
    }

    /// Transform a bounding box.
    /// - Parameters:
    ///   - source: The original bounding box
    ///   - matrix: The transform to apply to the bounding box
    /// - Returns: The transformed bounding box
    public static func transform(source: BoundingBox, matrix: Matrix) -> BoundingBox {
        // https://zeux.io/2010/10/17/aabb-from-obb-with-component-wise-abs/
        var center = source.getCenter()
        var extent = source.getExtent()
        center = Vector3.transformCoordinate(v: center, m: matrix)

        let x = extent.x
        let y = extent.y
        let z = extent.z

        extent = Vector3(abs(x * matrix.elements.columns.0[0]) + abs(y * matrix.elements.columns.1[0]) + abs(z * matrix.elements.columns.2[0]),
                abs(x * matrix.elements.columns.0[1]) + abs(y * matrix.elements.columns.1[1]) + abs(z * matrix.elements.columns.2[1]),
                abs(x * matrix.elements.columns.0[2]) + abs(y * matrix.elements.columns.1[2]) + abs(z * matrix.elements.columns.2[2]))

        // set min、max
        return BoundingBox(center - extent, center + extent)
    }

    /// Calculate a bounding box that is as large as the total combined area of the two specified boxes.
    /// - Parameters:
    ///   - box1: The first box to merge
    ///   - box2: The second box to merge
    /// - Returns: The merged bounding box
    public static func merge(box1: BoundingBox, box2: BoundingBox) -> BoundingBox {
        BoundingBox(Vector3.min(left: box1.min, right: box2.min), Vector3.max(left: box1.max, right: box2.max))
    }
}

extension BoundingBox {
    /// Get the center point of this bounding box.
    /// - Returns: The center point of this bounding box
    public func getCenter() -> Vector3 {
        (min + max) * 0.5
    }

    /// Get the extent of this bounding box.
    /// - Returns: The extent of this bounding box
    public func getExtent() -> Vector3 {
        (max - min) * 0.5
    }

    /// Get the eight corners of this bounding box.
    /// - Returns: An array of points representing the eight corners of this bounding box
    public func getCorners() -> [Vector3] {
        let minX = min.x
        let minY = min.y
        let minZ = min.z
        let maxX = max.x
        let maxY = max.y
        let maxZ = max.z

        // The array length is less than 8 to make up
        var out = Array<Vector3>(repeating: Vector3(), count: 8)
        _ = out[0].set(x: minX, y: maxY, z: maxZ)
        _ = out[1].set(x: maxX, y: maxY, z: maxZ)
        _ = out[2].set(x: maxX, y: minY, z: maxZ)
        _ = out[3].set(x: minX, y: minY, z: maxZ)
        _ = out[4].set(x: minX, y: maxY, z: minZ)
        _ = out[5].set(x: maxX, y: maxY, z: minZ)
        _ = out[6].set(x: maxX, y: minY, z: minZ)
        _ = out[7].set(x: minX, y: minY, z: minZ)

        return out
    }

    /// Transform a bounding box.
    /// - Parameter matrix: The transform to apply to the bounding box
    /// - Returns: The transformed bounding box
    public mutating func transform(matrix: Matrix) -> BoundingBox {
        self = BoundingBox.transform(source: self, matrix: matrix)
        return self
    }
}

public typealias Bounds = BoundingBox

extension BoundingBox: Codable {
}
