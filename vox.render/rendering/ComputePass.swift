//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class ComputePass {
    private var _pipelineDescriptor = MTLComputePipelineDescriptor()

    public weak var devicePipeline: DevicePipeline?

    public var threadsPerGridX = 1
    public var threadsPerGridY = 1
    public var threadsPerGridZ = 1

    public var shader: [ShaderPass] = []
    public var data: [ShaderData] = []
    
    var defaultShaderData: ShaderData {
        get {
            data[0]
        }
    }

    public init(_ device: MTLDevice) {
        data.append(ShaderData(device))
    }

    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    public func compute(commandEncoder: MTLComputeCommandEncoder) {
        if let devicePipeline = devicePipeline {
            let compileMacros = ShaderMacroCollection()
            for shaderData in data {
                ShaderMacroCollection.unionCollection(compileMacros, shaderData._macroCollection, compileMacros)
            }

            for shaderPass in shader {
                _pipelineDescriptor.computeFunction = devicePipeline._resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
                let pipelineState = devicePipeline._resourceCache.requestComputePipeline(_pipelineDescriptor)
                for shaderData in data {
                    shaderData.bindData(commandEncoder, pipelineState.uniformBlock, devicePipeline._resourceCache)
                }
                commandEncoder.setComputePipelineState(pipelineState.handle)

                let nWidth = min(threadsPerGridX, pipelineState.handle.threadExecutionWidth)
                let nHeight = min(threadsPerGridY, pipelineState.handle.maxTotalThreadsPerThreadgroup / nWidth)
                commandEncoder.dispatchThreads(MTLSize(width: threadsPerGridX, height: threadsPerGridY, depth: threadsPerGridZ),
                        threadsPerThreadgroup: MTLSize(width: nWidth, height: nHeight, depth: 1))
            }
        }
    }
}
