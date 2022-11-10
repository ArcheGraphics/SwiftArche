//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// A bounding frustum.
struct BoundingFrustum {
    /// The near plane of this frustum.
    var _near: Plane
    /// The far plane of this frustum.
    var _far: Plane
    /// The left plane of this frustum.
    var _left: Plane
    /// The right plane of this frustum.
    var _right: Plane
    /// The top plane of this frustum.
    var _top: Plane
    /// The bottom plane of this frustum.
    var _bottom: Plane

    var near: Plane {
        get {
            _near
        }
    }

    var far: Plane {
        get {
            _far
        }
    }

    var left: Plane {
        get {
            _left
        }
    }

    var right: Plane {
        get {
            _right
        }
    }

    var top: Plane {
        get {
            _top
        }
    }

    var bottom: Plane {
        get {
            _bottom
        }
    }

    /// Constructor of BoundingFrustum.
    /// - Parameter matrix: The view-projection matrix
    init(matrix: Matrix? = nil) {
        _near = Plane()
        _far = Plane()
        _left = Plane()
        _right = Plane()
        _top = Plane()
        _bottom = Plane()

        if matrix != nil {
            calculateFromMatrix(matrix: matrix!)
        }
    }
}

extension BoundingFrustum {
    /// Get the plane by the given index.
    /// - Remark:
    /// 0: near
    /// 1: far
    /// 2: left
    /// 3: right
    /// 4: top
    /// 5: bottom
    /// - Parameter index: The index
    /// - Returns: The plane get
    func getPlane(index: Int) -> Plane? {
        switch (index) {
        case 0:
            return near
        case 1:
            return far
        case 2:
            return left
        case 3:
            return right
        case 4:
            return top
        case 5:
            return bottom
        default:
            return nil
        }
    }

    /// Update all planes from the given matrix.
    /// - Parameter matrix: The given view-projection matrix
    public mutating func calculateFromMatrix(matrix: Matrix) {
        let m11 = matrix.elements.columns.0[0]
        let m12 = matrix.elements.columns.0[1]
        let m13 = matrix.elements.columns.0[2]
        let m14 = matrix.elements.columns.0[3]

        let m21 = matrix.elements.columns.1[0]
        let m22 = matrix.elements.columns.1[1]
        let m23 = matrix.elements.columns.1[2]
        let m24 = matrix.elements.columns.1[3]

        let m31 = matrix.elements.columns.2[0]
        let m32 = matrix.elements.columns.2[1]
        let m33 = matrix.elements.columns.2[2]
        let m34 = matrix.elements.columns.2[3]

        let m41 = matrix.elements.columns.3[0]
        let m42 = matrix.elements.columns.3[1]
        let m43 = matrix.elements.columns.3[2]
        let m44 = matrix.elements.columns.3[3]

        // near
        _near = Plane(Vector3(-m14 - m13, -m24 - m23, -m34 - m33), -m44 - m43)
        _ = _near.normalize()

        // far
        _far = Plane(Vector3(m13 - m14, m23 - m24, m33 - m34), m43 - m44)
        _ = _far.normalize()

        // left
        _left = Plane(Vector3(-m14 - m11, -m24 - m21, -m34 - m31), -m44 - m41)
        _ = _left.normalize()

        // right
        _right = Plane(Vector3(m11 - m14, m21 - m24, m31 - m34), m41 - m44)
        _ = _right.normalize()

        // top
        _top = Plane(Vector3(m12 - m14, m22 - m24, m32 - m34), m42 - m44)
        _ = _top.normalize()

        // bottom
        _bottom = Plane(Vector3(-m14 - m12, -m24 - m22, -m34 - m32), -m44 - m42)
        _ = _bottom.normalize()
    }

    /// Get whether or not a specified bounding box intersects with this frustum (Contains or Intersects).
    /// - Parameter box: The box for testing
    /// - Returns: True if bounding box intersects with this frustum, false otherwise
    public func intersectsBox(box: BoundingBox) -> Bool {
        CollisionUtil.intersectsFrustumAndBox(frustum: self, box: box)
    }

    /// Get whether or not a specified bounding sphere intersects with this frustum (Contains or Intersects).
    /// - Parameter sphere: The sphere for testing
    /// - Returns: True if bounding sphere intersects with this frustum, false otherwise
    public func intersectsSphere(sphere: BoundingSphere) -> Bool {
        CollisionUtil.frustumContainsSphere(frustum: self, sphere: sphere) != ContainmentType.Disjoint
    }
}
