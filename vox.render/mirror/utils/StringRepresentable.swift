//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

protocol StringRepresentable {
    init?(stringRepresentation: String)
    var stringRepresentation: String { get }
}

extension StringRepresentable {
    var stringRepresentation: String {
        "\(self)"
    }
}

extension String: StringRepresentable {
    init?(stringRepresentation: String) {
        self = stringRepresentation
    }

    var stringRepresentation: String {
        return self
    }
}
