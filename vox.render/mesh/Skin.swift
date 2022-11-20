//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Mesh skin data, equal glTF skins define
public class Skin {
    public var inverseBindMatrices: [Matrix] = []
    public var joints: [String] = []
    public var skeleton: String = "none"
    public let name: String

    public init(_ name: String) {
        self.name = name
    }
}