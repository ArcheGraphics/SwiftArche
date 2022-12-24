//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class HashGrid {
    var _engine: Engine
    var _gridSpacing: Float = 1.0;
    var _resolution: SIMD3<UInt32> = SIMD3<UInt32>(1, 1, 1)
    var _sortedIndices: BufferView!
    let _indirectArgsBuffer: BufferView
    let _shaderData: ShaderData
    
    let _fillPass: ComputePass
    let _initArgsPass: ComputePass
    let _preparePass: ComputePass
    let _buildPass: ComputePass
    let _sortPass: BitonicSort

    public var shaderData: ShaderData {
        get {
            _shaderData
        }
    }
    
    public static func builder() -> Builder {
        HashGrid.Builder()
    }
    
    public init(_ engine: Engine,
                _ resolutionX: UInt32,
                _ resolutionY: UInt32,
                _ resolutionZ: UInt32,
                _ gridSpacing: Float) {
        _engine = engine
        _resolution.x = max(resolutionX, 1)
        _resolution.y = max(resolutionY, 1)
        _resolution.z = max(resolutionZ, 1)
        _gridSpacing = gridSpacing
        _shaderData = ShaderData(engine)
        
        _indirectArgsBuffer = BufferView(device: engine.device, count: 1,
                                         stride: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride)
        
        let totalCount = Int(_resolution.x * _resolution.y * _resolution.z)
        _shaderData.setData("u_startIndexTable",
                            BufferView.init(device: engine.device, count: totalCount,
                                            stride: MemoryLayout<UInt>.stride))
        _shaderData.setData("u_endIndexTable",
                            BufferView.init(device: engine.device, count: totalCount,
                                            stride: MemoryLayout<UInt>.stride))
        _shaderData.setData("u_hashGridData", BufferView(device: engine.device,
                                                         array: [HashGridData(resolutionX: resolutionX,
                                                                              resolutionY: resolutionY,
                                                                              resolutionZ: resolutionZ,
                                                                              gridSpacing: gridSpacing)]))
        
        let resourceCache = engine.sceneManager.activeScene?.postprocessManager.resourceCache
        _fillPass = ComputePass(engine)
        _fillPass.resourceCache = resourceCache
        _fillPass.shader.append(ShaderPass(engine.library("flex.shader"), "fillHashGrid"))
        _fillPass.data.append(_shaderData)
        _fillPass.threadsPerGridX = totalCount
        
        _initArgsPass = ComputePass(engine)
        _initArgsPass.resourceCache = resourceCache
        _initArgsPass.defaultShaderData.setData("args", _indirectArgsBuffer)
        _initArgsPass.shader.append(ShaderPass(engine.library("flex.shader"), "initHashGridArgs"))
        _initArgsPass.data.append(_shaderData)

        _preparePass = ComputePass(engine)
        _preparePass.resourceCache = resourceCache
        _preparePass.shader.append(ShaderPass(engine.library("flex.shader"), "prepareSortHash"))
        _preparePass.data.append(_shaderData)

        _buildPass = ComputePass(engine)
        _buildPass.resourceCache = resourceCache
        _buildPass.shader.append(ShaderPass(engine.library("flex.shader"), "buildHashGrid"))
        _buildPass.data.append(_shaderData)

        _sortPass = BitonicSort(engine)
    }
    
    public func build(commandBuffer: MTLCommandBuffer, positions: BufferView,
                      itemCount: BufferView, maxNumberOfParticles: UInt32) {
        if _sortedIndices == nil || _sortedIndices.count != maxNumberOfParticles {
            _sortedIndices = BufferView(device: _engine.device, count: Int(maxNumberOfParticles),
                                        stride: MemoryLayout<SIMD2<Float>>.stride)
            _shaderData.setData("u_sortedIndices", _sortedIndices)
        }
        _shaderData.setData("u_positions", positions)
        _shaderData.setData("g_NumElements", itemCount)

        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _fillPass.compute(commandEncoder: commandEncoder, label: "fillPass")
            commandEncoder.endEncoding()
        }
        
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _initArgsPass.compute(commandEncoder: commandEncoder, label: "initArgs")
            commandEncoder.endEncoding()
        }
        
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _preparePass.compute(commandEncoder: commandEncoder, indirectBuffer: _indirectArgsBuffer.buffer,
                             threadsPerThreadgroup: MTLSize(width: 512, height: 1, depth: 1), label: "prepare sort")
            commandEncoder.endEncoding()
        }
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _sortPass.run(commandEncoder: commandEncoder, maxSize: UInt(maxNumberOfParticles), sortBuffer: _sortedIndices, itemCount: itemCount)
            commandEncoder.endEncoding()
        }
        // Now _points and _keys are sorted by points' hash key values.
        // Let's fill in start/end index table with _keys.

        // Assume that _keys array looks like:
        // [5|8|8|10|10|10]
        // Then _startIndexTable and _endIndexTable should be like:
        // [.....|0|...|1|..|3|..]
        // [.....|1|...|3|..|6|..]
        //       ^5    ^8   ^10
        // So that _endIndexTable[i] - _startIndexTable[i] is the number points
        // in i-th table bucket.
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _buildPass.compute(commandEncoder: commandEncoder, indirectBuffer: _indirectArgsBuffer.buffer,
                               threadsPerThreadgroup: MTLSize(width: 512, height: 1, depth: 1), label: "build hash grid")
            commandEncoder.endEncoding()
        }
    }
    
    // MARK: - Builder
    public class Builder {
        var _resolution = SIMD3<UInt32>(64, 64, 64)
        var _gridSpacing: Float = 1.0;
        
        //! Returns builder with resolution.
        public func withResolution(_ resolution: SIMD3<UInt32>) -> Builder {
            _resolution = resolution
            return self
        }

        //! Returns builder with grid spacing.
        public func withGridSpacing(_ gridSpacing: Float) -> Builder {
            _gridSpacing = gridSpacing
            return self
        }

        //! Builds PointParallelHashGridSearcher3 instance.
        public func build(_ engine: Engine) -> HashGrid {
            HashGrid(engine, _resolution.x, _resolution.y, _resolution.z, _gridSpacing)
        }
    }
}
