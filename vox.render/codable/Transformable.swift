//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public typealias Transformable = TransformableFromJSON & TransformableToJSON

/// TransformableFromJSON protocol for JSON Decoding
public protocol TransformableFromJSON {
    associatedtype From: Any
    associatedtype To: Any

    static func transformFromJSON(value: From?) -> To?
}

/// TransformableToJSON for JSON Encoding
public protocol TransformableToJSON {
    associatedtype From: Any
    associatedtype To: Any

    static func transformToJSON(value: To?) -> From?
}
