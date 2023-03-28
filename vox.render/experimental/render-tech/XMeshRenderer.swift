//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import simd

/// Encapsulates the pipeline states and intermediate objects for rendering meshes.
class XMeshRenderer {
    // Device from initialization.
    private var _device: MTLDevice

    private var _textureManager: XTextureManager

    // - GBuffer
    private var _gBufferOpaque: MTLRenderPipelineState!
    private var _gBufferAlphaMask: MTLRenderPipelineState!
    private var _gBufferDebug: MTLRenderPipelineState!

    //  - Depth Only
    private var _depthOnlyOpaque: MTLRenderPipelineState!
    private var _depthOnlyAlphaMask: MTLRenderPipelineState!

    private var _depthOnlyAmplifiedOpaque: MTLRenderPipelineState?
    private var _depthOnlyAmplifiedAlphaMask: MTLRenderPipelineState?

    private var _depthOnlyTileOpaque: MTLRenderPipelineState?
    private var _depthOnlyTileAlphaMask: MTLRenderPipelineState?

    //  - Forward
    private var _forwardOpaque: MTLRenderPipelineState!
    private var _forwardAlphaMask: MTLRenderPipelineState!
    private var _forwardTransparent: MTLRenderPipelineState!
    private var _forwardTransparentLightCluster: MTLRenderPipelineState!

    private var _forwardOpaqueDebug: MTLRenderPipelineState!
    private var _forwardAlphaMaskDebug: MTLRenderPipelineState!
    private var _forwardTransparentDebug: MTLRenderPipelineState!
    private var _forwardTransparentLightClusterDebug: MTLRenderPipelineState!

    private var _materialSize: Int
    private var _alignedMaterialSize: Int

    private var _lightCullingTileSize: Int
    private var _lightClusteringTileSize: Int

    /// Initializes this object, allocating metal objects from the device based on functions in the library.
    init(with device: MTLDevice,
         textureManager: XTextureManager,
         materialSize: Int,
         alignedMaterialSize: Int,
         library: MTLLibrary,
         GBufferPixelFormats: [MTLPixelFormat],
         lightingPixelFormat: MTLPixelFormat,
         depthStencilFormat: MTLPixelFormat,
         sampleCount: Int,
         useRasterizationRate: Bool,
         singlePassDeferredLighting: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int,
         useSinglePassCSMGeneration: Bool,
         genCSMUsingVertexAmplification: Bool) {
        _device = device
        _textureManager = textureManager

        _materialSize = materialSize
        _alignedMaterialSize = alignedMaterialSize

        _lightCullingTileSize = lightCullingTileSize
        _lightClusteringTileSize = lightClusteringTileSize
        rebuildPipelines(with: library, GBufferPixelFormats: GBufferPixelFormats,
                lightingPixelFormat: lightingPixelFormat,
                depthStencilFormat: depthStencilFormat,
                sampleCount: sampleCount,
                useRasterizationRate: useRasterizationRate,
                singlePassDeferredLighting: singlePassDeferredLighting,
                useSinglePassCSMGeneration: useSinglePassCSMGeneration,
                genCSMUsingVertexAmplification: genCSMUsingVertexAmplification)
    }

