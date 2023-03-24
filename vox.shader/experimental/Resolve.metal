//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"

//------------------------------------------------------------------------------

constant bool gUseRasterizationRate    [[function_constant(XFunctionConstIndexRasterizationRate)]];

constant bool gUseTemporalAntialiasing [[function_constant(XFunctionConstIndexTemporalAntialiasing)]];

//------------------------------------------------------------------------------

// Standard ACES tonemap function.
static xhalf3 ToneMapACES(xhalf3 x)
{
    xhalf a = 2.51f;
    xhalf b = 0.03f;
    xhalf c = 2.43f;
    xhalf d = 0.59f;
    xhalf e = 0.14f;
    return saturate((x*(a*x+b))/(x*(c*x+d)+e));
}

// Samples a texture with Catmull-Rom interpolation of the sampled values.
static xhalf3 sampleCatmullRom(texture2d<float, access::sample> tex,
                               float2 texCoord,
                               float2 texSize,
                               float2 invTexSize)
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, address::clamp_to_edge);

    float2 position = texSize * texCoord;
    float2 centerPosition = floor(position - 0.5f) + 0.5f;

    float2 f    = position - centerPosition;
    float2 f2   = f * f;
    float2 f3   = f * f2;

    float c = 0.5f;

    float2 w0 = -c * f3 + 2.0f * c * f2 - c * f;
    float2 w1 = (2.0f - c) * f3 - (3.0f - c) * f2 + 1.0f;
    float2 w2 = -(2.0f - c) * f3 + (3.0f -  2.0f * c) * f2 + c * f;
    float2 w3 = c * f3 - c * f2;

    float2 w12 = w1 + w2;
    float2 tc12 = (centerPosition + w2 / w12) * invTexSize;

    float2 tc0 = (centerPosition - 1.0) * invTexSize;
    float2 tc3 = (centerPosition + 2.0) * invTexSize;

    float3 centerColor  = tex.sample(linearSampler, float2(tc12.x, tc12.y)).rgb;
    float3 sample0      = tex.sample(linearSampler, float2(tc12.x, tc0.y)).rgb;
    float3 sample1      = tex.sample(linearSampler, float2(tc0.x, tc12.y)).rgb;
    float3 sample2      = tex.sample(linearSampler, float2(tc3.x, tc12.y)).rgb;
    float3 sample3      = tex.sample(linearSampler, float2(tc12.x, tc3.y)).rgb;

    float4 color =  float4(sample0, 1.0f) * (w12.x * w0.y) + float4(sample1, 1.0f) * (w0.x * w12.y) +
                    float4(centerColor, 1.0f) * (w12.x * w12.y) +
                    float4(sample2, 1.0f) * (w3.x * w12.y) + float4(sample3, 1.0f) * (w12.x * w3.y);

    return (xhalf3)(color.rgb * 1.0f / color.a);
}

//------------------------------------------------------------------------------

// Fragment shader to temporally resolve the output of the current frame with
//  the history from the previous frame.
//  Also applies an ACES tonemap to the result.
fragment xhalf4 fragmentResolveShader(XSimpleTexVertexOut in                     [[stage_in]],
                                      constant XFrameConstants & frameData       [[buffer(XBufferIndexFrameData)]],
                                      constant XCameraParams & cameraParams      [[buffer(XBufferIndexCameraParams)]],
                                      constant rasterization_rate_map_data * rrData [[buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate)]],
                                      texture2d<xhalf, access::sample> current      [[texture(0)]],
                                      texture2d<float, access::sample> history      [[texture(1)]],
                                      depth2d<float, access::sample> depthTexture   [[texture(2)]])
{
    constexpr sampler readSampler(mag_filter::nearest, min_filter::nearest, address::clamp_to_zero, coord::pixel);

    float2 screenPos = in.position.xy;
#if SUPPORT_RASTERIZATION_RATE
    if (gUseRasterizationRate)
    {
        // Perform the physical -> screen upscale during resolve.
        rasterization_rate_map_decoder decoder(*rrData);
        screenPos = decoder.map_screen_to_physical_coordinates(in.position.xy);
    }
#endif

    xhalf3 center = current.sample(readSampler, screenPos).rgb;

    xhalf3 result = ToneMapACES(center * frameData.exposure);

#if SUPPORT_TEMPORAL_ANTIALIASING
    if(gUseTemporalAntialiasing)
    {
        xhalf3 n0 = current.sample(readSampler, screenPos, int2(-1,-1)).rgb;
        xhalf3 n1 = current.sample(readSampler, screenPos, int2(-1,0)).rgb;
        xhalf3 n2 = current.sample(readSampler, screenPos, int2(-1,1)).rgb;
        xhalf3 n3 = current.sample(readSampler, screenPos, int2(0,-1)).rgb;
        xhalf3 n5 = current.sample(readSampler, screenPos, int2(0,1)).rgb;
        xhalf3 n6 = current.sample(readSampler, screenPos, int2(1,-1)).rgb;
        xhalf3 n7 = current.sample(readSampler, screenPos, int2(1,0)).rgb;
        xhalf3 n8 = current.sample(readSampler, screenPos, int2(1,1)).rgb;

        xhalf3 minH0 = min3(n0, n1, n2);
        xhalf3 minH1 = min3(n3, center, n5);
        xhalf3 minH2 = min3(n6, n7, n8);
        xhalf3 minC = min3(minH0, minH1, minH2);

        xhalf3 maxH0 = max3(n0, n1, n2);
        xhalf3 maxH1 = max3(n3, center, n5);
        xhalf3 maxH2 = max3(n6, n7, n8);
        xhalf3 maxC = max3(maxH0, maxH1, maxH2);

        minC = ToneMapACES(minC * frameData.exposure);
        maxC = ToneMapACES(maxC * frameData.exposure);

        // sample history
        const float depth = depthTexture.sample(readSampler, screenPos);

        float3 worldPosition = worldPositionForTexcoord(in.texCoord, depth, cameraParams).xyz;

        float4 prevPos = frameData.prevViewProjectionMatrix * float4(worldPosition, 1.0f);
        prevPos.xyz /= prevPos.w;

        float2 prevUV = prevPos.xy * float2(0.5f, -0.5f) + 0.5f;

        xhalf3 historySample = sampleCatmullRom(history, prevUV, frameData.screenSize, frameData.invScreenSize);

        historySample = clamp(historySample, minC, maxC);

        float blendFactor = 0.95f;

        if(any(abs(prevPos.xy) > 1.0f))
            blendFactor = 0.0f;

        result = mix(result, historySample, blendFactor);
    }
#endif

    return xhalf4(result, 1.0f);
}
