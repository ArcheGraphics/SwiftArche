//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum LightingMode {
    /// Deferred with lights filtered per tile.
    case DeferredTiled
    /// Deferred with lights clustered per tile.
    case DeferredClustered
    /// Forward rendering.
    case Forward

    /// Checks if lighting mode is deferred.
    static func lightingModeIsDeferred(_ mode: LightingMode) -> Bool {
        switch mode {
        case .Forward:
            return false
        case .DeferredTiled, .DeferredClustered:
            return true
        }
    }
}

/// Options for encoding rendering.
public enum RenderMode {
    /// CPU encoding of draws with a `MTLRenderCommandEncoder`.
    case Direct
    /// GPU encoding of draws with an `MTLIndirectCommandBuffer`.
    case Indirect
}

/// Options for types of culling to apply.
public struct RenderCullType: OptionSet {
    public let rawValue: UInt32

    /// this initializer is required, but it's also automatically
    /// synthesized if `rawValue` is the only member, so writing it
    /// here is optional:
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let None = RenderCullType([])
    public static let Frustum = RenderCullType(rawValue: 1)
    public static let FrustumDepth = RenderCullType(rawValue: 2)
    public static let Count = RenderCullType(rawValue: 3)
    public static let Visualization = RenderCullType(rawValue: RenderCullType.FrustumDepth.rawValue | 0x10000)
}

// MARK: - Render Config with hardware support

// FIXME: - Must modify config in vox.shader by correspoding change
public enum RenderConfig {
    public static var supportMaterialUpdates: Bool {
        true
    }

    public static var useTextureStreaming: Bool {
        true && supportMaterialUpdates
    }

    public static var supportSparseTexture: Bool {
        true && useTextureStreaming
    }

    public static var supportPageAccessCounters: Bool {
        true && supportSparseTexture
    }

    public static var enableDebugRendering: Bool {
        true
    }

    public static var supportRasterizationRate: Bool {
        true
    }

    public static var useResolvePass: Bool {
        true
    }

    public static var supportTAA: Bool {
        true && useResolvePass
    }

    /// High level flag to enable SAO.
    public static var useScalableAmbientObscurance: Bool {
        true
    }

    /// Enable use of local lights in the scene.  When disabled, only the sun used.
    public static var useLocalLights: Bool {
        true
    }

    /// High level flag to enable the scatter volume.
    public static var useScatteringVolume: Bool {
        true
    }

    /// Local lights contribute to the scattering volume.
    public static var localLightScattering: Bool {
        true && useScatteringVolume && useLocalLights
    }

    /// Support using tile shaders for depth prepass on Apple Silicon.
    public static var supportDepthPrepassTileShader: Bool {
        true
    }

    /// Support using tile shaders for light culling on Apple Silicon.
    public static var supportLightCullingTileShaders: Bool {
        true && supportDepthPrepassTileShader
    }

    /// Uses tile shaders to downsample depth from the imageblock.
    public static var supportDepthDownSampleTileShader: Bool {
        true && supportLightCullingTileShaders
    }

    /// Uses tile shaders to perform light clustering.
    public static var supportLightClusteringTileShader: Bool {
        true && supportLightCullingTileShaders
    }

    /// Enable code to perform deferred lighting in a single render pass using programable blending.
    public static var supportSinglePassDeferred: Bool {
        true
    }

    /// Enables the reset and optimization of command buffers after they are generated.
    public static var optimizeCommandBuffers: Bool {
        true
    }

    /// Enables use of vertex amplification to render to entire shadow cascade set in one encoder.
    public static var supportSinglePassCSMGeneration: Bool {
        true
    }

    /// Enables culling to generate an ICB that represents the difference between cascade 2 from cascade 1.
    /// Cascade 1 amplified to cascade 2, and only the difference ICB rendered to cascade 2.
    public static var supportCSMGenerationWithVertexAmplification: Bool {
        true && supportSinglePassCSMGeneration
    }

    // MARK: - Config Constants

    /// Use Equal depth test when rendering GBuffer after depth prepass.
    /// Noticeable win on traditional GPUs
    public static var useEqualDepthTest: Bool {
        true
    }

    public static var maxFrameInFlight: Int {
        3
    }

    public static var taaJitterCount: Int {
        8
    }

    public static var maxAnisotropy: Int {
        10
    }

    public static var alphaCount: Float {
        0.1
    }

    /// Size of tiles for depth bounds calculation in tile shaders.
    public static var tileDepthBoundsDispatchSize: Int {
        8
    }

    /// Flag to indicate that this light is included in scattering and affects transparencies.
    /// Lights are culled without limiting to the opaque depth range in the tile.
    public static var lightForTransparentFlag: UInt32 {
        0x0000_0001
    }

    public static var lightClusterRange: Float {
        100
    }

    /// The maximum number of lights in a tile.
    public static var maxLightsPerTile: Int {
        64
    }

    public static var maxLightPerCluster: Int {
        16
    }

