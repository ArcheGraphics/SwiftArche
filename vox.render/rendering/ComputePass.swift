//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class ComputePass {
    private var _devicePipeline: DevicePipeline
    private var _pipelineDescriptor = MTLComputePipelineDescriptor()

    public var threadsPerGridX = 1
    public var threadsPerGridY = 1
    public var threadsPerGridZ = 1

    public var shader: [ShaderPass] = []
    public var data: [ShaderData] = []

    public init(_ devicePipeline: DevicePipeline) {
        _devicePipeline = devicePipeline
    }

    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    func compute(commandEncoder: MTLComputeCommandEncoder) {
        let compileMacros = ShaderMacroCollection()
        for shaderData in data {
            ShaderMacroCollection.unionCollection(compileMacros, shaderData._macroCollection, compileMacros)
        }

        for shaderPass in shader {
            _pipelineDescriptor.computeFunction =  _devicePipeline._resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
            let pipelineState = _devicePipeline._resourceCache.requestComputePipeline(_pipelineDescriptor)
            for shaderData in data {
                shaderData.bindData(commandEncoder, pipelineState.uniformBlock, _devicePipeline._resourceCache)
            }
            commandEncoder.setComputePipelineState(pipelineState.handle)

            let nWidth = min(threadsPerGridX, pipelineState.handle.threadExecutionWidth)
            let nHeight = min(threadsPerGridY, pipelineState.handle.maxTotalThreadsPerThreadgroup / nWidth)
            commandEncoder.dispatchThreads(MTLSize(width: threadsPerGridX, height: threadsPerGridY, depth: threadsPerGridZ),
                    threadsPerThreadgroup: MTLSize(width: nWidth, height: nHeight, depth: 1))
        }
    }
}