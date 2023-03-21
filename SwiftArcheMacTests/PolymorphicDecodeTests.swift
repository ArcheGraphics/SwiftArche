//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
import vox_render

extension CodingUserInfoKey {
    public static var polymorphicTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.polymophicTypes")!
    }
}

final class PolymorphicDecodeTests: XCTestCase {
    func testComponent() throws {
        let wrapper1 = PolymorphicValue<Component>(wrappedValue: Transform())
        let wrapper2 = PolymorphicValue<Component>(wrappedValue: Camera())
        let wrapperArray = [wrapper1, wrapper2]

        let data = try JSONEncoder().encode(wrapperArray)
        // let json = String(data: data, encoding: .utf8)

        let decoder = JSONDecoder()
        decoder.userInfo[.polymorphicTypes] = [
            Camera.self,
            Transform.self
        ]
        let model = try decoder.decode([PolymorphicValue<Component>].self, from: data)
        XCTAssertEqual((model[0].wrappedValue as! Transform).number, 0)
        XCTAssertEqual((model[1].wrappedValue as! Camera).name, "camera")
    }
    
    func testEncode() throws {
        let model = UserRecord(name: "A name", pet: Snake(name: "A Snake"))
        let data = try JSONEncoder().encode(model)
        XCTAssertEqual(
            String(data: data, encoding: .utf8),
            #"""
            {"name":"A name","pet":{"_type":"Snake","name":"A Snake"}}
            """#
        )
    }

    func testDecodeSnake() throws {
        let data = #"""
        {
          "name": "A name",
          "pet": {
            "_type": "Snake",
            "name": "A Snake"
          }
        }
        """#.data(using: .utf8)!
        let model = try makeDecoder().decode(UserRecord.self, from: data)
        XCTAssertEqual(model.name, "A name")
        let pet = try XCTUnwrap(model.pet as? Snake)
        XCTAssertEqual(pet.name, "A Snake")
    }
    
    func testDecodeDog() throws {
        let data = #"""
        {
          "name": "A name",
          "pet": {
            "_type": "Dog",
            "petName": "A dog"
          }
        }
        """#.data(using: .utf8)!
        let model = try makeDecoder().decode(UserRecord.self, from: data)
        XCTAssertEqual(model.name, "A name")
        let pet = try XCTUnwrap(model.pet as? Dog)
        XCTAssertEqual(pet.petName, "A dog")
    }

    func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.polymorphicTypes] = [
            Snake.self,
            Dog.self
        ]

        return decoder
    }
}

// MARK: - Protocol
struct UserRecord: Codable {
    let name: String

    @PolymorphicValue
    var pet: Animal
}

protocol Animal: Polymorphic {}

struct Snake: Animal {
    var name: String
}

struct Dog: Animal {
    var petName: String
}

// MARK: - Inheritence
fileprivate class Component: Polymorphic {
}

fileprivate class Transform: Component {
    var number: Int = 0

    enum CodingKeys: String, CodingKey {
        case number
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decode(Int.self, forKey: .number)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
    }
}

fileprivate class Camera: Component {
    var name: String = "camera"

    enum CodingKeys: String, CodingKey {
        case name
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
