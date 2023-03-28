//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

enum XLightingMode {
    /// Deferred with lights filtered per tile.
    case LightingModeDeferredTiled
    /// Deferred with lights clustered per tile.
    case LightingModeDeferredClustered
    /// Forward rendering.
    case LightingModeForward

    // Checks if lighting mode is deferred.
    static func lightingModeIsDeferred(_ mode: XLightingMode) -> Bool {
        switch (mode) {
        case .LightingModeForward:
            return false
        case .LightingModeDeferredTiled, .LightingModeDeferredClustered:
            return true
        }
    }
}

struct XConfig {
    var lightingMode: XLightingMode

    var renderMode: XRenderMode
    var renderCullType: XRenderCullType

    var shadowRenderMode: XRenderMode
    var shadowCullType: XRenderCullType

    /// Indicates use of temporal antialiasing in resolve pass
    var useTemporalAA: Bool

    /// Indicates use of single pass deferred lighting avaliable to TBDR GPUs.
    var singlePassDeferredLighting: Bool

    /// Indicates whether to preform a depth prepass using tiles shaders.
    var useDepthPrepassTileShaders: Bool

    /// Indicates use of a tile shader instead of traditional compute kernels to cull lights
    var useLightCullingTileShaders: Bool

    /// Indicates use of a tile shader instead of traditional compute kernels downsample depth.
    var useDepthDownsampleTileShader: Bool

    /// Indicates use of vertex amplification  to render to all shadow map cascased in a single pass.
    var useSinglePassCSMGeneration: Bool

    /// Indicate use of vertex amplification to draw to multiple cascades in with a single draw or execute indirect command.
    var genCSMUsingVertexAmplification: Bool

    /// Indicates use of rasterization rate to increase resolution at center of FOV.
    var useRasterizationRate: Bool

    /// Indecates whether to page textures onto a sparse heap
    var useSparseTextures: Bool

    /// Indicates whether to prefer assets using the ASTC pixel format
    var useASTCPixelFormat: Bool

    #if USE_SPOT_LIGHT_SHADOWS
    static let SpotShadowRenderMode: XRenderMode = .RenderModeDirect
    #endif

    // GBuffer depth and stencil formats.
    static let DepthStencilFormat: MTLPixelFormat = .depth32Float
    static let LightingPixelFormat: MTLPixelFormat = .rgba16Float
    static let HistoryPixelFormat: MTLPixelFormat = .bgra8Unorm_srgb

    static let GBufferPixelFormats: [MTLPixelFormat] = [
        USE_RESOLVE_PASS != 0 ? LightingPixelFormat : .bgra8Unorm_srgb, // Lighting.
        .rgba8Unorm_srgb, // Albedo/Alpha.
        .rgba16Float, // Nnormal.
        .rgba8Unorm_srgb, // Emissive.
        .rgba8Unorm_srgb, // F0/Roughness.
    ]


// Shadow configuration.
    static let ShadowMapSize = 1024

    #if USE_SPOT_LIGHT_SHADOWS
    static let SpotShadowMapSize = 256
    #endif

// Number of views to be rendered. Main view plus shadow cascades.
    static let NUM_VIEWS = (1 + SHADOW_CASCADE_COUNT)

    static let MaxPointLights = 1024
    static let MaxSpotLights = 1024

}
