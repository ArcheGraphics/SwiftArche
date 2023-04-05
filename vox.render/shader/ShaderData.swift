//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

struct ArgumentInfo {
    var desc: MTLArgumentDescriptor
    var encoder: MTLArgumentEncoder
    var bufferName: String
    var resource: MTLResource?

    init(desc: MTLArgumentDescriptor, encoder: MTLArgumentEncoder, bufferName: String) {
        self.desc = desc
        self.encoder = encoder
        self.bufferName = bufferName
    }
}

open class ShaderData {
    private var _argumentArray: [String: MTLArgumentDescriptor] = [:]
    private var _argumentDescriptors: [String: ArgumentInfo] = [:]
    private var _shaderBuffers: [String: (MTLBuffer, resource: Set<String>)] = [:]
    private var _shaderDynamicBuffers: [[String: BufferView]] = []
    private var _imageViews: [String: MTLTexture] = [:]
    private var _samplers: [String: MTLSamplerDescriptor] = [:]
    private static var _defaultSamplerDesc: MTLSamplerDescriptor = .init()
    internal var _macroCollection = ShaderMacroCollection()
    var group: ShaderDataGroup
    var resourceCache: ResourceCache

    init(group: ShaderDataGroup) {
        self.group = group
        resourceCache = Engine.resourceCache
        _shaderDynamicBuffers = [[String: BufferView]](repeating: [:], count: Engine._maxFramesInFlight)
        ShaderData._defaultSamplerDesc.magFilter = .linear
        ShaderData._defaultSamplerDesc.minFilter = .linear
        ShaderData._defaultSamplerDesc.mipFilter = .linear
        ShaderData._defaultSamplerDesc.rAddressMode = .repeat
        ShaderData._defaultSamplerDesc.sAddressMode = .repeat
        ShaderData._defaultSamplerDesc.tAddressMode = .repeat
        ShaderData._defaultSamplerDesc.supportArgumentBuffers = true
    }

    public func clear() {
        _argumentArray = [:]
        _argumentDescriptors = [:]
        _shaderBuffers = [:]
        _macroCollection.clear()
    }

    public func registerArgumentDescriptor(with name: String, descriptor: MTLArgumentDescriptor) {
        _argumentArray[name] = descriptor
    }

    public func createArgumentBuffer(with name: String) {
        resourceCache.setUniformName(with: name, group: group)

        let encoder = Engine.device.makeArgumentEncoder(arguments: _argumentArray.map { (_: String, value: MTLArgumentDescriptor) in
            value
        }.sorted(by: { lhs, rhs in
            lhs.index < rhs.index
        }))!
        let buffer = Engine.device.makeBuffer(length: encoder.encodedLength)!
        encoder.setArgumentBuffer(buffer, offset: 0)
        _shaderBuffers[name] = (buffer, [])
        _argumentArray.forEach { (key: String, value: MTLArgumentDescriptor) in
            _argumentDescriptors[key] = ArgumentInfo(desc: value, encoder: encoder, bufferName: name)
        }
        _argumentArray = [:]
    }

    public func setData<T>(with property: String, data: T) {
        var data = data
        if let argument = _argumentDescriptors[property] {
            argument.encoder.constantData(at: argument.desc.index).copyMemory(from: &data, byteCount: MemoryLayout<T>.stride)
        } else {
            resourceCache.setUniformName(with: property, group: group)
            let value = _shaderBuffers.first { (key: String, _: (MTLBuffer, Set<String>)) in
                key == property
            }

            if let value {
                value.value.0.contents().copyMemory(from: &data, byteCount: MemoryLayout<T>.stride)
            } else {
                _shaderBuffers[property] = (Engine.device.makeBuffer(bytes: &data, length: MemoryLayout<T>.stride)!, [])
            }
        }
    }

    public func setData<T>(with property: String, array: [T]) {
        if let argument = _argumentDescriptors[property] {
            argument.encoder.constantData(at: argument.desc.index).copyMemory(from: array, byteCount: MemoryLayout<T>.stride * array.count)
        } else {
            resourceCache.setUniformName(with: property, group: group)
            let value = _shaderBuffers.first { (key: String, _: (MTLBuffer, Set<String>)) in
                key == property
            }

            if let value {
                value.value.0.contents().copyMemory(from: array, byteCount: MemoryLayout<T>.stride * array.count)
            } else {
                _shaderBuffers[property] = (Engine.device.makeBuffer(bytes: array, length: MemoryLayout<T>.stride * array.count)!, [])
            }
        }
    }

    public func setData(with property: String, buffer: MTLBuffer?) {
        if let buffer {
            if let argument = _argumentDescriptors[property] {
                argument.encoder.setBuffer(buffer, offset: 0, index: argument.desc.index)
                _argumentDescriptors[property]!.resource = buffer
                _shaderBuffers[argument.bufferName]!.resource.insert(property)
            } else {
                resourceCache.setUniformName(with: property, group: group)
                _shaderBuffers[property] = (buffer, [])
            }
        } else {
            _argumentDescriptors.removeValue(forKey: property)
            _shaderBuffers.removeValue(forKey: property)
        }
    }

    public func setImageSampler(with textureName: String, _ sampler: String, texture: MTLTexture?) {
        setImageView(with: textureName, texture: texture)
        setSampler(with: sampler, sampler: nil)
    }

