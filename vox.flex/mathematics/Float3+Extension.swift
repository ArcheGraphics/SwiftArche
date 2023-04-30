//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

extension float3 {
    // MARK: - Basic setters

    /// Normalizes this vector.
    mutating func normalized() {
        let l: Scalar = length(self)
        x /= l
        y /= l
        z /= l
    }

    // MARK: - Basic getters

    /// Returns the average of all the components.
    /// - Returns: average
    var avg: Scalar {
        (x + y + z) / 3
    }

    /// Returns the reflection vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: reflection vector
    func reflected(with normal: SIMD3) -> SIMD3 {
        self - 2 * normal * dot(self, normal)
    }

    /// Returns the projected vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: projected vector
    func projected(with normal: SIMD3) -> SIMD3 {
        self - normal * dot(self, normal)
    }

    /// Returns the tangential vector for this vector.
    /// - Returns: tangential vector
    var tangential: [SIMD3] {
        var a: SIMD3 = ((abs(y) > 0 || abs(z) > 0) ? SIMD3(1, 0, 0)
            : SIMD3(0, 1, 0))
        a = normalize(cross(a, self))

        var result = [SIMD3](repeating: a, count: 2)
        let b = cross(self, a)
        result[1] = b
        return result
    }
}
