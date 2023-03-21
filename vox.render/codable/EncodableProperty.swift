//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.
import Foundation

/// Encodable property protocol implemented in Serialized where Wrapped Value is Encodable
public protocol EncodableProperty {
    typealias EncodeContainer = KeyedEncodingContainer<SerializedCodingKeys>

    func encodeValue(from container: inout EncodeContainer, propertyName: String) throws
}
