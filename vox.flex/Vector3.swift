//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

extension SIMD3 where Scalar: BinaryFloatingPoint {
    /// Returns true if \p other is the same as this vector.
    func isEqual(other: SIMD3) -> Bool {
        x == other.x && y == other.y && z == other.z
    }

    /// Returns true if \p other is similar to this vector.
    /// - Parameters:
    ///   - other: similar vector
    ///   - epsilon: tolerance
    /// - Returns: isSimilar
    func isSimilar(other: SIMD3, epsilon: Scalar = Scalar.leastNonzeroMagnitude) -> Bool {
        (abs(x - other.x) < epsilon) &&
                (abs(y - other.y) < epsilon) &&
                (abs(z - other.z) < epsilon)
    }
}

//MARK: - Float Extension

extension SIMD3 where Scalar == Float {
    // MARK:- Basic setters
    /// Normalizes this vector.
    public mutating func normalized() {
        let l: Scalar = length(self)
        x /= l
        y /= l
        z /= l
    }

    // MARK:- Basic getters

    /// Returns the average of all the components.
    /// - Returns: average
    public var avg: Scalar {
        (x + y + z) / 3
    }

    /// Returns the reflection vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: reflection vector
    public func reflected(with normal: SIMD3) -> SIMD3 {
        self - 2 * normal * (dot(self, normal))
    }

    /// Returns the projected vector to the surface with given surface normal.
    /// - Parameter normal: surface normal
    /// - Returns: projected vector
    public func projected(with normal: SIMD3) -> SIMD3 {
        self - normal * (dot(self, normal))
    }

    /// Returns the tangential vector for this vector.
    /// - Returns: tangential vector
    public var tangential: Array<SIMD3> {
        var a: SIMD3 = ((abs(y) > 0 || abs(z) > 0) ? SIMD3(1, 0, 0)
                : SIMD3(0, 1, 0))
        a = normalize(cross(a, self))

        var result = Array<SIMD3>(repeating: a, count: 2)
        let b = cross(self, a)
        result[1] = b
        return result
    }
}

// MARK: - Utility Extensions

public func monotonicCatmullRom(v0: SIMD3<Float>, v1: SIMD3<Float>,
                         v2: SIMD3<Float>, v3: SIMD3<Float>, f: Float) -> SIMD3<Float> {
    let two: Float = 2
    let three: Float = 3

    var d1 = (v2 - v0) / two
    var d2 = (v3 - v1) / two
    let D1 = v2 - v1

    if (abs(D1.x) < Float.leastNonzeroMagnitude ||
            sign(D1.x) != sign(d1.x) ||
            sign(D1.x) != sign(d2.x)) {
        d1.x = 0
        d2.x = 0
    }

    if (abs(D1.y) < Float.leastNonzeroMagnitude ||
            sign(D1.y) != sign(d1.y) ||
            sign(D1.y) != sign(d2.y)) {
        d1.y = 0
        d2.y = 0
    }

    if (abs(D1.z) < Float.leastNonzeroMagnitude ||
            sign(D1.z) != sign(d1.z) ||
            sign(D1.z) != sign(d2.z)) {
        d1.z = 0
        d2.z = 0
    }

    let a3 = d1 + d2 - two * D1
    let a2 = three * D1 - two * d1 - d2
    let a1 = d1
    let a0 = v1

    var result = a3 * Math.cubic(of: f)
    result += a2 * Math.square(of: f)
    result += a1 * f + a0

    return result
}

public typealias Vector3 = SIMD3
public typealias Vector3F = SIMD3<Float>
