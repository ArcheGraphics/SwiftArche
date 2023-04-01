//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Reflection uniform。
struct ReflectionUniform {
    var name: String!
    var location: Int!
    var functionType: MTLFunctionType!
    var bindingType: MTLBindingType!
    var group: ShaderDataGroup!
}
