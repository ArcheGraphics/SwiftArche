//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"

// Calculates a camera space position for XY coordinates at a specific depth.
inline float3 GetCameraSpacePositionFromDepth(uint2 coordinates,
                                              float depth,
                                              constant XFrameConstants& frameData,
                                              constant XCameraParams& cameraParams)
{
    float4 ndc;
    ndc.xy = (float2(coordinates) + 0.5) * frameData.invPhysicalSize;

    ndc.xy = ndc.xy * 2 - 1;
    ndc.y *= -1;
    ndc.z = depth;
    ndc.w = 1;

    float4x4 invProjectionMatrix = cameraParams.invProjectionMatrix;
    float4 cameraSpacePosition = {
        ndc.x * invProjectionMatrix.columns[0][0] + invProjectionMatrix.columns[3][0],
        ndc.y * invProjectionMatrix.columns[1][1] + invProjectionMatrix.columns[3][1],
        1.0f,
        ndc.z * invProjectionMatrix.columns[2][3] + invProjectionMatrix.columns[3][3]
    };
    cameraSpacePosition.xyz /= cameraSpacePosition.w;

    return cameraSpacePosition.xyz;
}

// Calculates an XY camera space position for XY coordinates.
inline float2 GetCameraSpaceBasePosition(uint2 coordinates,
                                         constant XFrameConstants& frameData,
                                         constant XCameraParams& cameraParams)
{
    float2 ndc;
    ndc.xy = (float2(coordinates) + 0.5) * frameData.invPhysicalSize;
    ndc.xy = ndc.xy * 2 - 1;
    ndc.y *= -1;

    float4x4 invProjectionMatrix = cameraParams.invProjectionMatrix;
    float2 cameraSpacePosition = {
        ndc.x * invProjectionMatrix.columns[0][0] + invProjectionMatrix.columns[3][0],
        ndc.y * invProjectionMatrix.columns[1][1] + invProjectionMatrix.columns[3][1],
    };

    return cameraSpacePosition;
}

// Calculates a camera space position from a base position and offset
inline float3 GetOffsetCameraSpacePositionFromDepth(float2 baseInCameraSpace,
                                                    float2 offsetInScreenSpace,
                                                    float depth,
                                                    constant XFrameConstants& frameData,
                                                    constant XCameraParams& cameraParams)
{
    float4x4 invProjectionMatrix = cameraParams.invProjectionMatrix;
    const float2 ndcScale = float2(2.0f, -2.0f) * frameData.invPhysicalSize;
    const float2 cameraSpaceScale = ndcScale * float2(invProjectionMatrix.columns[0][0], invProjectionMatrix.columns[1][1]);

    float4 cameraSpacePosition = float4(baseInCameraSpace + offsetInScreenSpace * cameraSpaceScale,
                                        1.0f,
                                        depth * invProjectionMatrix.columns[2][3] + invProjectionMatrix.columns[3][3]);

    cameraSpacePosition.xyz /= cameraSpacePosition.w;

    return cameraSpacePosition.xyz;
}

// Rotates a vector by a (sin, cos) pair.
inline float2 RotateVector(float2 v, float2 rotation)
{
    float2 vr;
    vr.x = v.x * rotation.x - v.y * rotation.y;
    vr.y = v.x * rotation.y + v.y * rotation.x;
    return vr;
}