    public func setImageView(with name: String, texture: MTLTexture?) {
        if let texture {
            if let argument = _argumentDescriptors[name] {
                argument.encoder.setTexture(texture, index: argument.desc.index)
                _argumentDescriptors[name]!.resource = texture
                _shaderBuffers[argument.bufferName]!.resource.insert(name)
            } else {
                resourceCache.setUniformName(with: name, group: group)
                _imageViews[name] = texture
            }
        } else {
            _argumentDescriptors.removeValue(forKey: name)
            _shaderBuffers.removeValue(forKey: name)
        }
    }

    public func setSampler(with name: String, sampler: MTLSamplerDescriptor?) {
        if let argument = _argumentDescriptors[name] {
            if let sampler {
                argument.encoder.setSamplerState(resourceCache.requestSamplers(sampler), index: argument.desc.index)
            } else {
                argument.encoder.setSamplerState(resourceCache.requestSamplers(ShaderData._defaultSamplerDesc), index: argument.desc.index)
            }
        } else {
            resourceCache.setUniformName(with: name, group: group)
            if let sampler {
                _samplers[name] = sampler
            } else {
                _samplers[name] = ShaderData._defaultSamplerDesc
            }
        }
    }
}

public extension ShaderData {
    func setDynamicData(with property: String, buffer: BufferView) {
        resourceCache.setUniformName(with: property, group: group)
        _shaderDynamicBuffers[Engine.currentBufferIndex][property] = buffer
    }

    func setDynamicData<T>(with property: String, data: T) {
        resourceCache.setUniformName(with: property, group: group)
        let value = _shaderDynamicBuffers[Engine.currentBufferIndex].first { (key: String, _: BufferView) in
            key == property
        }
        if value == nil {
            _shaderDynamicBuffers[Engine.currentBufferIndex][property] = BufferView(array: [data])
        } else {
            value!.value.assign(data)
        }
    }

    func setDynamicData<T>(with property: String, array: [T]) {
        resourceCache.setUniformName(with: property, group: group)
        let value = _shaderDynamicBuffers[Engine.currentBufferIndex].first { (key: String, _: BufferView) in
            key == property
        }
        if value == nil {
            _shaderDynamicBuffers[Engine.currentBufferIndex][property] = BufferView(array: array)
        } else {
            value!.value.assign(with: array)
        }
    }
}

public extension ShaderData {
    /// Enable macro.
    /// - Parameter name: Macro name
    func enableMacro(_ name: UInt32) {
        _macroCollection._value[UInt16(name)] = (1, .bool)
    }

    /// Enable macro.
    /// - Parameters:
    ///   - name: Macro name
    ///   - value: Macro value
    func enableMacro(_ name: UInt32, _ value: (Int, MTLDataType)) {
        _macroCollection._value[UInt16(name)] = value
    }

    /// Disable macro
    /// - Parameter name: Macro name
    func disableMacro(_ name: UInt32) {
        _macroCollection._value.removeValue(forKey: UInt16(name))
    }
}

extension ShaderData {
    func bindData(_ commandEncoder: MTLComputeCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform])
    {
        for uniform in reflectionUniforms {
            if uniform.group != group {
                continue
            }

            switch uniform.bindingType {
            case .buffer:
                if let buffer = _shaderBuffers[uniform.name] {
                    if !buffer.resource.isEmpty {
                        buffer.resource.forEach { resourceName in
                            var resources: [MTLResource] = []
                            if let argument = _argumentDescriptors[resourceName] {
                                resources.append(argument.resource!)
                            }
                            commandEncoder.useResources(resources, usage: .read)
                        }
                    }
                    commandEncoder.setBuffer(buffer.0, offset: 0, index: uniform.location)
                }
                if let bufferView = _shaderDynamicBuffers[Engine.currentBufferIndex][uniform.name] {
                    commandEncoder.setBuffer(bufferView.buffer, offset: 0, index: uniform.location)
                }
            case .texture:
                if let image = _imageViews[uniform.name] {
                    commandEncoder.setTexture(image, index: uniform.location)
                }
            case .sampler:
                if let sampler = _samplers[uniform.name] {
                    commandEncoder.setSamplerState(resourceCache.requestSamplers(sampler), index: uniform.location)
                }
            default:
                break
            }
        }
    }

    func bindData(_ commandEncoder: MTLRenderCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform])
    {
        for uniform in reflectionUniforms {
            if uniform.group != group {
                continue
            }

            switch uniform.bindingType {
            case .buffer:
                if let buffer = _shaderBuffers[uniform.name] {
                    var resources: [MTLResource] = []
                    if !buffer.resource.isEmpty {
                        buffer.resource.forEach { resourceName in
                            if let argument = _argumentDescriptors[resourceName] {
                                resources.append(argument.resource!)
                            }
                        }
                    }
                    if uniform.functionType == .vertex {
                        commandEncoder.useResources(resources, usage: .read, stages: .vertex)
                        commandEncoder.setVertexBuffer(buffer.0, offset: 0, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.useResources(resources, usage: .read, stages: .fragment)
                        commandEncoder.setFragmentBuffer(buffer.0, offset: 0, index: uniform.location)
                    }
                }
                if let bufferView = _shaderDynamicBuffers[Engine.currentBufferIndex][uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexBuffer(bufferView.buffer, offset: 0, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentBuffer(bufferView.buffer, offset: 0, index: uniform.location)
                    }
                }
            case .texture:
                if let image = _imageViews[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexTexture(image, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentTexture(image, index: uniform.location)
                    }
                }
            case .sampler:
                if let sampler = _samplers[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
                    }
                }
            default:
                break
            }
        }
    }
}
