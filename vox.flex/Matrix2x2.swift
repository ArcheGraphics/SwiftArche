//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

public extension matrix_float2x2 {
    // MARK: - Basic getters

    /// Returns true if this matrix is a square matrix.
    var isSquare: Bool {
        true
    }

    /// Returns number of rows of this matrix.
    var rows: Int {
        2
    }

    /// Returns number of columns of this matrix.
    var cols: Int {
        2
    }

    // MARK: - Complex getters

    /// Returns sum of all elements.
    var sum: Float {
        reduce_add(columns.0)
            + reduce_add(columns.1)
    }

    /// Returns average of all elements.
    /// - Returns: average
    var avg: Float {
        sum / 4
    }

    /// Returns minimum among all elements.
    var min: Float {
        Swift.min(reduce_min(columns.0),
                  reduce_min(columns.1))
    }

    /// Returns maximum among all elements.
    var max: Float {
        Swift.max(reduce_max(columns.0),
                  reduce_max(columns.1))
    }

    /// Returns absolute minimum among all elements.
    var absmin: Float {
        Math.absmin(between: Math.absmin(between: columns.0[0], and: columns.0[1]),
                    and: Math.absmin(between: columns.1[0], and: columns.1[1]))
    }

    /// Returns absolute maximum among all elements.
    var absmax: Float {
        Math.absmax(between: Math.absmax(between: columns.0[0], and: columns.0[1]),
                    and: Math.absmax(between: columns.1[0], and: columns.1[1]))
    }

    /// Returns sum of all diagonal elements.
    var trace: Float {
        columns.0[0] + columns.1[1]
    }

    /// Returns diagonal part of this matrix.
    var diagonal: matrix_float2x2 {
        matrix_float2x2(diagonal: SIMD2<Float>(columns.0[0],
                                               columns.1[1]))
    }

    /// Returns off-diagonal part of this matrix.
    var offDiagonal: matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(0, columns.0[1]),
                               SIMD2<Float>(columns.1[0], 0)])
    }

    /// Returns strictly lower triangle part of this matrix.
    var strictLowerTri: matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(0, 0),
                               SIMD2<Float>(columns.1[0], 0)])
    }

    /// Returns strictly upper triangle part of this matrix.
    var strictUpperTri: matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(0, columns.0[1]),
                               SIMD2<Float>(0, 0)])
    }

    /// Returns lower triangle part of this matrix (including the diagonal).
    var lowerTri: matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(columns.0[0], 0),
                               SIMD2<Float>(columns.1[0], columns.1[1])])
    }

    /// Returns upper triangle part of this matrix (including the diagonal).
    var upperTri: matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(columns.0[0], columns.0[1]),
                               SIMD2<Float>(0, columns.1[1])])
    }

    /// Returns Frobenius norm.
    var frobeniusNorm: Float {
        sqrt(length_squared(columns.0) + length_squared(columns.1))
    }

    /// Makes rotation matrix.
    /// - Warning: Input angle should be radian.
    /// - Returns: new matrix
    static func makeRotationMatrix(rad: Float) -> matrix_float2x2 {
        matrix_float2x2(rows: [SIMD2<Float>(cos(rad), -sin(rad)),
                               SIMD2<Float>(sin(rad), cos(rad))])
    }
}