    public static var lightClusterDepth: Int {
        64
    }

    public static var spotShadowMaxCount: Int {
        32
    }

    public static var spotShadowDepthBias: Float {
        0.001
    }

    public static var tileShaderDimension: Int {
        16
    }

    public static var tileShaderWidth: Int {
        tileShaderDimension
    }

    public static var tileShaderHeight: Int {
        tileShaderDimension
    }

    /// Light culling tile size for Apple Silicon devices.
    public static var TBDRLightCullingTileSize: Int {
        tileShaderDimension
    }

    /// Light culling tile size for AMD and Intel devices.
    public static var defaultLightCullingTileSize: Int {
        32
    }

    public static var textureHeapSize: Int {
        if useTextureStreaming {
            return 512 * 1024 * 1024 // 512MB
        } else {
            #if os(iOS)
                return 512 * 1024 * 1024 // 512MB
            #else
                return 1536 * 1024 * 1024 // 1.5GB
            #endif
        }
    }

    /// Size of scattering volume tiles in pixels.
    public static var scatteringTileSize: Int {
        8
    }

    /// Number of depth slices in scattering volume
    public static var scatteringVolumeDepth: Int {
        64
    }

    /// View space range of scattering volume.
    public static var scatteringRange: Float {
        100
    }

    // MARK: - User-Define Config

    public static var lightingMode: LightingMode = .DeferredClustered

    public static var renderMode: RenderMode = .Indirect
    public static var renderCullType: RenderCullType = .FrustumDepth

    public static var shadowRenderMode: RenderMode = .Indirect
    public static var shadowCullType: RenderCullType = .FrustumDepth

    /// Indicates use of temporal antialiasing in resolve pass
    public static var useTemporalAA: Bool {
        true && supportTAA
    }

    /// Indicates use of single pass deferred lighting avaliable to TBDR GPUs.
    public static var singlePassDeferredLighting: Bool {
        Engine.device.supportsFamily(.mac2) && supportSinglePassDeferred
    }

    /// Indicates whether to preform a depth prepass using tiles shaders.
    public static var useDepthPrepassTileShaders: Bool {
        Engine.device.supportsFamily(.mac2) && supportDepthPrepassTileShader
    }

    /// Indicates use of a tile shader instead of traditional compute kernels to cull lights
    public static var useLightCullingTileShaders: Bool {
        Engine.device.supportsFamily(.mac2) && supportLightCullingTileShaders
    }

    /// Indicates use of a tile shader instead of traditional compute kernels downsample depth.
    public static var useDepthDownsampleTileShader: Bool {
        Engine.device.supportsFamily(.mac2) && supportDepthDownSampleTileShader
    }

    /// Indicates use of vertex amplification  to render to all shadow map cascased in a single pass.
    public static var useSinglePassCSMGeneration: Bool {
        Engine.device.supportsVertexAmplificationCount(1) && Engine.device.supportsFamily(.mac2) && supportSinglePassCSMGeneration
    }

    /// Indicate use of vertex amplification to draw to multiple cascades in with a single draw or execute indirect command.
//    public static var genCSMUsingVertexAmplification: Bool {
//        Engine.device.supportsVertexAmplificationCount(2) && useSinglePassCSMGeneration && supportCSMGenerationWithVertexAmplification
//    }

    /// Indicates use of rasterization rate to increase resolution at center of FOV.
    public static var useRasterizationRate: Bool {
        Engine.device.supportsRasterizationRateMap(layerCount: 1) && supportRasterizationRate
    }

    /// Indecates whether to page textures onto a sparse heap
    public static var useSparseTextures: Bool {
        Engine.device.supportsFamily(.mac2) && supportSparseTexture
    }

    /// Indicates whether to prefer assets using the ASTC pixel format
    public static var useASTCPixelFormat: Bool {
        Engine.device.supportsFamily(.mac2)
    }

    static let SpotShadowRenderMode: RenderMode = .Direct

    /// GBuffer depth and stencil formats.
    static let DepthStencilFormat: MTLPixelFormat = .depth32Float
    static let LightingPixelFormat: MTLPixelFormat = .rgba16Float
    static let HistoryPixelFormat: MTLPixelFormat = .bgra8Unorm_srgb

    static var GBufferPixelFormats: [MTLPixelFormat] {
        var formats: [MTLPixelFormat] = []
        if supportSinglePassDeferred {
            // Lighting.
            formats.append(useResolvePass ? LightingPixelFormat : .bgra8Unorm_srgb)
        }
        // Albedo/Alpha.
        formats.append(.rgba8Unorm_srgb)
        // Nnormal.
        formats.append(.rgba16Float)
        // Emissive.
        formats.append(.rgba8Unorm_srgb)
        // F0/Roughness.
        formats.append(.rgba8Unorm_srgb)
        return formats
    }

    static let MaxPointLights = 1024
    static let MaxSpotLights = 1024
}
