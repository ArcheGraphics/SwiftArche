//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct XICBData {
    // Default indirect command buffers.
    var commandBuffer: MTLIndirectCommandBuffer!
    var commandBuffer_alphaMask: MTLIndirectCommandBuffer!
    var commandBuffer_transparent: MTLIndirectCommandBuffer!
    // Indirect command buffers for depth only rendering which has fewer buffers.
    var commandBuffer_depthOnly: MTLIndirectCommandBuffer!
    var commandBuffer_depthOnly_alphaMask: MTLIndirectCommandBuffer!
    // Buffer to store the execution range for the ICB.
    var executionRangeBuffer: MTLBuffer!
    // Buffer containing a AAPLEncodeArguments argument buffer.
    var icbEncodeArgsBuffer: MTLBuffer!
    var icbEncodeArgsBuffer_alphaMask: MTLBuffer!
    var icbEncodeArgsBuffer_transparent: MTLBuffer!
    // Output buffer for chunk visualization.
    var chunkVizBuffer: MTLBuffer!
}

class XCulling {
    // Device from initialization.
    private var _device: MTLDevice

    // Compute pipelines for updating MTLIndirectCommandBufferExecutionRange objects.
    private var _resetChunkExecutionRangeState: MTLComputePipelineState!

    // Compute pipelines for culling indexed by AAPLRenderCullType.
    private var _encodeChunksState: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))
    private var _encodeChunksState_AlphaMask: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))
    private var _encodeChunksState_Transparent: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))

    private var _encodeChunksState_DepthOnly: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))
    private var _encodeChunksState_DepthOnly_AlphaMask: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))

    private var _encodeChunksState_DepthOnly_Filtered: MTLComputePipelineState!
    private var _encodeChunksState_DepthOnly_AlphaMask_Filtered: MTLComputePipelineState!

    private var _encodeChunksState_Both: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))
    private var _encodeChunksState_Both_AlphaMask: [MTLComputePipelineState?] = .init(repeating: nil, count: Int(XRenderCullType.Count.rawValue))

    private var _visualizeCullingState: MTLComputePipelineState!
    private var _visualizeCullingState_AlphaMask: MTLComputePipelineState!
    private var _visualizeCullingState_Transparent: MTLComputePipelineState!

    // Argument encoder for configuring AAPLEncodeArguments objects.
    private var _icbEncodeArgsEncoder: MTLArgumentEncoder!

    // Initializes this culling object, allocating compute pipelines and argument encoders.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         genCSMUsingVertexAmplification: Bool)
    {
        _device = device
        rebuildPipelines(with: library, useRasterizationRate: useRasterizationRate, genCSMUsingVertexAmplification: genCSMUsingVertexAmplification)
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool,
                          genCSMUsingVertexAmplification: Bool)
    {
        _resetChunkExecutionRangeState = newComputePipelineState(library: library, functionName: "resetChunkExecutionRange",
                                                                 label: "ChunkExecRangeReset", functionConstants: nil)

        var TRUE_VALUE = true
        var FALSE_VALUE = false

        let fc = MTLFunctionConstantValues()

        #if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
            fc.setConstantValue(&genCSMUsingVertexAmplification, type: .bool, index: XFunctionConstIndexFilteredCulling.rawValue)
        #endif

        // ----------------------------------

        // MARK: - CULLING STATES

        // ----------------------------------

        let encodeChunksFunction = library.makeFunction(name: "encodeChunks")!
        _icbEncodeArgsEncoder = encodeChunksFunction.makeArgumentEncoder(bufferIndex: Int(XBufferIndexComputeEncodeArguments.rawValue))
        var useRasterizationRate = useRasterizationRate
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        _encodeChunksState[Int(XRenderCullType.None.rawValue)] = newComputePipelineState(
            library: library, functionName: "encodeChunks",
            label: "EncodeAllChunks",
            functionConstants: fc
        )
        _encodeChunksState[Int(XRenderCullType.Frustum.rawValue)] = newComputePipelineState(
            library: library, functionName: "encodeChunksWithCulling",
            label: "CullAndEncodeChunksFrustum",
            functionConstants: fc
        )
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState[Int(XRenderCullType.FrustumDepth.rawValue)] = newComputePipelineState(
            library: library, functionName: "encodeChunksWithCulling",
            label: "CullAndEncodeChunksOccAndFrustum",
            functionConstants: fc
        )

        // MARK: - Depth Only

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        _encodeChunksState_DepthOnly[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                     label: "EncodeAllChunks_DepthOnly",
                                                                                     functionConstants: fc)
        _encodeChunksState_DepthOnly[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                        label: "CullAndEncodeChunksFrustum_DepthOnly",
                                                                                        functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_DepthOnly[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                             label: "CullAndEncodeChunksOccAndFrustum_DepthOnly",
                                                                                             functionConstants: fc)

        if genCSMUsingVertexAmplification {
            _encodeChunksState_DepthOnly_Filtered = newComputePipelineState(library: library, functionName: "encodeChunksWithCullingFiltered",
                                                                            label: "CullAndEncodeChunksOccAndFrustum_Filtered",
                                                                            functionConstants: fc)
        }

        // MARK: - Both

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        _encodeChunksState_Both[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                label: "EncodeAllChunks_Both",
                                                                                functionConstants: fc)
        _encodeChunksState_Both[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                   label: "CullAndEncodeChunksFrustum_Both",
                                                                                   functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_Both[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                        label: "CullAndEncodeChunksOccAndFrustum_Both",
                                                                                        functionConstants: fc)

        // MARK: - Alpha Masked

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        _encodeChunksState_AlphaMask[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                     label: "EncodeAllChunks_AlphaMask",
                                                                                     functionConstants: fc)
        _encodeChunksState_AlphaMask[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                        label: "CullAndEncodeChunksFrustum_AlphaMask",
                                                                                        functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_AlphaMask[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                             label: "CullAndEncodeChunksOccAndFrustum_AlphaMask",
                                                                                             functionConstants: fc)

        // MARK: - Alpha Masked Depth Only

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))

        _encodeChunksState_DepthOnly_AlphaMask[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                               label: "EncodeAllChunks_DepthOnly_AlphaMask",
                                                                                               functionConstants: fc)

        _encodeChunksState_DepthOnly_AlphaMask[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                                  label: "CullAndEncodeChunksFrustum_DepthOnly_AlphaMask",
                                                                                                  functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_DepthOnly_AlphaMask[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                                       label: "CullAndEncodeChunksOccAndFrustum_DepthOnly_AlphaMask",
                                                                                                       functionConstants: fc)

        #if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
            if genCSMUsingVertexAmplification {
                _encodeChunksState_DepthOnly_AlphaMask_Filtered = newComputePipelineState(library, "encodeChunksWithCullingFiltered",
                                                                                          "CullAndEncodeChunksOccAndFrustum_FilteredAlphaDepth",
                                                                                          fc)
            }
        #endif

        // MARK: - Alpha Masked Both

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        _encodeChunksState_Both_AlphaMask[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                          label: "EncodeAllChunks_Both_AlphaMask",
                                                                                          functionConstants: fc)

        _encodeChunksState_Both_AlphaMask[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                             label: "CullAndEncodeChunksFrustum_Both_AlphaMask",
                                                                                             functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_Both_AlphaMask[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                                  label: "CullAndEncodeChunksOccAndFrustum_Both_AlphaMask",
                                                                                                  functionConstants: fc)

        // MARK: - Transparent

        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))

        _encodeChunksState_Transparent[XRenderCullType.None] = newComputePipelineState(library: library, functionName: "encodeChunks",
                                                                                       label: "EncodeAllChunks_Transparent",
                                                                                       functionConstants: fc)

        _encodeChunksState_Transparent[XRenderCullType.Frustum] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                          label: "CullAndEncodeChunksFrustum_Transparent",
                                                                                          functionConstants: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _encodeChunksState_Transparent[XRenderCullType.FrustumDepth] = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                                               label: "CullAndEncodeChunksOccAndFrustum_Transparent",
                                                                                               functionConstants: fc)

        // MARK: - Visualization

        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexPackCommands.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexVisualizeCulling.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToDepthOnly.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeToMain.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexUseOcclusionCulling.rawValue))
        _visualizeCullingState = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                         label: "CullingStateVisualization",
                                                         functionConstants: fc)
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexEncodeAlphaMask.rawValue))
        _visualizeCullingState_AlphaMask = newComputePipelineState(library: library, functionName: "encodeChunksWithCulling",
                                                                   label: "CullingStateVisualization_AlphaMask",
                                                                   functionConstants: fc)
        _visualizeCullingState_Transparent = _visualizeCullingState_AlphaMask
    }

    // Initializes `AAPLICBData` argument buffers for rendering the results of
    //  culling for a specific mesh.
    func initCommandData(_ commandData: inout XICBData,
                         for mesh: XMesh,
                         chunkViz: Bool,
                         frameData: MTLBuffer,
                         globalTexturesBuffer: MTLBuffer,
                         lightParamsBuffer: MTLBuffer)
    {
        let icbDescriptor = MTLIndirectCommandBufferDescriptor()
        icbDescriptor.commandTypes = .drawIndexed
        icbDescriptor.inheritPipelineState = true
        icbDescriptor.inheritBuffers = false
        icbDescriptor.maxVertexBufferBindCount = Int(XBufferIndexVertexICBBufferCount.rawValue)
        icbDescriptor.maxFragmentBufferBindCount = Int(XBufferIndexFragmentICBBufferCount.rawValue)

        commandData.commandBuffer = _device.makeIndirectCommandBuffer(descriptor: icbDescriptor,
                                                                      maxCommandCount: Int(mesh.opaqueChunkCount),
                                                                      options: MTLResourceOptions())
        commandData.commandBuffer.label = "Opaque ICB"
        commandData.commandBuffer_alphaMask = _device.makeIndirectCommandBuffer(descriptor: icbDescriptor,
                                                                                maxCommandCount: Int(mesh.alphaMaskedChunkCount),
                                                                                options: MTLResourceOptions())
        commandData.commandBuffer_alphaMask.label = "AlphaMask ICB"
        commandData.commandBuffer_transparent = _device.makeIndirectCommandBuffer(descriptor: icbDescriptor,
                                                                                  maxCommandCount: Int(mesh.transparentChunkCount),
                                                                                  options: MTLResourceOptions())
        commandData.commandBuffer_transparent.label = "Transparent ICB"

        icbDescriptor.maxVertexBufferBindCount = Int(XBufferIndexVertexDepthOnlyICBBufferCount.rawValue)
        icbDescriptor.maxFragmentBufferBindCount = 0
        commandData.commandBuffer_depthOnly = _device.makeIndirectCommandBuffer(descriptor: icbDescriptor,
                                                                                maxCommandCount: Int(mesh.opaqueChunkCount),
                                                                                options: MTLResourceOptions())
        commandData.commandBuffer_depthOnly.label = "Opaque DepthOnly ICB"

        icbDescriptor.maxVertexBufferBindCount = Int(XBufferIndexVertexDepthOnlyICBAlphaMaskBufferCount.rawValue)
        icbDescriptor.maxFragmentBufferBindCount = Int(XBufferIndexFragmentDepthOnlyICBAlphaMaskBufferCount.rawValue)
        commandData.commandBuffer_depthOnly_alphaMask = _device.makeIndirectCommandBuffer(descriptor: icbDescriptor,
                                                                                          maxCommandCount: Int(mesh.alphaMaskedChunkCount),
                                                                                          options: MTLResourceOptions())
        commandData.commandBuffer_depthOnly_alphaMask.label = "AlphaMask DepthOnly ICB"

        if chunkViz {
            commandData.chunkVizBuffer = _device.makeBuffer(
                length: MemoryLayout<XChunkVizData>.stride * Int(mesh.chunkCount),
                options: .storageModePrivate
            )
            commandData.chunkVizBuffer.label = "ChunkViz"
        }

        let numExecutionRanges = 3

        // Read back in callback
        commandData.executionRangeBuffer = _device.makeBuffer(length: MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride * numExecutionRanges,
                                                              options: .storageModeShared)
        commandData.executionRangeBuffer.label = "Execution Range Buffer"
        commandData.icbEncodeArgsBuffer = _device.makeBuffer(length: _icbEncodeArgsEncoder.encodedLength)
        commandData.icbEncodeArgsBuffer.label = "ICB Encode Args Buffer"
        commandData.icbEncodeArgsBuffer_alphaMask = _device.makeBuffer(length: _icbEncodeArgsEncoder.encodedLength)
        commandData.icbEncodeArgsBuffer_alphaMask.label = "ICB Encode Args Buffer Alpha Mask"
        commandData.icbEncodeArgsBuffer_transparent = _device.makeBuffer(length: _icbEncodeArgsEncoder.encodedLength)
        commandData.icbEncodeArgsBuffer_transparent.label = "ICB Encode Args Buffer Transparent"

        let icbEncodeArgsBuffers: [MTLBuffer] = [commandData.icbEncodeArgsBuffer, commandData.icbEncodeArgsBuffer_alphaMask, commandData.icbEncodeArgsBuffer_transparent]

        let commandBuffers: [MTLIndirectCommandBuffer] = [commandData.commandBuffer, commandData.commandBuffer_alphaMask, commandData.commandBuffer_transparent]
        let commandBuffersDepthOnly: [MTLIndirectCommandBuffer?] = [commandData.commandBuffer_depthOnly, commandData.commandBuffer_depthOnly_alphaMask, nil]

        for i in 0 ..< numExecutionRanges {
            let depthOnly = commandBuffersDepthOnly[i] != nil ? commandBuffersDepthOnly[i]! : commandBuffers[i]
            _icbEncodeArgsEncoder.setArgumentBuffer(icbEncodeArgsBuffers[i], offset: 0)
            _icbEncodeArgsEncoder.setIndirectCommandBuffer(commandBuffers[i], index: Int(XEncodeArgsIndexCommandBuffer.rawValue))
            _icbEncodeArgsEncoder.setIndirectCommandBuffer(depthOnly, index: Int(XEncodeArgsIndexCommandBufferDepthOnly.rawValue))
            _icbEncodeArgsEncoder.setBuffer(mesh.indices, offset: 0, index: Int(XEncodeArgsIndexIndexBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(mesh.vertices, offset: 0, index: Int(XEncodeArgsIndexVertexBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(mesh.normals, offset: 0, index: Int(XEncodeArgsIndexVertexNormalBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(mesh.tangents, offset: 0, index: Int(XEncodeArgsIndexVertexTangentBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(mesh.uvs, offset: 0, index: Int(XEncodeArgsIndexUVBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(frameData, offset: 0, index: Int(XEncodeArgsIndexFrameDataBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(globalTexturesBuffer, offset: 0, index: Int(XEncodeArgsIndexGlobalTexturesBuffer.rawValue))
            _icbEncodeArgsEncoder.setBuffer(lightParamsBuffer, offset: 0, index: Int(XEncodeArgsIndexLightParamsBuffer.rawValue))
        }
    }

    // Executes the culling for `AAPLRenderModeIndirect` render mode on GPU with depth texture
    //  and depth pyramid.
    func executeCulling(commandData: XICBData,
                        frameViewData: XFrameViewData,
                        frameDataBuffer: MTLBuffer,
                        cullMode: XRenderCullType,
                        pyramidTexture: MTLTexture,
                        mainPass: Bool,
                        depthOnly: Bool,
                        mesh: XMesh,
                        materialBuffer: MTLBuffer,
                        rrData _: MTLBuffer,
                        encoder: MTLComputeCommandEncoder)
    {
        encoder.pushDebugGroup("Encode chunks")

        if mainPass {
            encoder.useResource(commandData.commandBuffer, usage: .readWrite)
            encoder.useResource(commandData.commandBuffer_alphaMask, usage: .readWrite)
            encoder.useResource(commandData.commandBuffer_transparent, usage: .readWrite)
        }

        if depthOnly {
            encoder.useResource(commandData.commandBuffer_depthOnly, usage: .readWrite)
            encoder.useResource(commandData.commandBuffer_depthOnly_alphaMask, usage: .readWrite)
        }

        let opaqueCullPipeline: MTLComputePipelineState,
            alphaMaskCullPipeline: MTLComputePipelineState,
            transparentCullPipeline: MTLComputePipelineState?
        if cullMode == .Visualization {
            opaqueCullPipeline = _visualizeCullingState
            alphaMaskCullPipeline = _visualizeCullingState_AlphaMask
            transparentCullPipeline = _visualizeCullingState_Transparent
        } else if mainPass, depthOnly {
            opaqueCullPipeline = _encodeChunksState_Both[cullMode]!
            alphaMaskCullPipeline = _encodeChunksState_Both_AlphaMask[cullMode]!
            transparentCullPipeline = _encodeChunksState_Transparent[cullMode]!
        } else if depthOnly {
            opaqueCullPipeline = _encodeChunksState_DepthOnly[cullMode]!
            alphaMaskCullPipeline = _encodeChunksState_DepthOnly_AlphaMask[cullMode]!
            transparentCullPipeline = nil
        } else {
            opaqueCullPipeline = _encodeChunksState[cullMode]!
            alphaMaskCullPipeline = _encodeChunksState_AlphaMask[cullMode]!
            transparentCullPipeline = _encodeChunksState_Transparent[cullMode]!
        }

        encoder.setBuffer(frameViewData.cullParamBuffer, offset: 0, index: Int(XBufferIndexComputeCullCameraParams.rawValue))
        encoder.setBuffer(frameViewData.cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))
        encoder.setBuffer(materialBuffer, offset: 0, index: Int(XBufferIndexComputeMaterial.rawValue))
        encoder.setBuffer(commandData.chunkVizBuffer, offset: 0, index: Int(XBufferIndexComputeChunkViz.rawValue))
        encoder.setBuffer(mesh.chunks, offset: 0, index: Int(XBufferIndexComputeChunks.rawValue))

        encoder.setBuffer(commandData.executionRangeBuffer, offset: 0, index: Int(XBufferIndexComputeExecutionRange.rawValue))
        encoder.setBuffer(frameDataBuffer, offset: 0, index: Int(XBufferIndexComputeFrameData.rawValue))
        #if SUPPORT_RASTERIZATION_RATE
            encoder.setBuffer(rrMapData, offset: 0, index: XBufferIndexRasterizationRateMap.rawValue)
        #endif
        encoder.setTexture(pyramidTexture, index: 0)

        let packCommands = !(cullMode == .None || cullMode == .Visualization)

        // Cull opaque draws
        encodeCulling(encoder: encoder, cullPipeline: opaqueCullPipeline,
                      icbEncodeArgsBuffer: commandData.icbEncodeArgsBuffer,
                      chunkCount: UInt32(mesh.opaqueChunkCount),
                      chunkOffset: 0, packCommands: packCommands)

        // Cull alpha mask draws
        encoder.setBufferOffset(MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride,
                                index: Int(XBufferIndexComputeExecutionRange.rawValue))

        if commandData.chunkVizBuffer != nil {
            encoder.setBufferOffset(MemoryLayout<XChunkVizData>.stride * Int(mesh.opaqueChunkCount),
                                    index: Int(XBufferIndexComputeChunkViz.rawValue))
        }

        encodeCulling(encoder: encoder, cullPipeline: alphaMaskCullPipeline,
                      icbEncodeArgsBuffer: commandData.icbEncodeArgsBuffer_alphaMask,
                      chunkCount: UInt32(mesh.alphaMaskedChunkCount),
                      chunkOffset: UInt32(mesh.opaqueChunkCount), packCommands: packCommands)

        // Cull transparent draws
        if let transparentCullPipeline {
            encoder.setBufferOffset(MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride * 2,
                                    index: Int(XBufferIndexComputeExecutionRange.rawValue))

            if commandData.chunkVizBuffer != nil {
                encoder.setBufferOffset(MemoryLayout<XChunkVizData>.stride * Int(mesh.opaqueChunkCount + mesh.alphaMaskedChunkCount),
                                        index: Int(XBufferIndexComputeChunkViz.rawValue))
            }

            encodeCulling(encoder: encoder, cullPipeline: transparentCullPipeline,
                          icbEncodeArgsBuffer: commandData.icbEncodeArgsBuffer_transparent,
                          chunkCount: UInt32(mesh.transparentChunkCount),
                          chunkOffset: UInt32(mesh.opaqueChunkCount + mesh.alphaMaskedChunkCount),
                          packCommands: mainPass ? false : packCommands)
        }

        encoder.popDebugGroup()
    }

    func executeCullingFiltered(commandData: XICBData,
                                frameViewData1: XFrameViewData,
                                frameViewData2: XFrameViewData,
                                frameDataBuffer _: MTLBuffer,
                                cullMode: XRenderCullType,
                                pyramidTexture1: MTLTexture,
                                pyramidTexture2: MTLTexture,
                                mesh: XMesh,
                                materialBuffer: MTLBuffer,
                                encoder: MTLComputeCommandEncoder)
    {
        if let opaqueCullPipeline = _encodeChunksState_DepthOnly_Filtered,
           let alphaMaskCullPipeline = _encodeChunksState_DepthOnly_AlphaMask_Filtered
        {
            encoder.pushDebugGroup("Encode chunks filtered")
            encoder.useResource(commandData.commandBuffer_depthOnly, usage: .readWrite)
            encoder.useResource(commandData.commandBuffer_depthOnly_alphaMask, usage: .readWrite)

            encoder.setBuffer(frameViewData1.cullParamBuffer, offset: 0, index: Int(XBufferIndexComputeCullCameraParams.rawValue))
            encoder.setBuffer(frameViewData2.cullParamBuffer, offset: 0, index: Int(XBufferIndexComputeCullCameraParams2.rawValue))
            encoder.setBuffer(frameViewData2.cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))
            encoder.setBuffer(materialBuffer, offset: 0, index: Int(XBufferIndexComputeMaterial.rawValue))

            encoder.setBuffer(commandData.chunkVizBuffer, offset: 0, index: Int(XBufferIndexComputeChunkViz.rawValue))
            encoder.setBuffer(mesh.chunks, offset: 0, index: Int(XBufferIndexComputeChunks.rawValue))

            encoder.setBuffer(commandData.executionRangeBuffer, offset: 0, index: Int(XBufferIndexComputeExecutionRange.rawValue))
            encoder.setTexture(pyramidTexture1, index: 0)
            encoder.setTexture(pyramidTexture2, index: 1)

            let packCommands = !(cullMode == .None || cullMode == .Visualization)

            // Cull opaque draws
            encodeCulling(encoder: encoder, cullPipeline: opaqueCullPipeline,
                          icbEncodeArgsBuffer: commandData.icbEncodeArgsBuffer,
                          chunkCount: UInt32(mesh.opaqueChunkCount),
                          chunkOffset: 0, packCommands: packCommands)

            // Cull alpha mask draws
            encoder.setBufferOffset(MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride,
                                    index: Int(XBufferIndexComputeExecutionRange.rawValue))

            if commandData.chunkVizBuffer != nil {
                encoder.setBufferOffset(MemoryLayout<XChunkVizData>.stride * Int(mesh.opaqueChunkCount),
                                        index: Int(XBufferIndexComputeChunkViz.rawValue))
            }

            encodeCulling(encoder: encoder, cullPipeline: alphaMaskCullPipeline,
                          icbEncodeArgsBuffer: commandData.icbEncodeArgsBuffer_alphaMask,
                          chunkCount: UInt32(mesh.alphaMaskedChunkCount),
                          chunkOffset: UInt32(mesh.opaqueChunkCount), packCommands: packCommands)

            encoder.popDebugGroup()
        }
    }

    // Clears the indirect command buffer generated by the culling phase.
    func resetIndirectCommandBuffersForViews(commandData: [XICBData],
                                             viewCount: Int,
                                             mainPass: Bool,
                                             depthOnly: Bool,
                                             mesh: XMesh,
                                             commandBuffer: MTLCommandBuffer)
    {
        if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
            blitEncoder.label = "ICB Reset"
            for viewIndex in 0 ..< viewCount {
                if mainPass {
                    blitEncoder.resetCommandsInBuffer(commandData[viewIndex].commandBuffer,
                                                      range: 0 ..< Int(mesh.opaqueChunkCount))
                    blitEncoder.resetCommandsInBuffer(commandData[viewIndex].commandBuffer_alphaMask,
                                                      range: 0 ..< Int(mesh.alphaMaskedChunkCount))
                    blitEncoder.resetCommandsInBuffer(commandData[viewIndex].commandBuffer_transparent,
                                                      range: 0 ..< Int(mesh.transparentChunkCount))
                }

                if depthOnly {
                    blitEncoder.resetCommandsInBuffer(commandData[viewIndex].commandBuffer_depthOnly,
                                                      range: 0 ..< Int(mesh.opaqueChunkCount))
                    blitEncoder.resetCommandsInBuffer(commandData[viewIndex].commandBuffer_depthOnly_alphaMask,
                                                      range: 0 ..< Int(mesh.alphaMaskedChunkCount))
                }
            }
            blitEncoder.endEncoding()
        }
    }

    // Optimizes the contents of the indirect command buffer generated by the culling phase.
    func optimizeIndirectCommandBuffersForViews(commandData: [XICBData],
                                                viewCount: Int,
                                                mainPass: Bool,
                                                depthOnly: Bool,
                                                mesh: XMesh,
                                                commandBuffer: MTLCommandBuffer)
    {
        if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
            blitEncoder.label = "ICB Optimize"
            for viewIndex in 0 ..< viewCount {
                if mainPass {
                    blitEncoder.optimizeIndirectCommandBuffer(commandData[viewIndex].commandBuffer,
                                                              range: 0 ..< Int(mesh.opaqueChunkCount))
                    blitEncoder.optimizeIndirectCommandBuffer(commandData[viewIndex].commandBuffer_alphaMask,
                                                              range: 0 ..< Int(mesh.alphaMaskedChunkCount))
                    blitEncoder.optimizeIndirectCommandBuffer(commandData[viewIndex].commandBuffer_transparent,
                                                              range: 0 ..< Int(mesh.transparentChunkCount))
                }

                if depthOnly {
                    blitEncoder.optimizeIndirectCommandBuffer(commandData[viewIndex].commandBuffer_depthOnly,
                                                              range: 0 ..< Int(mesh.opaqueChunkCount))
                    blitEncoder.optimizeIndirectCommandBuffer(commandData[viewIndex].commandBuffer_depthOnly_alphaMask,
                                                              range: 0 ..< Int(mesh.alphaMaskedChunkCount))
                }
            }
            blitEncoder.endEncoding()
        }
    }

    // Internal helper method to encode the commands required for culling chunks of
    //  a mesh and generating an ICB.
    private func encodeCulling(encoder: MTLComputeCommandEncoder,
                               cullPipeline: MTLComputePipelineState,
                               icbEncodeArgsBuffer: MTLBuffer,
                               chunkCount: UInt32,
                               chunkOffset: UInt32,
                               packCommands: Bool)
    {
        var cullParams = XCullParams()
        cullParams.numChunks = chunkCount
        cullParams.offset = chunkOffset

        encoder.setBuffer(icbEncodeArgsBuffer, offset: 0, index: Int(XBufferIndexComputeEncodeArguments.rawValue))

        // Reset.
        var lengthResetValue = packCommands ? 0 : cullParams.numChunks
        encoder.setComputePipelineState(_resetChunkExecutionRangeState)
        encoder.setBytes(&lengthResetValue, length: MemoryLayout<UInt32>.stride,
                         index: Int(XBufferIndexComputeExecutionRange.rawValue) + 1)
        encoder.dispatchThreadgroups(MTLSizeMake(1, 1, 1), threadsPerThreadgroup: MTLSizeMake(1, 1, 1))

        // Fill.
        encoder.setComputePipelineState(cullPipeline)
        encoder.setBytes(&cullParams, length: MemoryLayout<XCullParams>.stride,
                         index: Int(XBufferIndexCullParams.rawValue))
        encoder.setBufferOffset(MemoryLayout<XMeshChunk>.stride * Int(cullParams.offset),
                                index: Int(XBufferIndexComputeChunks.rawValue))

        let threadgroupSize = MTLSizeMake(Int(CULLING_THREADGROUP_SIZE), 1, 1)
        let threadgroupCount = MTLSizeMake(divideRoundUp(numerator: Int(cullParams.numChunks),
                                                         denominator: threadgroupSize.width), 1, 1)
        encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
    }
}