    func rebuildPipelines(with library: MTLLibrary,
                          GBufferPixelFormats: [MTLPixelFormat],
                          lightingPixelFormat: MTLPixelFormat,
                          depthStencilFormat: MTLPixelFormat,
                          sampleCount: Int,
                          useRasterizationRate: Bool,
                          singlePassDeferredLighting: Bool,
                          useSinglePassCSMGeneration: Bool,
                          genCSMUsingVertexAmplification: Bool) {
        var TRUE_VALUE = true
        var FALSE_VALUE = false

        //Both Apple Silicon and iPhone will respond with true
        let nilFragmentFunction = _device.supportsFamily(.apple4) ? library.makeFunction(name: "dummyFragmentShader") : nil

        // ----------------------------------
        //MARK: - Create vertex descriptors
        // ----------------------------------

        let vd = MTLVertexDescriptor()

        vd.attributes[Int(XVertexAttributePosition.rawValue)].format = .float3
        vd.attributes[Int(XVertexAttributePosition.rawValue)].offset = 0
        vd.attributes[Int(XVertexAttributePosition.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshPositions.rawValue)

        vd.attributes[Int(XVertexAttributeNormal.rawValue)].format = .float3
        vd.attributes[Int(XVertexAttributeNormal.rawValue)].offset = 0
        vd.attributes[Int(XVertexAttributeNormal.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshNormals.rawValue)

        vd.attributes[Int(XVertexAttributeTangent.rawValue)].format = .float3
        vd.attributes[Int(XVertexAttributeTangent.rawValue)].offset = 0
        vd.attributes[Int(XVertexAttributeTangent.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshTangents.rawValue)

        vd.attributes[Int(XVertexAttributeTexcoord.rawValue)].format = .float2
        vd.attributes[Int(XVertexAttributeTexcoord.rawValue)].offset = 0
        vd.attributes[Int(XVertexAttributeTexcoord.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshGenerics.rawValue)

        vd.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stride = 12
        vd.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stepRate = 1
        vd.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stepFunction = .perVertex

        vd.layouts[Int(XBufferIndexVertexMeshNormals.rawValue)].stride = 12
        vd.layouts[Int(XBufferIndexVertexMeshNormals.rawValue)].stepRate = 1
        vd.layouts[Int(XBufferIndexVertexMeshNormals.rawValue)].stepFunction = .perVertex

        vd.layouts[Int(XBufferIndexVertexMeshTangents.rawValue)].stride = 12
        vd.layouts[Int(XBufferIndexVertexMeshTangents.rawValue)].stepRate = 1
        vd.layouts[Int(XBufferIndexVertexMeshTangents.rawValue)].stepFunction = .perVertex

        vd.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stride = 8
        vd.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stepRate = 1
        vd.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stepFunction = .perVertex

        //MARK: - Depth Only Vertex Descriptor

        let depthOnlyVD = MTLVertexDescriptor()

        depthOnlyVD.attributes[Int(XVertexAttributePosition.rawValue)].format = .float3
        depthOnlyVD.attributes[Int(XVertexAttributePosition.rawValue)].offset = 0
        depthOnlyVD.attributes[Int(XVertexAttributePosition.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshPositions.rawValue)

        depthOnlyVD.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stride = 12
        depthOnlyVD.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stepRate = 1
        depthOnlyVD.layouts[Int(XBufferIndexVertexMeshPositions.rawValue)].stepFunction = .perVertex

        //MARK: - Depth Only Alpha Mask Vertex Descriptor

        let depthOnlyAlphaMaskVD = depthOnlyVD.copy() as! MTLVertexDescriptor

        depthOnlyAlphaMaskVD.attributes[Int(XVertexAttributeTexcoord.rawValue)].format = .float2
        depthOnlyAlphaMaskVD.attributes[Int(XVertexAttributeTexcoord.rawValue)].offset = 0
        depthOnlyAlphaMaskVD.attributes[Int(XVertexAttributeTexcoord.rawValue)].bufferIndex = Int(XBufferIndexVertexMeshGenerics.rawValue)

        depthOnlyAlphaMaskVD.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stride = 8
        depthOnlyAlphaMaskVD.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stepRate = 1
        depthOnlyAlphaMaskVD.layouts[Int(XBufferIndexVertexMeshGenerics.rawValue)].stepFunction = .perVertex

        // ----------------------------------

        let vertexFunction = library.makeFunction(name: "vertexShader")

        // ----------------------------------
        //MARK: - Forward pipeline states
        // ----------------------------------
        var useRasterizationRate = useRasterizationRate
        var fc = MTLFunctionConstantValues()
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexDebugView.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexTransparent.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))
        fc.setConstantValue(&_lightCullingTileSize, type: .uint, index: Int(XFunctionConstIndexLightCullingTileSize.rawValue))
        fc.setConstantValue(&_lightClusteringTileSize, type: .uint, index: Int(XFunctionConstIndexLightClusteringTileSize.rawValue))
        let fragmentFunctionOpaqueICB = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        let fragmentFunctionAlphaMaskICB = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexTransparent.rawValue))
        let fragmentFunctionTransparentICB = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))
        let fragmentFunctionLCTransparentICB = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexTransparent.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexDebugView.rawValue))
        let fragmentFunctionOpaqueICBDebug = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        let fragmentFunctionAlphaMaskICBDebug = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexTransparent.rawValue))
        let fragmentFunctionTransparentICBDebug = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))
        let fragmentFunctionLCTransparentICBDebug = try? library.makeFunction(name: "fragmentForwardShader", constantValues: fc)

        let psd = MTLRenderPipelineDescriptor()
        psd.sampleCount = sampleCount
        psd.vertexFunction = vertexFunction
        psd.vertexDescriptor = vd
        psd.colorAttachments[0].pixelFormat = lightingPixelFormat
        psd.depthAttachmentPixelFormat = depthStencilFormat
        psd.supportIndirectCommandBuffers = true
        psd.colorAttachments[0].isBlendingEnabled = false
        psd.label = "MeshForwardPipelineState_Opaque_ICB"
        psd.fragmentFunction = fragmentFunctionOpaqueICB
        _forwardOpaque = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "MeshForwardPipelineState_AlphaMask_ICB"
        psd.fragmentFunction = fragmentFunctionAlphaMaskICB
        _forwardAlphaMask = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "MeshForwardPipelineState_Transparent_ICB"
        psd.fragmentFunction = fragmentFunctionTransparentICB
        psd.colorAttachments[0].rgbBlendOperation = .add
        psd.colorAttachments[0].alphaBlendOperation = .add
        psd.colorAttachments[0].sourceRGBBlendFactor = .one
        psd.colorAttachments[0].sourceAlphaBlendFactor = .one
        psd.colorAttachments[0].destinationRGBBlendFactor = .one
        psd.colorAttachments[0].destinationAlphaBlendFactor = .one
        psd.colorAttachments[0].isBlendingEnabled = true
        _forwardTransparent = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "MeshForwardPipelineState_LightClusters_Transparent_ICB"
        psd.fragmentFunction = fragmentFunctionLCTransparentICB
        _forwardTransparentLightCluster = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)


        //MARK: - ICB Debug pipelines
        psd.colorAttachments[0].isBlendingEnabled = false
        psd.label = "MeshForwardPipelineState_ICB_Debug"
        psd.fragmentFunction = fragmentFunctionOpaqueICBDebug
        _forwardOpaqueDebug = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "MeshForwardPipelineState_AlphaMask_ICB_Debug"
        psd.fragmentFunction = fragmentFunctionAlphaMaskICBDebug
        _forwardAlphaMaskDebug = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "Mesh_Forward_Transparent_ICB_Debug_PipelineState"
        psd.fragmentFunction = fragmentFunctionTransparentICBDebug
        psd.colorAttachments[0].isBlendingEnabled = false
        _forwardTransparentDebug = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        psd.label = "Mesh_Forward_LightClusters_Transparent_ICB_Debug_PipelineState"
        psd.fragmentFunction = fragmentFunctionLCTransparentICBDebug
        _forwardTransparentLightClusterDebug = try? _device.makeRenderPipelineState(descriptor: psd, options: MTLPipelineOption(), reflection: nil)

        // ----------------------------------
        //MARK: - Depth-only pipeline states
        // ----------------------------------
        let depthOnlyVertexFunction = library.makeFunction(name: "vertexShaderDepthOnly")

        let depthOnlyDescriptor = MTLRenderPipelineDescriptor()
        depthOnlyDescriptor.label = "DepthOnlyPipelineState"
        depthOnlyDescriptor.rasterSampleCount = 1
        depthOnlyDescriptor.vertexFunction = depthOnlyVertexFunction
        depthOnlyDescriptor.fragmentFunction = nilFragmentFunction
        depthOnlyDescriptor.vertexDescriptor = depthOnlyVD
        depthOnlyDescriptor.depthAttachmentPixelFormat = .depth32Float
        depthOnlyDescriptor.supportIndirectCommandBuffers = true
        // Enable vertex amplification - need a minimum of 2 amplification to enable on shaders
        if (genCSMUsingVertexAmplification) {
            depthOnlyDescriptor.maxVertexAmplificationCount = 2
        } else if (useSinglePassCSMGeneration) {
            depthOnlyDescriptor.maxVertexAmplificationCount = 1
        }
        _depthOnlyOpaque = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                options: MTLPipelineOption(), reflection: nil)

        if (genCSMUsingVertexAmplification) {
            depthOnlyDescriptor.vertexFunction = library.makeFunction(name: "vertexShaderDepthOnlyAmplified")
            _depthOnlyAmplifiedOpaque = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                    options: MTLPipelineOption(), reflection: nil)
        }

        let depthOnlyAlphaMaskVertexFunction = library.makeFunction(name: "vertexShaderDepthOnlyAlphaMask")
        let depthOnlyAlphaMaskFragmentFunction = library.makeFunction(name: "fragmentShaderDepthOnlyAlphaMask")
        depthOnlyDescriptor.label = "DepthOnlyPipelineState_AlphaMask"
        depthOnlyDescriptor.vertexFunction = depthOnlyAlphaMaskVertexFunction
        depthOnlyDescriptor.fragmentFunction = depthOnlyAlphaMaskFragmentFunction
        depthOnlyDescriptor.vertexDescriptor = depthOnlyAlphaMaskVD
        _depthOnlyAlphaMask = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                options: MTLPipelineOption(), reflection: nil)

        if (genCSMUsingVertexAmplification) {
            depthOnlyDescriptor.vertexFunction = library.makeFunction(name: "vertexShaderDepthOnlyAlphaMaskAmplified")
            _depthOnlyAmplifiedAlphaMask = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                    options: MTLPipelineOption(), reflection: nil)
        }

        // Reset vertex amplification to disabled
        if (genCSMUsingVertexAmplification) {
            depthOnlyDescriptor.maxVertexAmplificationCount = 1
        }

        let depthOnlyTileFragmentFunction = library.makeFunction(name: "fragmentShaderDepthOnlyTile")
        let depthOnlyTileAlphaMaskFragmentFunction = library.makeFunction(name: "fragmentShaderDepthOnlyTileAlphaMask")

        depthOnlyDescriptor.colorAttachments[0].pixelFormat = .r32Float

        depthOnlyDescriptor.label = "DepthOnlyTilePipelineState"
        depthOnlyDescriptor.vertexFunction = depthOnlyVertexFunction
        depthOnlyDescriptor.fragmentFunction = depthOnlyTileFragmentFunction

        _depthOnlyTileOpaque = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                options: MTLPipelineOption(), reflection: nil)

        depthOnlyDescriptor.label = "DepthOnlyTilePipelineState_AlphaMask"
        depthOnlyDescriptor.vertexFunction = depthOnlyAlphaMaskVertexFunction
        depthOnlyDescriptor.fragmentFunction = depthOnlyTileAlphaMaskFragmentFunction

        _depthOnlyTileAlphaMask = try? _device.makeRenderPipelineState(descriptor: depthOnlyDescriptor,
                options: MTLPipelineOption(), reflection: nil)

        // ----------------------------------
        //MARK: - GBuffer pipeline states
        // ----------------------------------

        fc = MTLFunctionConstantValues()
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexDebugView.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexTransparent.rawValue))
        let fragmentGBufferFunctionOpaqueICB = try? library.makeFunction(name: "fragmentGBufferShader", constantValues: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexAlphaMask.rawValue))
        let fragmentGBufferFunctionAlphaMaskICB = try? library.makeFunction(name: "fragmentGBufferShader", constantValues: fc)

        let rpd = MTLRenderPipelineDescriptor()
        rpd.label = "Mesh_GBufferPipelineState_Opaque_ICB"
        rpd.rasterSampleCount = sampleCount
        rpd.vertexFunction = vertexFunction
        rpd.fragmentFunction = fragmentGBufferFunctionOpaqueICB
        rpd.vertexDescriptor = vd
        rpd.depthAttachmentPixelFormat = depthStencilFormat
        rpd.supportIndirectCommandBuffers = true
        var GBufferIndexStart = XTraditionalGBufferStart.rawValue
        if (singlePassDeferredLighting) {
            GBufferIndexStart = XGBufferLightIndex.rawValue
        }
        for GBufferIndex in GBufferIndexStart..<XGBufferIndexCount.rawValue {
            rpd.colorAttachments[Int(GBufferIndex)].pixelFormat = GBufferPixelFormats[Int(GBufferIndex)]
        }
        _gBufferOpaque = try? _device.makeRenderPipelineState(descriptor: rpd, options: MTLPipelineOption(), reflection: nil)

        rpd.label = "Mesh_GBufferPipelineState_AlphaMask_ICB"
        rpd.fragmentFunction = fragmentGBufferFunctionAlphaMaskICB
        _gBufferAlphaMask = try? _device.makeRenderPipelineState(descriptor: rpd, options: MTLPipelineOption(), reflection: nil)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexDebugView.rawValue))
        let fragmentGBufferFunctionICBDebug = try? library.makeFunction(name: "fragmentGBufferShader", constantValues: fc)
        rpd.label = "Mesh_GBufferPipelineState_ICB_Debug"
        rpd.fragmentFunction = fragmentGBufferFunctionICBDebug
        _gBufferDebug = try? _device.makeRenderPipelineState(descriptor: rpd, options: MTLPipelineOption(), reflection: nil)
    }

    // Writes commands prior to executing a set of passes for rendering a mesh.
    func prerender(mesh: XMesh,
                   direct: Bool,
                   icbData: inout XICBData,
                   encoder: MTLRenderCommandEncoder) {
        if !direct {
            encoder.useResource(mesh.indices, usage: .read)
            encoder.useResource(mesh.vertices, usage: .read)
            encoder.useResource(mesh.normals, usage: .read)
            encoder.useResource(mesh.tangents, usage: .read)
            encoder.useResource(mesh.uvs, usage: .read)
        }
    }

    // Writes commands to render meshes using the command buffer.
    func render(mesh: XMesh,
                pass: XRenderPass,
                direct: Bool,
                icbData: inout XICBData,
                flags: [String: Bool],
                cameraParams: inout XCameraParams,
                encoder: MTLRenderCommandEncoder) {
        let cullingVisualizationMode = flags["cullingVisualizationMode"] ?? false
        let debugView = flags["debugView"] ?? false
        let clusteredLighting = flags["clusteredLighting"] ?? false
        let amplifyRendering = flags["amplify"] ?? false
        let useTileShader = flags["useTileShader"] ?? false

        var pipelineState: MTLRenderPipelineState? = nil
        if (pass == .Depth) {
            if (useTileShader) {
                pipelineState = _depthOnlyTileOpaque
            } else if (amplifyRendering) {
                pipelineState = _depthOnlyAmplifiedOpaque
            } else {
                pipelineState = _depthOnlyOpaque
            }
        } else if (pass == .DepthAlphaMasked) {
            if (useTileShader) {
                pipelineState = _depthOnlyTileAlphaMask
            } else if (amplifyRendering) {
                pipelineState = _depthOnlyAmplifiedAlphaMask
            } else {
                pipelineState = _depthOnlyAlphaMask
            }
        } else if (pass == .GBuffer) {
            pipelineState = _gBufferOpaque
        } else if (pass == .GBufferAlphaMasked) {
            pipelineState = _gBufferAlphaMask
        } else if (pass == .Forward) {
            pipelineState = _forwardOpaque
        } else if (pass == .ForwardAlphaMasked) {
            pipelineState = _forwardAlphaMask
        } else if (pass == .ForwardTransparent) {
            pipelineState = clusteredLighting ? _forwardTransparentLightCluster : _forwardTransparent
        } else {
            fatalError("Unsupported pass type")
        }

        if (cullingVisualizationMode) {
            if (pass == .GBuffer || pass == .GBufferAlphaMasked) {
                pipelineState = _gBufferDebug
            }
        }

        if (debugView) {
            if (pass == .Forward) {
                pipelineState = _forwardOpaqueDebug
            } else if (pass == .ForwardAlphaMasked) {
                pipelineState = _forwardAlphaMaskDebug
            } else if (pass == .ForwardTransparent) {
                pipelineState = _forwardTransparentDebug
            }
        }

        if (pass == .ForwardTransparent && clusteredLighting) {
            if (debugView) {
                pipelineState = _forwardTransparentLightClusterDebug
            } else {
                pipelineState = _forwardTransparentLightCluster
            }
        }

        if (pipelineState == nil) {
            return
        }

        encoder.setRenderPipelineState(pipelineState!)

        if (pass == .DepthAlphaMasked
                || pass == .GBufferAlphaMasked
                || pass == .ForwardAlphaMasked
                || pass == .ForwardTransparent) {
            encoder.setCullMode(.none)
        }

        let materialSize = direct ? _alignedMaterialSize : _materialSize

        _textureManager.makeResident(for: encoder)

        if (direct) {
            encoder.setVertexBuffer(mesh.vertices, offset: 0, index: Int(XBufferIndexVertexMeshPositions.rawValue))
            encoder.setVertexBuffer(mesh.normals, offset: 0, index: Int(XBufferIndexVertexMeshNormals.rawValue))
            encoder.setVertexBuffer(mesh.tangents, offset: 0, index: Int(XBufferIndexVertexMeshTangents.rawValue))
            encoder.setVertexBuffer(mesh.uvs, offset: 0, index: Int(XBufferIndexVertexMeshGenerics.rawValue))

            var submeshes: UnsafePointer<XSubMesh>? = nil
            var submeshCount = 0
            if (pass == .Depth || pass == .GBuffer || pass == .Forward) {
                submeshes = mesh.meshes
                submeshCount = Int(mesh.opaqueMeshCount)
            } else if (pass == .DepthAlphaMasked || pass == .GBufferAlphaMasked || pass == .ForwardAlphaMasked) {
                submeshes = mesh.meshes.advanced(by: Int(mesh.opaqueMeshCount))
                submeshCount = Int(mesh.alphaMaskedMeshCount)
            } else if (pass == .ForwardTransparent) {
                submeshes = mesh.meshes.advanced(by: Int(mesh.opaqueMeshCount + mesh.alphaMaskedMeshCount))
                submeshCount = Int(mesh.transparentMeshCount)
            } else {
                fatalError("Unsupported pass type")
            }
            drawSubMeshes(submeshes!, count: submeshCount, indexBuffer: mesh.indices,
                    chunkData: mesh.chunkData, setMaterialOffset: pass != .Depth,
                    materialSize: materialSize, cameraParams: cameraParams, renderEncoder: encoder)
        } else {
            var cmdBuffer: MTLIndirectCommandBuffer? = nil
            var executionRangeOffset = 0

            if (pass == .Depth) {
                cmdBuffer = icbData.commandBuffer_depthOnly
                executionRangeOffset = 0
            } else if (pass == .DepthAlphaMasked) {
                cmdBuffer = icbData.commandBuffer_depthOnly_alphaMask
                executionRangeOffset = MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride
            } else if (pass == .GBuffer
                    || pass == .Forward) {
                cmdBuffer = icbData.commandBuffer
                executionRangeOffset = 0
            } else if (pass == .GBufferAlphaMasked
                    || pass == .ForwardAlphaMasked) {
                cmdBuffer = icbData.commandBuffer_alphaMask
                executionRangeOffset = MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride
            } else if (pass == .ForwardTransparent) {
                cmdBuffer = icbData.commandBuffer_transparent
                executionRangeOffset = MemoryLayout<MTLIndirectCommandBufferExecutionRange>.stride * 2
            } else {
                fatalError("Unsupported pass type")
            }
            encoder.executeCommandsInBuffer(cmdBuffer!, indirectBuffer: icbData.executionRangeBuffer, offset: executionRangeOffset)
        }
    }

    private func drawSubMeshes(_ meshes: UnsafePointer<XSubMesh>,
                               count: Int,
                               indexBuffer: MTLBuffer,
                               chunkData: UnsafePointer<XMeshChunk>,
                               setMaterialOffset: Bool,
                               materialSize: Int,
                               cameraParams: XCameraParams,
                               renderEncoder: MTLRenderCommandEncoder) {
        for i in 0..<count {
            let mesh = meshes[i]

            if (setMaterialOffset) {
                renderEncoder.setFragmentBufferOffset(Int(mesh.materialIndex) * materialSize,
                                                      index: Int(XBufferIndexFragmentMaterial.rawValue))
            }

            let frustumCulled = !sphereInFrustum(cameraParams: cameraParams, sphere: mesh.boundingSphere)

            if (frustumCulled) {
                continue
            }

            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: Int(mesh.indexCount),
                    indexType: .uint32, indexBuffer: indexBuffer,
                    indexBufferOffset: Int(mesh.indexBegin) * MemoryLayout<UInt32>.stride)
        }
    }
}

@inlinable
func distanceToPlane(_ sphere: XSphere, _ planeEq: simd_float4) -> Float {
    let centerDist = simd_dot(planeEq, simd_make_float4(sphere.data.x, sphere.data.y, sphere.data.z, 1))
    return centerDist > 0 ? simd_max(0.0, centerDist - sphere.data.w) : simd_min(0.0, centerDist + sphere.data.w)
}

// Checks if a sphere is in a frustum.
func sphereInFrustum(cameraParams: XCameraParams, sphere: XSphere) -> Bool {
    return (simd_min(
            simd_min(distanceToPlane(sphere, cameraParams.worldFrustumPlanes.0),
                    simd_min(distanceToPlane(sphere, cameraParams.worldFrustumPlanes.1),
                            distanceToPlane(sphere, cameraParams.worldFrustumPlanes.2))),
            simd_min(distanceToPlane(sphere, cameraParams.worldFrustumPlanes.3),
                    simd_min(distanceToPlane(sphere, cameraParams.worldFrustumPlanes.4),
                            distanceToPlane(sphere, cameraParams.worldFrustumPlanes.5))))) >= 0.0
}
