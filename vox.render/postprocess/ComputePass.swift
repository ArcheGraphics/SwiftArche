//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

open class ComputePass {
    private var _pipelineDescriptor = MTLComputePipelineDescriptor()

    public weak var resourceCache: ResourceCache?

    public var threadsPerGridX = 1
    public var threadsPerGridY = 1
    public var threadsPerGridZ = 1

    public var shader: [ShaderPass] = []
    public var data: [ShaderData] = []
    public weak var engine: Engine!
    public var defaultShaderData: ShaderData {
        get {
            data[0]
        }
    }

    public init(_ engine: Engine) {
        self.engine = engine
        data.append(ShaderData(engine))
    }

    /// Compute function
    /// - Parameter commandEncoder: CommandEncoder to use to record compute commands
    open func compute(commandEncoder: MTLComputeCommandEncoder) {
        if let resourceCache = resourceCache {
            let compileMacros = ShaderMacroCollection()
            for shaderData in data {
                ShaderMacroCollection.unionCollection(compileMacros, shaderData._macroCollection, compileMacros)
            }

            for shaderPass in shader {
                _pipelineDescriptor.computeFunction = resourceCache.requestShaderModule(shaderPass, compileMacros)[0]
                let pipelineState = resourceCache.requestComputePipeline(_pipelineDescriptor)
                for shaderData in data {
                    shaderData.bindData(commandEncoder, pipelineState.uniformBlock, resourceCache)
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
