//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Decodable property protocol implemented in Serialized where Wrapped Value is Decodable
public protocol DecodableProperty {
    typealias DecodeContainer = KeyedDecodingContainer<SerializedCodingKeys>
    
    func decodeValue(from container: DecodeContainer, propertyName: String) throws
}
