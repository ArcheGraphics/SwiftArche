//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Fuzzy hashing functions for vector types. Exists as a shortcut to create hashcodes for Vector3 in the style of
/// IntVector3 without the overhead of casting.
class VectorHash {
    public static let FltCompareResolution: Float = 1000

    static func HashFloat(_ f: Float) -> Int {
        0
    }
    
    /// Return the rounded hashcode for a vector2
    public static func GetHashCode(_ v: Vector2) -> Int {
        0
    }

    /// Return the hashcode for a vector3 without first converting it to pb_IntVec3.
    public static func GetHashCode(_ v: Vector3) -> Int {
        0
    }

    /// Return the hashcode for a vector3 without first converting it to pb_IntVec3.
    public static func GetHashCode(_ v: Vector4) -> Int {
        0
    }
}
