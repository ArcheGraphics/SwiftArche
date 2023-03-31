//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class ComputePass {
    private var _pipelineDescriptor = MTLComputePipelineDescriptor()
    private var _precompilePSO: [ComputePipelineState] = []
    private var _passData: (ShaderData, FrameData)

    public var threadsPerGridX = 1
    public var threadsPerGridY = 1
    public var threadsPerGridZ = 1

    public var shader: [ShaderPass] = []

    public init(_ scene: Scene) {
        _passData = (scene.shaderData, Engine.fg.frameData)
    }
    
    /// generate PSO before calculation only work for shader without function constant values.
    public func precompileAll() {
        _precompilePSO.removeAll()
        _precompilePSO.reserveCapacity(shader.count)
        let compileMacros = ShaderMacroCollection()
        for shaderPass in shader {
            _pipelineDescriptor.computeFunction = Engine.resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
            _precompilePSO.append(Engine.resourceCache.requestComputePipeline(_pipelineDescriptor))
        }
    }

    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    public func compute(commandEncoder: MTLComputeCommandEncoder, label: String = "") {
        commandEncoder.pushDebugGroup(label)
        if _precompilePSO.isEmpty {
            var compileMacros = ShaderMacroCollection()
            ShaderMacroCollection.unionCollection(compileMacros, _passData.0._macroCollection, &compileMacros)
            ShaderMacroCollection.unionCollection(compileMacros, _passData.1._macroCollection, &compileMacros)
            
            for shaderPass in shader {
                _pipelineDescriptor.computeFunction = Engine.resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
                let pipelineState = Engine.resourceCache.requestComputePipeline(_pipelineDescriptor)
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                
                let nWidth = min(threadsPerGridX, pipelineState.handle.threadExecutionWidth)
                let nHeight = min(threadsPerGridY, pipelineState.handle.maxTotalThreadsPerThreadgroup / nWidth)
                commandEncoder.dispatchThreads(MTLSize(width: threadsPerGridX, height: threadsPerGridY, depth: threadsPerGridZ),
                                               threadsPerThreadgroup: MTLSize(width: nWidth, height: threadsPerGridY == 1 ? 1 : nHeight, depth: 1))
            }
        } else {
            for pipelineState in _precompilePSO {
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                
                let nWidth = min(threadsPerGridX, pipelineState.handle.threadExecutionWidth)
                let nHeight = min(threadsPerGridY, pipelineState.handle.maxTotalThreadsPerThreadgroup / nWidth)
                commandEncoder.dispatchThreads(MTLSize(width: threadsPerGridX, height: threadsPerGridY, depth: threadsPerGridZ),
                                               threadsPerThreadgroup: MTLSize(width: nWidth, height: threadsPerGridY == 1 ? 1 : nHeight, depth: 1))
            }
        }
        commandEncoder.popDebugGroup()
    }
    
    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    public func compute(commandEncoder: MTLComputeCommandEncoder,
                        threadgroupsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize, label: String = "") {
        commandEncoder.pushDebugGroup(label)
        if _precompilePSO.isEmpty {
            var compileMacros = ShaderMacroCollection()
            ShaderMacroCollection.unionCollection(compileMacros, _passData.0._macroCollection, &compileMacros)
            ShaderMacroCollection.unionCollection(compileMacros, _passData.1._macroCollection, &compileMacros)
            
            for shaderPass in shader {
                _pipelineDescriptor.computeFunction = Engine.resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
                let pipelineState = Engine.resourceCache.requestComputePipeline(_pipelineDescriptor)
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            }
        } else {
            for pipelineState in _precompilePSO {
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            }
        }
        commandEncoder.popDebugGroup()
    }
    
    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    public func compute(commandEncoder: MTLComputeCommandEncoder,
                        indirectBuffer: MTLBuffer, threadsPerThreadgroup: MTLSize, label: String = "") {
        commandEncoder.pushDebugGroup(label)
        if _precompilePSO.isEmpty {
            var compileMacros = ShaderMacroCollection()
            ShaderMacroCollection.unionCollection(compileMacros, _passData.0._macroCollection, &compileMacros)
            ShaderMacroCollection.unionCollection(compileMacros, _passData.1._macroCollection, &compileMacros)
            
            for shaderPass in shader {
                _pipelineDescriptor.computeFunction = Engine.resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
                let pipelineState = Engine.resourceCache.requestComputePipeline(_pipelineDescriptor)
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                commandEncoder.dispatchThreadgroups(indirectBuffer: indirectBuffer,
                                                    indirectBufferOffset: 0, threadsPerThreadgroup: threadsPerThreadgroup)
            }
        } else {
            for pipelineState in _precompilePSO {
                _passData.0.bindData(commandEncoder, pipelineState.uniformBlock)
                _passData.1.bindData(commandEncoder, pipelineState.uniformBlock)
                commandEncoder.setComputePipelineState(pipelineState.handle)
                commandEncoder.dispatchThreadgroups(indirectBuffer: indirectBuffer,
                                                    indirectBufferOffset: 0, threadsPerThreadgroup: threadsPerThreadgroup)
            }
        }
        commandEncoder.popDebugGroup()
    }
}