// This function does not correctly account for the warping of texture space when sampling from a
// a depth texture rendered with a variable rasterization rate (VRR).  The coordinates used to
// sample from the depth texture do do not account for VRR so the radius of ambient occlusion will
// be larger in tiles rendered with a reduced rasterization rate.   To correctly account for the
// warping, the function would need to unwarp the texture coordinates before sampling.   While some
// visual artifacts might be visible using this implementation, it provides a good trade-off between
// quality and performance.
kernel void scalableAmbientObscurance(uint2 coordinates                              [[thread_position_in_grid]],
                                      uint2 size                                     [[threads_per_grid]],
                                      constant XFrameConstants& frameData         [[buffer(XBufferIndexFrameData)]],
                                      constant XCameraParams& cameraParams        [[buffer(XBufferIndexCameraParams)]],
                                      texture2d<float, access::write> image          [[texture(0)]],
                                      texture2d<float, access::read> depthTexture    [[texture(1)]],
                                      texture2d<float, access::read> depthMipTexture [[texture(2)]])
{
    const bool temporal = true;
    const int temporalFrames = temporal ? 4 : 1;

    int tapCount = 36 / temporalFrames;

    const float radius = 0.5f * depthTexture.get_height() * cameraParams.projectionMatrix[1][1]; // 1m in pixels = 1/2 height / tan(1/2 fov)
    const uint numSpirals = 11;
    const float bias = 0.001f;
    const float epsilon = 0.01;
    const float intensity = 1.0f;

    float depth = depthTexture.read(coordinates).x;
    float3 cameraPosition = GetCameraSpacePositionFromDepth(coordinates, depth, frameData, cameraParams);

    float2 cameraBasePosition = GetCameraSpaceBasePosition(coordinates, frameData, cameraParams);

    float depthd = depthTexture.read(coordinates + uint2(0, 1)).x;
    float depthr = depthTexture.read(coordinates + uint2(1, 0)).x;
    float depthu = depthTexture.read(coordinates - uint2(0, 1)).x;
    float depthl = depthTexture.read(coordinates - uint2(1, 0)).x;
    float3 cameraPositiond = GetOffsetCameraSpacePositionFromDepth(cameraBasePosition, float2(0, 1), depthd, frameData, cameraParams);
    float3 cameraPositionr = GetOffsetCameraSpacePositionFromDepth(cameraBasePosition, float2(1, 0), depthr, frameData, cameraParams);
    float3 cameraPositionu = GetOffsetCameraSpacePositionFromDepth(cameraBasePosition, float2(0, -1), depthu, frameData, cameraParams);
    float3 cameraPositionl = GetOffsetCameraSpacePositionFromDepth(cameraBasePosition, float2(-1, 0), depthl, frameData, cameraParams);

    float3 dyu = cameraPositionu - cameraPosition;
    float3 dyd = cameraPositiond - cameraPosition;
    float3 dy = length_squared(dyd) < length_squared(dyu) ? dyd : -dyu;
    float3 dxr = cameraPositionr - cameraPosition;
    float3 dxl = cameraPositionl - cameraPosition;
    float3 dx = length_squared(dxl) < length_squared(dxr) ? -dxl : dxr;
    float3 normal = normalize(cross(dx, dy));

    float sum = 0.0f;
    int taps = 0;
    uint seed = ((coordinates.y << 16) | coordinates.x) * 100;

    if(temporal)
        seed += frameData.frameCounter;

    float dither = wang_hash(seed) / ((float)((uint)0xFFFFFFFF));

    float discSize = radius / cameraPosition.z;
    float angleIncrement = (numSpirals * M_PI_F * 2.0f) / tapCount;
    float2 tapRotation = float2(cos(angleIncrement), sin(angleIncrement));

    float initialAngle = dither * M_PI_F * 2.0f;
    float2 offsetDirection = float2(cos(initialAngle), sin(initialAngle));

    float alpha = dither / tapCount;

    for(int i = 0 ; i < tapCount ; i++, alpha += 1.0f / tapCount, offsetDirection = RotateVector(offsetDirection, tapRotation))
    {
        float offsetScale = alpha * alpha; // Square to bias towards to origin

        float2 offset = floor(offsetDirection * offsetScale * discSize);
        int2 xy = (int2)coordinates + (int2)offset;
        if(any(xy < int2(0, 0)) || any(xy >= int2(depthTexture.get_width(), depthTexture.get_height())))
            continue;

        int mipLevel = log2(max(abs(offset.x), abs(offset.y))) - 3;
        mipLevel = clamp(mipLevel, 0, 6);
        //float depth2 = depthTexture.read((uint2)xy).x;
        //float depth2 = depthTexture.read((uint2)(xy >> (mipLevel)), mipLevel).x;
        float depth2 = depthMipTexture.read((uint2)(xy >> (mipLevel+1)), mipLevel).x;
        if(depth2 == 1.0f)
            continue;

        float3 cameraPosition2 = GetOffsetCameraSpacePositionFromDepth(cameraBasePosition, offset, depth2, frameData, cameraParams);
        float3 v = cameraPosition2 - cameraPosition;

        float vv = dot(v, v);
        float vn = dot(v, normal);
        sum += max((vn - bias) / (epsilon + vv), 0.0);
        taps++;
    }

    float x = max(0.0, 1.0 - sum * intensity * (1.0 / taps));
    image.write(float4(x), coordinates);
}
