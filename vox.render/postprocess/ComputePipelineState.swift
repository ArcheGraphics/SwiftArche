//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

class ComputePipelineState {
    private var _reflection: MTLComputePipelineReflection?
    private var _handle: MTLComputePipelineState?

    var uniformBlock: [ReflectionUniform] = []

    var handle: MTLComputePipelineState {
        get {
            return _handle!
        }
    }

    var reflection: MTLComputePipelineReflection {
        get {
            return _reflection!
        }
    }

    init(_ device: MTLDevice, _ descriptor: MTLComputePipelineDescriptor) {
        do {
            _handle = try device.makeComputePipelineState(descriptor: descriptor,
                    options: MTLPipelineOption.argumentInfo, reflection: &_reflection)
        } catch let error {
            fatalError(error.localizedDescription)
        }

        _recordLocation()
    }

    /// record the location of uniform/attribute.
    private func _recordLocation() {
        guard let _reflection = _reflection else {
            return
        }

        let count = _reflection.bindings.count
        if count != 0 {
            for i in 0..<count {
                let aug = _reflection.bindings[i]
                var shaderUniform = ReflectionUniform()
                shaderUniform.name = aug.name
                shaderUniform.location = aug.index
                shaderUniform.functionType = .kernel
                shaderUniform.bindingType = aug.type
                uniformBlock.append(shaderUniform)
            }
        }
    }
}

