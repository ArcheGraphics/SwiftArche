//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_sdf(uint v_id [[vertex_id]]) {
    VertexOut out;
    
    out.v_uv = float2((v_id << 1) & 2, v_id & 2);
    out.position = float4(out.v_uv * float2(2, -2) + float2(-1, 1), 0.5, 1);
    
    return out;
}

float max3(float x, float y, float z) {
    return max(x, max(y, z));
}

float min3(float x, float y, float z) {
    return min(x, min(y, z));
}

float2 intersectRayBox(float3 o, float3 d, float3 SDFLower, float3 SDFUpper) {
    float3 invD = 1 / d;
    float3 n = invD * (SDFLower - o);
    float3 f = invD * (SDFUpper - o);

    float3 minnf = min(n, f);
    float3 maxnf = max(n, f);

    float t0 = ::max3(minnf.x, minnf.y, minnf.z);
    float t1 = ::min3(maxnf.x, maxnf.y, maxnf.z);

    return float2(max(0.0f, t0), t1);
}


fragment float4 fragment_sdf(VertexOut in [[stage_in]],
                             constant SDFData& u_sdfData [[buffer(0)]],
                             sampler u_sdfSampler [[sampler(0)]],
                             texture3d<float> u_sdfTexture [[texture(0)]]) {
    float3 o = u_sdfData.Eye;
    float3 d = normalize(mix(
                             mix(u_sdfData.FrustumA, u_sdfData.FrustumB, in.v_uv.x),
                             mix(u_sdfData.FrustumC, u_sdfData.FrustumD, in.v_uv.x), in.v_uv.y));

    float2 incts = intersectRayBox(o, d, u_sdfData.SDFLower, u_sdfData.SDFUpper);
    if(incts.x >= incts.y)
        return float4(0, 0, 0, 1);

    float t = incts.x + 0.01;
    int i = 0;

    for(; i < u_sdfData.MaxTraceSteps; ++i) {
        float3 p = o + t * d;
        float3 uvw = (p - u_sdfData.SDFLower) / u_sdfData.SDFExtent;
        if(any(saturate(uvw) != uvw))
            break;

        float sdf = u_sdfTexture.sample(u_sdfSampler, uvw).r;
        float udf = abs(sdf);
        if(udf <= u_sdfData.AbsThreshold)
            break;

        t += udf;
    }

    float color = float(i) / (u_sdfData.MaxTraceSteps - 1);
    color = pow(color, 1 / 2.2);
    return float4(color, color, color, 1);
}
