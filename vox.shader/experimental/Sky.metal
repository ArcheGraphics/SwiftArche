//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"

//------------------------------------------------------------------------------

constant bool gUseRasterizationRate [[function_constant(XFunctionConstIndexRasterizationRate)]];

//------------------------------------------------------------------------------

// Skybox shader for forward rendering.
fragment xhalf4 skyboxShader(XSimpleTexVertexOut in                      [[ stage_in ]],
                             constant XFrameConstants & frameData        [[ buffer(XBufferIndexFrameData) ]],
                             constant XCameraParams & cameraParams       [[ buffer(XBufferIndexCameraParams) ]],
                             constant rasterization_rate_map_data * rrData  [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],
                             constant XGlobalTextures & globalTextures   [[ buffer(XBufferIndexFragmentGlobalTextures) ]]
                             )
{
    xhalf3 result = (xhalf3)frameData.skyColor;

    float2 screenUV = in.texCoord.xy;
#if SUPPORT_RASTERIZATION_RATE
    if (gUseRasterizationRate)
    {
        // Currently drawing inside compressed space, so must fix up screen space.
        rasterization_rate_map_decoder decoder(*rrData);
        screenUV = decoder.map_physical_to_screen_coordinates(screenUV * frameData.physicalSize) * frameData.invScreenSize;
    }
#endif

#if USE_SCATTERING_VOLUME
    float linearDepth = linearizeDepth(cameraParams, 1.0f);
    xhalf4 scatteringSample;
    {
        constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, address::clamp_to_edge);

        float scatterDepth = zToScatterDepth(linearDepth);
        scatterDepth = saturate(scatterDepth);

        scatteringSample = globalTextures.scattering.sample(linearSampler, float3(screenUV, scatterDepth));

        result = result * scatteringSample.a + scatteringSample.rgb;
    }
#endif

    return xhalf4(result, 0.0f);
}
