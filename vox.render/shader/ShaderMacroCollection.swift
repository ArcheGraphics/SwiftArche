//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

extension MacroName: Hashable {}

/// Shader macro collection.
internal struct ShaderMacroCollection {
    internal var _value: [UInt16: (Int, MTLDataType)] = [:]

    /// Union of two macro collection.
    /// - Parameters:
    ///   - left: input macro collection
    ///   - right: input macro collection
    ///   - result: union output macro collection
    static func unionCollection(_ left: ShaderMacroCollection, _ right: ShaderMacroCollection, _ result: inout ShaderMacroCollection) {
        result._value = left._value.merging(right._value) { _, r in
            r
        }
    }

    mutating func clear() {
        _value = [:]
    }
}

extension ShaderMacroCollection: Hashable {
    static func == (lhs: ShaderMacroCollection, rhs: ShaderMacroCollection) -> Bool {
        var lhs_hasher = Hasher()
        var rhs_hasher = Hasher()

        lhs.hash(into: &lhs_hasher)
        rhs.hash(into: &rhs_hasher)

        return lhs_hasher.finalize() == rhs_hasher.finalize()
    }

    func hash(into hasher: inout Hasher) {
        _value.sorted { l, r in
            l.key < r.key
        }
        .forEach { (key: UInt16, value: (Int, MTLDataType)) in
            hasher.combine(key)
            hasher.combine(value.0)
        }
    }
}
