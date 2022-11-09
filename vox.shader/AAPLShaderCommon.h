//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#ifndef AAPLShaderCommon_h
#define AAPLShaderCommon_h

// Raster order group definitions
#define AAPLLightingROG  0
#define AAPLGBufferROG   1

// G-buffer outputs using Raster Order Groups
struct GBufferData {
    half4 lighting        [[color(AAPLRenderTargetLighting), raster_order_group(AAPLLightingROG)]];
    half4 albedo_specular [[color(AAPLRenderTargetAlbedo), raster_order_group(AAPLGBufferROG)]];
    half4 normal_shadow   [[color(AAPLRenderTargetNormal), raster_order_group(AAPLGBufferROG)]];
    float depth           [[color(AAPLRenderTargetDepth), raster_order_group(AAPLGBufferROG)]];
};

// Final buffer outputs using Raster Order Groups
struct AccumLightBuffer {
    half4 lighting [[color(AAPLRenderTargetLighting), raster_order_group(AAPLLightingROG)]];
};

#endif // AAPLShaderCommon_h
