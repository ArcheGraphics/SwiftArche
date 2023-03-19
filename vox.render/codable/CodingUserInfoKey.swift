//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

extension CodingUserInfoKey {
    public static var engine: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.engine")!
    }
    public static var polymorphicTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.polymophicTypes")!
    }
}

public func makeDecoder(for engine: Engine) -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.userInfo[.engine] = engine
    decoder.userInfo[.polymorphicTypes] = Entity.ComponentType
    return decoder
}
