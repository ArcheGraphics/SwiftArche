//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

protocol PointGenerator {
    /// Generates points to output array \p points inside given \p boundingBox
    /// with target point \p spacing.
    func generate(boundingBox: BoundingBox3F,
                  spacing: Float,
                  points: inout [Vector3F])

    /// Iterates every point within the bounding box with specified
    /// point pattern and invokes the callback function.
    ///
    /// This function iterates every point within the bounding box and invokes
    /// the callback function. The position of the point is specified by the
    /// actual implementation. The suggested spacing between the points are
    /// given by \p spacing. The input parameter of the callback function is
    /// the position of the point and the return value tells whether the
    /// iteration should stop or not.
    func forEachPoint(boundingBox: BoundingBox3F,
                      spacing: Float,
                      callback: (Vector3F) -> Bool)
}

extension PointGenerator {
    func generate(boundingBox: BoundingBox3F,
                  spacing: Float,
                  points: inout [Vector3F])
    {
        forEachPoint(boundingBox: boundingBox, spacing: spacing) {
            (point: Vector3F) in
            let pointArray: [Vector3F] = [point]
            points.append(contentsOf: pointArray)
            return true
        }
    }
}
