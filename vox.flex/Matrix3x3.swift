//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

extension matrix_float3x3 {
    // MARK:- Basic getters
    /// Returns true if this matrix is a square matrix.
    public var isSquare: Bool {
        true
    }

    /// Returns number of rows of this matrix.
    public var rows: size_t {
        3
    }

    /// Returns number of columns of this matrix.
    public var cols: size_t {
        3
    }

    // MARK:- Complex getters
    /// Returns sum of all elements.
    public var sum: Float {
        reduce_add(columns.0)
                + reduce_add(columns.1)
                + reduce_add(columns.2)
    }

    /// Returns average of all elements.
    /// - Returns: average
    public var avg: Float {
        return sum / 9
    }

    /// Returns minimum among all elements.
    public var min: Float {
        return Swift.min(Swift.min(reduce_min(columns.0),
                reduce_min(columns.1)),
                reduce_min(columns.1))
    }

    /// Returns maximum among all elements.
    public var max: Float {
        return Swift.max(Swift.max(reduce_max(columns.0),
                reduce_max(columns.1)),
                reduce_max(columns.2))
    }

    /// Returns absolute minimum among all elements.
    public var absmin: Float {
        let min = [Math.absminn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absminn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absminn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absminn(x: min)
    }

    /// Returns absolute maximum among all elements.
    public var absmax: Float {
        let max = [Math.absmaxn(x: [columns.0[0], columns.0[1], columns.0[2]]),
                   Math.absmaxn(x: [columns.1[0], columns.1[1], columns.1[2]]),
                   Math.absmaxn(x: [columns.2[0], columns.2[1], columns.2[2]])]
        return Math.absmaxn(x: max)
    }

    /// Returns sum of all diagonal elements.
    public var trace: Float {
        columns.0[0] + columns.1[1] + columns.2[2]
    }

    /// Returns diagonal part of this matrix.
    public var diagonal: matrix_float3x3 {
        matrix_float3x3(diagonal: SIMD3<Float>(columns.0[0],
                columns.1[1],
                columns.2[2]))
    }

    /// Returns off-diagonal part of this matrix.
    public var offDiagonal: matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(0, columns.0[1], columns.0[2]),
                               SIMD3<Float>(columns.1[0], 0, columns.1[2]),
                               SIMD3<Float>(columns.2[0], columns.2[1], 0)])
    }

    /// Returns strictly lower triangle part of this matrix.
    public var strictLowerTri: matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(0, 0, 0),
                               SIMD3<Float>(columns.1[0], 0, 0),
                               SIMD3<Float>(columns.2[0], columns.2[1], 0)])
    }

    /// Returns strictly upper triangle part of this matrix.
    public var strictUpperTri: matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(0, columns.0[1], columns.0[2]),
                               SIMD3<Float>(0, 0, columns.1[2]),
                               SIMD3<Float>(0, 0, 0)])
    }

    /// Returns lower triangle part of this matrix (including the diagonal).
    public var lowerTri: matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(columns.0[0], 0, 0),
                               SIMD3<Float>(columns.1[0], columns.1[1], 0),
                               SIMD3<Float>(columns.2[0], columns.2[1], columns.2[2])])
    }

    /// Returns upper triangle part of this matrix (including the diagonal).
    public var upperTri: matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(columns.0[0], columns.0[1], columns.0[2]),
                               SIMD3<Float>(0, columns.1[1], columns.1[2]),
                               SIMD3<Float>(0, 0, columns.2[2])])
    }

    /// Returns Frobenius norm.
    public var frobeniusNorm: Float {
        sqrt(length_squared(columns.0)
                + length_squared(columns.1)
                + length_squared(columns.2))
    }

    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    public static func makeRotationMatrix(axis: SIMD3<Float>, rad: Float) -> matrix_float3x3 {
        matrix_float3x3(rows: [SIMD3<Float>(1 + (1 - cos(rad)) * (axis.x * axis.x - 1),
                -axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z),
            SIMD3<Float>(axis.z * sin(rad) + (1 - cos(rad)) * axis.x * axis.y,
                    1 + (1 - cos(rad)) * (axis.y * axis.y - 1),
                    -axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z),
            SIMD3<Float>(-axis.y * sin(rad) + (1 - cos(rad)) * axis.x * axis.z,
                    axis.x * sin(rad) + (1 - cos(rad)) * axis.y * axis.z,
                    1 + (1 - cos(rad)) * (axis.z * axis.z - 1))])
    }
}
