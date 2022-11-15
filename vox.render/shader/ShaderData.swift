//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class ShaderData {
    private var _device: MTLDevice
    private var _shaderBuffers: [String: MTLBuffer] = [:]
    private var _imageViews: [String: MTLTexture] = [:]
    private var _samplers: [String: MTLSamplerDescriptor] = [:]
    static private var _defaultSamplerDesc: MTLSamplerDescriptor = MTLSamplerDescriptor()
    internal var _macroCollection = ShaderMacroCollection()

    public init(_ device: MTLDevice) {
        _device = device
    }

    func bindData(_ commandEncoder: MTLComputeCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform],
                  _ resourceCache: ResourceCache) {
        for uniform in reflectionUniforms {
            switch uniform.bindingType {
            case .buffer:
                let buffer = _shaderBuffers[uniform.name]
                if buffer != nil {
                    commandEncoder.setBuffer(buffer!, offset: 0, index: uniform.location)
                }
                break
            case .texture:
                let image = _imageViews[uniform.name]
                if image != nil {
                    commandEncoder.setTexture(image!, index: uniform.location)
                }
                break
            case .sampler:
                let sampler = _samplers[uniform.name]
                if sampler != nil {
                    commandEncoder.setSamplerState(resourceCache.requestSamplers(sampler!), index: uniform.location)
                }
                break
            default:
                break
            }
        }
    }

    public func setData<T>(_ property: String, _ data: T) {
        let value = _shaderBuffers.first { (key: String, value: MTLBuffer) in
            key == property
        }
        var buffer: MTLBuffer
        if value == nil {
            buffer = _device.makeBuffer(length: MemoryLayout<T>.size)!
            _shaderBuffers[property] = buffer
        } else {
            buffer = value!.value
        }

        let pointer = buffer.contents().bindMemory(to: T.self, capacity: MemoryLayout<T>.size)
        pointer.pointee = data
    }

    public func setData<T>(_ property: String, _ data: [T]) {
        let value = _shaderBuffers.first { (key: String, value: MTLBuffer) in
            key == property
        }
        var buffer: MTLBuffer
        if value == nil {
            buffer = _device.makeBuffer(length: MemoryLayout<T>.size * data.count)!
            _shaderBuffers[property] = buffer
        } else {
            buffer = value!.value
        }

        let pointer = buffer.contents().bindMemory(to: T.self, capacity: MemoryLayout<T>.size * data.count)
        pointer.assign(from: data, count: data.count)
    }

    public func setImageView(_ textureName: String, _ samplerName: String, _ value: MTLTexture?) {
        if value != nil {
            _imageViews[textureName] = value
            let sampler = _samplers.firstIndex { (key: String, value: MTLSamplerDescriptor) in
                key == samplerName
            }
            if sampler == nil {
                _samplers[samplerName] = ShaderData._defaultSamplerDesc
            }
        } else {
            _imageViews.removeValue(forKey: textureName)
            _samplers.removeValue(forKey: samplerName)
        }
    }

    public func setImageView(_ name: String, _ value: MTLTexture?) {
        if value != nil {
            _imageViews[name] = value
        } else {
            _imageViews.removeValue(forKey: name)
        }
    }

    public func setSampler(_ name: String, _ value: MTLSamplerDescriptor?) {
        if value != nil {
            _samplers[name] = value
        } else {
            _samplers.removeValue(forKey: name)
        }
    }
}

extension ShaderData {
    /// Enable macro.
    /// - Parameter name: Macro name
    public func enableMacro(_ name: MacroName) {
        _macroCollection._value[name] = (1, .bool)
    }

    /// Enable macro.
    /// - Parameters:
    ///   - name: Macro name
    ///   - value: Macro value
    public func enableMacro(_ name: MacroName, _ value: (Int, MTLDataType)) {
        _macroCollection._value[name] = value
    }

    /// Disable macro
    /// - Parameter name: Macro name
    public func disableMacro(_ name: MacroName) {
        _macroCollection._value.removeValue(forKey: name)
    }
}