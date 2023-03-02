//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// A container for normal, tangent, and bitangent values.
public struct Normal {
    /// A unit normal.
    public var normal = Vector3()
    /// A unit tangent.
    public var tangent = Vector4()
    /// A unit bitangent (sometimes called binormal).
    public var bitangent = Vector3()
}

extension Normal: Hashable {
    public static func == (lhs: Normal, rhs: Normal) -> Bool {
        return Math.Approx3(a: lhs.normal, b: rhs.normal) &&
        Math.Approx4(a: lhs.tangent, b: rhs.tangent) &&
        Math.Approx3(a: lhs.bitangent, b: rhs.bitangent)
    }
    
    public func hash(into hasher: inout Hasher) {
        var hashCode = VectorHash.GetHashCode(normal)
        hashCode = (hashCode * 397) ^ VectorHash.GetHashCode(tangent)
        hashCode = (hashCode * 397) ^ VectorHash.GetHashCode(bitangent)
        hasher.combine(hashValue)
    }
}
