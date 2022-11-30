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
    var graphics_pipelines: [Int: RenderPipelineState] = [:]
    var compute_pipelines: [Int: ComputePipelineState] = [:]
    var samplers: [Int: MTLSamplerState] = [:]
    var depth_stencil_states: [Int: MTLDepthStencilState] = [:]

    init(_ device: MTLDevice) {
        self.device = device
    }

    func requestGraphicsPipeline(_ pipelineDescriptor: MTLRenderPipelineDescriptor) -> RenderPipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = graphics_pipelines[hash]
        if pipelineState == nil {
            pipelineState = RenderPipelineState(device, pipelineDescriptor)
            graphics_pipelines[hash] = pipelineState
        }

        return pipelineState!
    }

    func requestComputePipeline(_ pipelineDescriptor: MTLComputePipelineDescriptor) -> ComputePipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = compute_pipelines[hash]
        if pipelineState == nil {
            pipelineState = ComputePipelineState(device, pipelineDescriptor)
            compute_pipelines[hash] = pipelineState
        }

        return pipelineState!
    }

    func requestSamplers(_ descriptor: MTLSamplerDescriptor) -> MTLSamplerState {
        let hash = descriptor.hash
        var sampler = samplers[hash]
        if sampler == nil {
            sampler = device.makeSamplerState(descriptor: descriptor)
            samplers[hash] = sampler
        }

        return sampler!
    }

    func requestDepthStencilState(_ descriptor: MTLDepthStencilDescriptor) -> MTLDepthStencilState {
        let hash = descriptor.hash
        var state = depth_stencil_states[hash]
        if state == nil {
            state = device.makeDepthStencilState(descriptor: descriptor)
            depth_stencil_states[hash] = state
        }

        return state!
    }

    func requestShaderModule(_ shaderPass: ShaderPass, _ macroInfo: ShaderMacroCollection) -> [MTLFunction] {
        var functions: [MTLFunction] = []
        for shader in shaderPass._shaders {
            var hasher = Hasher()
            shader.hash(into: &hasher)
            macroInfo.hash(into: &hasher)
            if let library = shaderPass.library {
                hasher.combine(library.hash)
            }
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

    func clear() {
        shader_modules = [:]
        graphics_pipelines = [:]
        compute_pipelines = [:]
        depth_stencil_states = [:]
        samplers = [:]
    }
}
