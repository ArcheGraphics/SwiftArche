//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "normal_shading.h"
#include "function_constant.h"

float3 NormalShading::getNormal() {
    float3 normal;
    if (hasNormal) {
        normal = normalize(v_normal);
    } else {
        float3 pos_dx = dfdx(v_pos);
        float3 pos_dy = dfdy(v_pos);
        normal = normalize( cross(pos_dx, pos_dy) );
    }
    normal *= float(isFrontFacing) * 2.0 - 1.0;
    return normal;
}

float3 NormalShading::getNormalByNormalTexture(matrix_float3x3 tbn, texture2d<float> normalTexture,
                                               sampler s, float normalIntensity, float2 uv) {
    float3 normal = normalTexture.sample(s, uv).rgb;
    normal = normalize(tbn * ((2.0 * normal - 1.0) * float3(normalIntensity, normalIntensity, 1.0)));
    normal *= float(isFrontFacing) * 2.0 - 1.0;

    return normal;
}

matrix_float3x3 NormalShading::getTBN() {
    if (hasNormal && hasTangent && (hasNormalTexture || hasClearCoatTexture)) {
        return v_TBN;
    } else {
        float3 normal = getNormal();
        float3 position = v_pos;
        float2 uv = isFrontFacing? v_uv: -v_uv;
        
        // ref: http://www.thetenthplanet.de/archives/1180
        // get edge vectors of the pixel triangle
        float3 dp1 = dfdx(position);
        float3 dp2 = dfdy(position);
        float2 duv1 = dfdx(uv);
        float2 duv2 = dfdy(uv);

        // solve the linear system
        float3 dp2perp = cross(dp2, normal);
        float3 dp1perp = cross(normal, dp1);
        float3 tangent = dp2perp * duv1.x + dp1perp * duv2.x;
        float3 binormal = dp2perp * duv1.y + dp1perp * duv2.y;

        // construct a scale-invariant frame
        float invmax = rsqrt(max(dot(tangent, tangent), dot(binormal, binormal)));
        return matrix_float3x3(tangent * invmax, binormal * invmax, normal);
    }
}
