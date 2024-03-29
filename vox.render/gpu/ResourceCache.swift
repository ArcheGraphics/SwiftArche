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
public class ResourceCache {
    private var device: MTLDevice
    var shader_modules: [Int: (resource: MTLFunction, useCount: Int)] = [:]
    var graphics_pipelines: [Int: (resource: RenderPipelineState, useCount: Int)] = [:]
    var compute_pipelines: [Int: (resource: ComputePipelineState, useCount: Int)] = [:]
    var samplers: [Int: (resource: MTLSamplerState, useCount: Int)] = [:]
    var depth_stencil_states: [Int: (resource: MTLDepthStencilState, useCount: Int)] = [:]
    var uniformNameMap: [String: ShaderDataGroup] = [:]

    public init(_ device: MTLDevice) {
        self.device = device
    }

    func setUniformName(with name: String, group: ShaderDataGroup) {
        // can upgrade to make warn if exits
        uniformNameMap[name] = group
    }

    func requestGraphicsPipeline(_ pipelineDescriptor: MTLRenderPipelineDescriptor) -> RenderPipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = graphics_pipelines[hash]
        if pipelineState == nil {
            pipelineState = (RenderPipelineState(device, pipelineDescriptor), 0)
            graphics_pipelines[hash] = pipelineState
        } else {
            graphics_pipelines[hash]!.useCount += 1
        }

        return pipelineState!.resource
    }

    func requestComputePipeline(_ pipelineDescriptor: MTLComputePipelineDescriptor) -> ComputePipelineState {
        let hash = pipelineDescriptor.hash
        var pipelineState = compute_pipelines[hash]
        if pipelineState == nil {
            pipelineState = (ComputePipelineState(device, pipelineDescriptor), 0)
            compute_pipelines[hash] = pipelineState
        } else {
            compute_pipelines[hash]!.useCount += 1
        }

        return pipelineState!.resource
    }

    func requestSamplers(_ descriptor: MTLSamplerDescriptor) -> MTLSamplerState {
        let hash = descriptor.hash
        var sampler = samplers[hash]
        if sampler == nil {
            sampler = (device.makeSamplerState(descriptor: descriptor)!, 0)
            samplers[hash] = sampler
        } else {
            samplers[hash]!.useCount += 1
        }

        return sampler!.resource
    }

    func requestDepthStencilState(_ descriptor: MTLDepthStencilDescriptor) -> MTLDepthStencilState {
        let hash = descriptor.hash
        var state = depth_stencil_states[hash]
        if state == nil {
            state = (device.makeDepthStencilState(descriptor: descriptor)!, 0)
            depth_stencil_states[hash] = state
        } else {
            depth_stencil_states[hash]!.useCount += 1
        }

        return state!.resource
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
                    shader_modules[hash] = (function!, 0)
                    functions.append(function!)
                }
            } else {
                shader_modules[hash]!.useCount += 1
                functions.append(cacheFunction!.resource)
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

    func garbageCollection(below threshold: Int) {
        gc(&shader_modules, threshold: threshold)
        gc(&graphics_pipelines, threshold: threshold)
        gc(&compute_pipelines, threshold: threshold)
        gc(&samplers, threshold: threshold)
        gc(&depth_stencil_states, threshold: threshold)
    }

    func gc<T>(_ contain: inout [Int: (resource: T, useCount: Int)], threshold: Int) -> Void {
        contain = contain.filter { element in
            element.value.useCount > threshold
        }.mapValues { element in
            var element = element
            element.useCount = 0
            return element
        }
    }
}
