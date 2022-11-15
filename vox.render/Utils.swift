//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class Utils {
    static func _floatMatrixMultiply(_ value: simd_float4x4, _ oe: inout [Float], _ offset: Int) {
        oe[offset] = value.columns.0[0]
        oe[offset + 1] = value.columns.0[1]
        oe[offset + 2] = value.columns.0[2]
        oe[offset + 3] = value.columns.0[3]

        oe[offset + 4] = value.columns.1[0]
        oe[offset + 5] = value.columns.1[1]
        oe[offset + 6] = value.columns.1[2]
        oe[offset + 7] = value.columns.1[3]

        oe[offset + 8] = value.columns.2[0]
        oe[offset + 9] = value.columns.2[1]
        oe[offset + 10] = value.columns.2[2]
        oe[offset + 11] = value.columns.2[3]

        oe[offset + 12] = value.columns.3[0]
        oe[offset + 13] = value.columns.3[1]
        oe[offset + 14] = value.columns.3[2]
        oe[offset + 15] = value.columns.3[3]
    }
    
    static func _floatMatrixMultiply(_ le: simd_float4x4, _ re: [Float], _ rOffset: Int,
                                     _ oe: inout [Float], _ offset: Int) {
        let l11 = le.columns.0[0], l12 = le.columns.0[1], l13 = le.columns.0[2], l14 = le.columns.0[3],
                l21 = le.columns.1[0], l22 = le.columns.1[1], l23 = le.columns.1[2], l24 = le.columns.1[3],
                l31 = le.columns.2[0], l32 = le.columns.2[1], l33 = le.columns.2[2], l34 = le.columns.2[3],
                l41 = le.columns.3[0], l42 = le.columns.3[1], l43 = le.columns.3[2], l44 = le.columns.3[3]

        let r11 = re[rOffset], r12 = re[rOffset + 1], r13 = re[rOffset + 2], r14 = re[rOffset + 3],
                r21 = re[rOffset + 4], r22 = re[rOffset + 5], r23 = re[rOffset + 6], r24 = re[rOffset + 7],
                r31 = re[rOffset + 8], r32 = re[rOffset + 9], r33 = re[rOffset + 10], r34 = re[rOffset + 11],
                r41 = re[rOffset + 12], r42 = re[rOffset + 13], r43 = re[rOffset + 14], r44 = re[rOffset + 15]

        oe[offset] = l11 * r11 + l21 * r12 + l31 * r13 + l41 * r14
        oe[offset + 1] = l12 * r11 + l22 * r12 + l32 * r13 + l42 * r14
        oe[offset + 2] = l13 * r11 + l23 * r12 + l33 * r13 + l43 * r14
        oe[offset + 3] = l14 * r11 + l24 * r12 + l34 * r13 + l44 * r14

        oe[offset + 4] = l11 * r21 + l21 * r22 + l31 * r23 + l41 * r24
        oe[offset + 5] = l12 * r21 + l22 * r22 + l32 * r23 + l42 * r24
        oe[offset + 6] = l13 * r21 + l23 * r22 + l33 * r23 + l43 * r24
        oe[offset + 7] = l14 * r21 + l24 * r22 + l34 * r23 + l44 * r24

        oe[offset + 8] = l11 * r31 + l21 * r32 + l31 * r33 + l41 * r34
        oe[offset + 9] = l12 * r31 + l22 * r32 + l32 * r33 + l42 * r34
        oe[offset + 10] = l13 * r31 + l23 * r32 + l33 * r33 + l43 * r34
        oe[offset + 11] = l14 * r31 + l24 * r32 + l34 * r33 + l44 * r34

        oe[offset + 12] = l11 * r41 + l21 * r42 + l31 * r43 + l41 * r44
        oe[offset + 13] = l12 * r41 + l22 * r42 + l32 * r43 + l42 * r44
        oe[offset + 14] = l13 * r41 + l23 * r42 + l33 * r43 + l43 * r44
        oe[offset + 15] = l14 * r41 + l24 * r42 + l34 * r43 + l44 * r44
    }
}