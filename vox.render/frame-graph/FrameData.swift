//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class FrameData {
    private var _shaderBuffers: [String: BufferAllocation] = [:]
    private var _imageViews: [String: MTLTexture] = [:]
    private var _samplers: [String: MTLSamplerDescriptor] = [:]
    private static var _defaultSamplerDesc: MTLSamplerDescriptor = .init()
    internal var _macroCollection = ShaderMacroCollection()
    var group: ShaderDataGroup = .Frame
    var resourceCache: ResourceCache

    public init() {
        resourceCache = Engine.resourceCache
        FrameData._defaultSamplerDesc.magFilter = .linear
        FrameData._defaultSamplerDesc.minFilter = .linear
        FrameData._defaultSamplerDesc.mipFilter = .linear
        FrameData._defaultSamplerDesc.rAddressMode = .repeat
        FrameData._defaultSamplerDesc.sAddressMode = .repeat
        FrameData._defaultSamplerDesc.tAddressMode = .repeat
    }

    public func clear() {
        _shaderBuffers = [:]
        _imageViews = [:]
        _samplers = [:]
        _macroCollection.clear()
    }

    public func getData(_ property: String) -> BufferAllocation? {
        _shaderBuffers[property]
    }

    public func setData(_ property: String, _ value: BufferAllocation) {
        resourceCache.setUniformName(with: property, group: group)
        _shaderBuffers[property] = value
    }

    public func setImageView(_ textureName: String, _ samplerName: String, _ value: MTLTexture?) {
        resourceCache.setUniformName(with: textureName, group: group)
        resourceCache.setUniformName(with: samplerName, group: group)

        if value != nil {
            _imageViews[textureName] = value
            let sampler = _samplers.firstIndex { (key: String, _: MTLSamplerDescriptor) in
                key == samplerName
            }
            if sampler == nil {
                _samplers[samplerName] = FrameData._defaultSamplerDesc
            }
        } else {
            _imageViews.removeValue(forKey: textureName)
            _samplers.removeValue(forKey: samplerName)
        }
    }

    public func setImageView(_ name: String, _ value: MTLTexture?) {
        resourceCache.setUniformName(with: name, group: group)

        if value != nil {
            _imageViews[name] = value
        } else {
            _imageViews.removeValue(forKey: name)
        }
    }

    public func setSampler(_ name: String, _ value: MTLSamplerDescriptor?) {
        resourceCache.setUniformName(with: name, group: group)

        if value != nil {
            _samplers[name] = value
        } else {
            _samplers.removeValue(forKey: name)
        }
    }
}

public extension FrameData {
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

extension FrameData {
    func bindData(_ commandEncoder: MTLComputeCommandEncoder,
                  _ reflectionUniforms: [ReflectionUniform])
    {
        for uniform in reflectionUniforms {
            if uniform.group != group {
                continue
            }

            switch uniform.bindingType {
            case .buffer:
                if let bufferAlloc = _shaderBuffers[uniform.name] {
                    commandEncoder.setBuffer(bufferAlloc.buffer, offset: bufferAlloc.offset, index: uniform.location)
                }
            case .texture:
                if let image = _imageViews[uniform.name] {
                    commandEncoder.setTexture(image, index: uniform.location)
                }
            case .sampler:
                if let sampler = _samplers[uniform.name] {
                    commandEncoder.setSamplerState(Engine.resourceCache.requestSamplers(sampler), index: uniform.location)
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
                if let bufferAlloc = _shaderBuffers[uniform.name] {
                    if uniform.functionType == .vertex {
                        commandEncoder.setVertexBuffer(bufferAlloc.buffer, offset: bufferAlloc.offset, index: uniform.location)
                    }
                    if uniform.functionType == .fragment {
                        commandEncoder.setFragmentBuffer(bufferAlloc.buffer, offset: bufferAlloc.offset, index: uniform.location)
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
