//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Cache all sorts of Metal objects specific to a Metal device.
/// Supports serialization and deserialization of cached resources.
/// There is only one cache for all these objects, with several unordered_map of hash indices
/// and objects. For every object requested, there is a templated version on request_resource.
/// Some objects may need building if they are not found in the cache.
///
/// The resource cache is also linked with ResourceRecord and ResourceReplay. Replay can warm-up
/// the cache on app startup by creating all necessary objects.
/// The cache holds pointers to objects and has a mapping from such pointers to hashes.
/// It can only be destroyed in bulk, single elements cannot be removed.
class ResourceCache {
    private var device: MTLDevice
    var shader_modules: [Int: MTLFunction] = [:]

    init(_ device: MTLDevice) {
        self.device = device
    }

    func requestShaderModule(_ shaderPass: ShaderPass, _ macroInfo: ShaderMacroCollection) -> [MTLFunction] {
        var functions: [MTLFunction] = []
        for shader in shaderPass._shaders {
            var hasher = Hasher()
            shader.hash(into: &hasher)
            macroInfo.hash(into: &hasher)
            hasher.combine(shaderPass._library.hash)
            let hash = hasher.finalize()
            let cacheFunction = shader_modules[hash]
            if cacheFunction == nil {
                let function = shaderPass.createProgram(shader, macroInfo)
                if function != nil {
                    shader_modules[hash] = function!
                    functions.append(function!)
                }
            } else {
                functions.append(cacheFunction!)
            }
        }
        return functions
    }
}
