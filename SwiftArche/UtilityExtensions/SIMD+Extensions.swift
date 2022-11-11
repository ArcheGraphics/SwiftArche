//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

// MARK: - SIMD4
extension SIMD4 {
    // Convenience getter for the first 3 components of a SIMD4 vector.
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

extension Float {
    static var randomSign: Float {
        if Bool.random() {
            return 1
        } else {
            return -1
        }
    }
}
