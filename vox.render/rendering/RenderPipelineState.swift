//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class RenderPipelineState {
    private var _reflection: MTLRenderPipelineReflection?
    private var _handle: MTLRenderPipelineState?

    var uploadRenderCount: UInt64 = .max
    var uploadScene: Scene?
    var uploadCamera: Camera?
    var uploadRenderer: Renderer?
    var uploadMaterial: Material?
    var uploadMesh: Mesh?

    var uniformBlock: [ReflectionUniform] = []

    var handle: MTLRenderPipelineState {
        _handle!
    }

    var reflection: MTLRenderPipelineReflection {
        _reflection!
    }

    init(_ device: MTLDevice, _ descriptor: MTLRenderPipelineDescriptor) {
        do {
            _handle = try device.makeRenderPipelineState(descriptor: descriptor,
                                                         options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch {
            fatalError(error.localizedDescription)
        }

        _recordLocation()
    }

    /// record the location of uniform/attribute.
    private func _recordLocation() {
        guard let _reflection = _reflection else {
            return
        }

        // isUsed have bug when no-debug
        var count = _reflection.vertexBindings.count
        if count != 0 {
            for i in 0 ..< count {
                let aug = _reflection.vertexBindings[i]
                var shaderUniform = ReflectionUniform()
                shaderUniform.name = aug.name
                shaderUniform.location = aug.index
                shaderUniform.functionType = .vertex
                shaderUniform.bindingType = aug.type
                shaderUniform.group = Engine.resourceCache.uniformNameMap[aug.name]
                uniformBlock.append(shaderUniform)
            }
        }

        count = _reflection.fragmentBindings.count
        if count != 0 {
            for i in 0 ..< count {
                let aug = _reflection.fragmentBindings[i]
                var shaderUniform = ReflectionUniform()
                shaderUniform.name = aug.name
                shaderUniform.location = aug.index
                shaderUniform.functionType = .fragment
                shaderUniform.bindingType = aug.type
                shaderUniform.group = Engine.resourceCache.uniformNameMap[aug.name]
                uniformBlock.append(shaderUniform)
            }
        }
    }
}
