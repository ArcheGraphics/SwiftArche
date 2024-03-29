//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

// MARK: - PolymorphicCodableError

enum PolymorphicCodableError: Error {
    case missingPolymorphicTypes
    case unableToFindPolymorphicType(String)
    case unableToCast(decoded: Polymorphic, into: String)
    case unableToRepresentAsPolymorphicForEncoding
}

// MARK: - Extension

public extension Encoder {
    func encode<ValueType>(_ value: ValueType) throws {
        guard let value = value as? Polymorphic else {
            throw PolymorphicCodableError.unableToRepresentAsPolymorphicForEncoding
        }
        var container = self.container(
            keyedBy: PolymorphicMetaContainerKeys.self
        )
        try container.encode(type(of: value).typeID, forKey: ._type)
        try value.encode(to: self)
    }
}

public extension Decoder {
    func decode<ExpectedType>(_: ExpectedType.Type, of key: CodingUserInfoKey) throws -> ExpectedType {
        let container = try self.container(keyedBy: PolymorphicMetaContainerKeys.self)
        let typeID = try container.decode(String.self, forKey: ._type)

        guard let types = userInfo[key] as? [Polymorphic.Type] else {
            throw PolymorphicCodableError.missingPolymorphicTypes
        }

        let _matchingType = types.first { type in
            type.typeID == typeID
        }

        guard let matchingType = _matchingType else {
            throw PolymorphicCodableError.unableToFindPolymorphicType(typeID)
        }

        let _decoded = try matchingType.init(from: self)

        guard let decoded = _decoded as? ExpectedType else {
            throw PolymorphicCodableError.unableToCast(
                decoded: _decoded,
                into: String(describing: ExpectedType.self)
            )
        }
        return decoded
    }
}

// MARK: - User Register

// MARK: - PolymorphicValue

@propertyWrapper
public struct PolymorphicValue<Value> {
    public var wrappedValue: Value
    var key: CodingUserInfoKey = .polymorphicTypes

    public init(wrappedValue: Value, key: CodingUserInfoKey = .polymorphicTypes) {
        self.wrappedValue = wrappedValue
        self.key = key
    }
}

extension PolymorphicValue: Codable {
    public init(from decoder: Decoder) throws {
        wrappedValue = try decoder.decode(Value.self, of: key)
    }

    public func encode(to encoder: Encoder) throws {
        try encoder.encode(wrappedValue)
    }
}

// MARK: - Polymorphic Protocol

public protocol Polymorphic: Codable {
    static var typeID: String { get }
}

public extension Polymorphic {
    static var typeID: String {
        String(describing: Self.self)
    }
}

enum PolymorphicMetaContainerKeys: CodingKey {
    case _type
}
