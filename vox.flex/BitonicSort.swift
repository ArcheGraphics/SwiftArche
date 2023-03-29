//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class BitonicSort {
    let SORT_SIZE = 512
    let MAX_NUM_THREAD_GROUP = 1024; //128; // max 128 * 512 elements = 64k elements
    let initSortArgsPass: ComputePass
    let preSortPass: ComputePass
    let innerSortPass: ComputePass
    let stepSortPass: ComputePass
    let indirectSortArgsBuffer: BufferView
    
    public init() {
        indirectSortArgsBuffer = BufferView(device: Engine.device, count: 1,
                                            stride: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride)
        let resourceCache = Engine.sceneManager.activeScene?.postprocessManager.resourceCache
        
        initSortArgsPass = ComputePass()
        initSortArgsPass.shader.append(ShaderPass(Engine.library("flex.shader"), "initSortArgs"))
        initSortArgsPass.threadsPerGridX = 1
        initSortArgsPass.threadsPerGridY = 1
        initSortArgsPass.threadsPerGridZ = 1
        initSortArgsPass.defaultShaderData.setData("args", indirectSortArgsBuffer)
        initSortArgsPass.precompileAll()
        
        preSortPass = ComputePass()
        preSortPass.shader.append(ShaderPass(Engine.library("flex.shader"), "preBitonicSort"))
        preSortPass.precompileAll()
        
        innerSortPass = ComputePass()
        innerSortPass.shader.append(ShaderPass(Engine.library("flex.shader"), "innerBitonicSort"))
        innerSortPass.precompileAll()
        
        stepSortPass = ComputePass()
        stepSortPass.shader.append(ShaderPass(Engine.library("flex.shader"), "stepBitonicSort"))
        stepSortPass.precompileAll()
    }
    
    public func run(commandEncoder: MTLComputeCommandEncoder, maxSize: UInt,
                    sortBuffer: BufferView, itemCount: BufferView) {
        initSortArgsPass.defaultShaderData.setData("g_NumElements", itemCount)
        initSortArgsPass.compute(commandEncoder: commandEncoder, label: "init sort args")
        
        preSortPass.defaultShaderData.setData("g_NumElements", itemCount)
        preSortPass.defaultShaderData.setData("Data", sortBuffer)
        var bDone = _sortInitial(commandEncoder, maxSize)
        
        innerSortPass.defaultShaderData.setData("g_NumElements", itemCount)
        innerSortPass.defaultShaderData.setData("Data", sortBuffer)
        stepSortPass.defaultShaderData.setData("g_NumElements", itemCount)
        stepSortPass.defaultShaderData.setData("Data", sortBuffer)
        var presorted: UInt = 512
        while (!bDone) {
            bDone = _sortIncremental(commandEncoder, presorted, maxSize)
            presorted *= 2
        }
    }
    
    private func _sortInitial(_ commandEncoder: MTLComputeCommandEncoder, _ maxSize: UInt) -> Bool {
        var bDone = true
        
        // calculate how many threads we'll require:
        //   we'll sort 512 elements per CU (threadgroupsize 256)
        //     maybe need to optimize this or make it changeable during init
        //     TGS=256 is a good intermediate value
        let numThreadGroups = ((maxSize - 1) >> 9) + 1
        if (numThreadGroups > 1) {
            bDone = false
        }
        
        let HALF_SIZE = SORT_SIZE / 2
        let ITERATIONS = HALF_SIZE > 1024 ? HALF_SIZE / 1024 : 1
        let NUM_THREADS = HALF_SIZE / ITERATIONS
        preSortPass.compute(commandEncoder: commandEncoder, indirectBuffer: indirectSortArgsBuffer.buffer,
                            threadsPerThreadgroup: MTLSize(width: NUM_THREADS, height: 1, depth: 1),
                            label: "pre sort")
        return bDone
    }
    
    private func _sortIncremental(_ commandEncoder: MTLComputeCommandEncoder,
                                  _ presorted: UInt, _ maxSize: UInt) -> Bool {
        var bDone = true
        
        // prepare thread group description data
        var numThreadGroups: UInt = 0;
        
        if (maxSize > presorted) {
            if (maxSize > presorted * 2) {
                bDone = false
            }
            var pow2 = presorted
            while (pow2 < maxSize) {
                pow2 *= 2
            }
            numThreadGroups = pow2 >> 9
        }
        
        let nMergeSize = presorted * 2
        var nMergeSubSize = nMergeSize >> 1
        while nMergeSubSize > 256 {
            var nMergeSubSizeHigh: UInt = 0
            var nMergeSubSizeLow: Int = 0
            if (nMergeSubSize == nMergeSize >> 1) {
                nMergeSubSizeHigh = 2 * nMergeSubSize - 1
                nMergeSubSizeLow = -1

            } else {
                nMergeSubSizeHigh = nMergeSubSize
                nMergeSubSizeLow = 1
            }
            commandEncoder.setBytes(&nMergeSubSize, length: MemoryLayout<UInt>.stride, index: 3)
            commandEncoder.setBytes(&nMergeSubSizeHigh, length: MemoryLayout<UInt>.stride, index: 4)
            commandEncoder.setBytes(&nMergeSubSizeLow, length: MemoryLayout<Int>.stride, index: 5)
            stepSortPass.compute(commandEncoder: commandEncoder, threadgroupsPerGrid: MTLSize(width: Int(numThreadGroups), height: 1, depth: 1),
                                 threadsPerThreadgroup: MTLSize(width: 256, height: 1, depth: 1), label: "step sort")
            
            nMergeSubSize = nMergeSubSize >> 1
        }
        let NUM_THREADS = SORT_SIZE / 2
        innerSortPass.compute(commandEncoder: commandEncoder, threadgroupsPerGrid: MTLSize(width: Int(numThreadGroups), height: 1, depth: 1),
                              threadsPerThreadgroup: MTLSize(width: NUM_THREADS, height: 1, depth: 1), label: "inner sort")
        
        return bDone
    }
}
