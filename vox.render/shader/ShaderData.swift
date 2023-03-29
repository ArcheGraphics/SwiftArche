//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class ShaderData {
    private var _shaderDynamicBuffers: [[String: BufferView]] = []
    private var _shaderBuffers: [String: BufferView] = [:]
    private var _shaderBufferFunctors: [String: () -> BufferView] = [:]
    private var _imageViews: [String: MTLTexture] = [:]
    private var _samplers: [String: MTLSamplerDescriptor] = [:]
    static private var _defaultSamplerDesc: MTLSamplerDescriptor = MTLSamplerDescriptor()
    internal var _macroCollection = ShaderMacroCollection()

    public init() {
        _shaderDynamicBuffers = [[String: BufferView]](repeating: [:], count: Engine._maxFramesInFlight)
        ShaderData._defaultSamplerDesc.magFilter = .linear
        ShaderData._defaultSamplerDesc.minFilter = .linear
        ShaderData._defaultSamplerDesc.mipFilter = .linear
        ShaderData._defaultSamplerDesc.rAddressMode = .repeat
        ShaderData._defaultSamplerDesc.sAddressMode = .repeat
        ShaderData._defaultSamplerDesc.tAddressMode = .repeat
    }
    
    public func getData(_ property: String) -> BufferView? {
        _shaderBuffers[property]
    }

    public func setBufferFunctor(_ property: String, _ functor: @escaping () -> BufferView) {
        _shaderBufferFunctors[property] = functor
    }

    public func setData(_ property: String, _ value: BufferView) {
        _shaderBuffers[property] = value
    }

    public func setData<T>(_ property: String, _ data: T) {
        let value = _shaderBuffers.first { (key: String, value: BufferView) in
            key == property
        }
        if value == nil {
            _shaderBuffers[property] = BufferView(device: Engine.device, array: [data])
        } else {
            value!.value.assign(data)
        }
    }

    public func setData<T>(_ property: String, _ data: [T]) {
        let value = _shaderBuffers.first { (key: String, value: BufferView) in
            key == property
        }
        if value == nil {
            _shaderBuffers[property] = BufferView(device: Engine.device, array: data)
        } else {
            value!.value.assign(with: data)
        }
    }

    public func getData<T>(_ property: String, at index: Int = 0) -> T? {
        let value = _shaderBuffers.first { (key: String, value: BufferView) in
            key == property
        }
        if value == nil {
            return nil
        } else {
            return value!.value[index]
        }
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
    public func setDynamicData(_ property: String, _ value: BufferView) {
        _shaderDynamicBuffers[Engine.currentBufferIndex][property] = value
    }

    public func setDynamicData<T>(_ property: String, _ data: T) {
        let value = _shaderDynamicBuffers[Engine.currentBufferIndex].first { (key: String, value: BufferView) in
            key == property
        }
        if value == nil {
            _shaderDynamicBuffers[Engine.currentBufferIndex][property] = BufferView(device: Engine.device, array: [data])
        } else {
            value!.value.assign(data)
        }
    }

    public func setDynamicData<T>(_ property: String, _ data: [T]) {
        let value = _shaderDynamicBuffers[Engine.currentBufferIndex].first { (key: String, value: BufferView) in
            key == property
        }
        if value == nil {
            _shaderDynamicBuffers[Engine.currentBufferIndex][property] = BufferView(device: Engine.device, array: data)
        } else {
            value!.value.assign(with: data)
        }
    }
}

extension ShaderData {
    /// Enable macro.
    /// - Parameter name: Macro name
    public func enableMacro(_ name: UInt32) {
        _macroCollection._value[UInt16(name)] = (1, .bool)
    }

    /// Enable macro.
    /// - Parameters:
    ///   - name: Macro name
    ///   - value: Macro value
    public func enableMacro(_ name: UInt32, _ value: (Int, MTLDataType)) {
        _macroCollection._value[UInt16(name)] = value
    }

    /// Disable macro
    /// - Parameter name: Macro name    
    public func disableMacro(_ name: UInt32) {
        _macroCollection._value.removeValue(forKey: UInt16(name))
    }
}

extension ShaderData {
    func bindData(_ commandEncoder: MTLComputeCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform]) {
        for uniform in reflectionUniforms {
            switch uniform.bindingType {
            case .buffer:
                if let buffer = _shaderBuffers[uniform.name] {
                    commandEncoder.setBuffer(buffer.buffer, offset: 0, index: uniform.location)
                }
                if let buffer = _shaderDynamicBuffers[Engine.currentBufferIndex][uniform.name] {
                    commandEncoder.setBuffer(buffer.buffer, offset: 0, index: uniform.location)
                }
                if let bufferFunctor = _shaderBufferFunctors[uniform.name] {
                    commandEncoder.setBuffer(bufferFunctor().buffer, offset: 0, index: uniform.location)
                }
                break
            case .texture:
                if let image = _imageViews[uniform.name] {
                    commandEncoder.setTexture(image, index: uniform.location)
                }
                break
            case .sampler:
                if let sampler = _samplers[uniform.name] {
                    commandEncoder.setSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
                }
                break
            default:
                break
            }
        }
    }

    func bindData(_ commandEncoder: MTLRenderCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform]) {
        for uniform in reflectionUniforms {
            switch uniform.bindingType {
            case .buffer:
                if let buffer = _shaderBuffers[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexBuffer(buffer.buffer, offset: 0, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentBuffer(buffer.buffer, offset: 0, index: uniform.location)
                    }
                }
                if let buffer = _shaderDynamicBuffers[Engine.currentBufferIndex][uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexBuffer(buffer.buffer, offset: 0, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentBuffer(buffer.buffer, offset: 0, index: uniform.location)
                    }
                }
                if let bufferFunctor = _shaderBufferFunctors[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexBuffer(bufferFunctor().buffer, offset: 0, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentBuffer(bufferFunctor().buffer, offset: 0, index: uniform.location)
                    }
                }
                break
            case .texture:
                if let image = _imageViews[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexTexture(image, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentTexture(image, index: uniform.location)
                    }
                }
                break
            case .sampler:
                if let sampler = _samplers[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
                    }
                }
                break
            default:
                break
            }
        }
    }
}
