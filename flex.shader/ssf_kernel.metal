//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"

float bilateral(uint2 xy, texture2d<float, access::read> depth,
                int kernel_r, float blur_r, float blur_z) {
    float z = depth.read(xy).r;
    float sum = 0, wsum = 0;

    for(int dx = -kernel_r; dx <= kernel_r; dx++)
        for (int dy = -kernel_r; dy <= kernel_r; dy++) {
            float s = depth.read(xy + uint2(dx, dy)).r;

            float w = exp(- (dx*dx + dy*dy) * blur_r * blur_r);

            float r2 = (s - z) * blur_z;
            float g = exp(-r2 * r2);

            float wg = w * g;
            sum += s * wg;
            wsum += wg;
        }

    if (wsum > 0) sum /= wsum;
    return sum;
}

float gaussian(uint2 xy, texture2d<float, access::read> depth,
               int kernel_r, float blur_r) {
    float sum = 0, wsum = 0;

    for (int dx = -kernel_r; dx <= kernel_r; dx++)
        for (int dy = -kernel_r; dy <= kernel_r; dy++) {
            float s = depth.read(xy + uint2(dx, dy)).r;
            float w = exp(-(dx*dx + dy * dy) * blur_r * blur_r);

            sum += s * w;
            wsum += w;
        }

    if (wsum > 0) sum /= wsum;
    return sum;
}

kernel void ssf_smoothDepth(constant int& kernel_r [[buffer(1)]],
                            constant float& blur_r [[buffer(2)]],
                            constant float& blur_z [[buffer(3)]],
                            // output
                            texture2d<float, access::read> depthIn [[ texture(0) ]],
                            texture2d<float, access::write> depthOut [[texture(1)]],
                            uint3 tpig [[ thread_position_in_grid ]]) {
    float zz = bilateral(tpig.xy, depthIn, kernel_r, blur_r, blur_z);
    // float zz = gaussian(tpig.xy, depth, kernel_r, blur_r);
    depthOut.write(float4(zz, 0, 0, 0), tpig.xy);
}

kernel void ssf_restoreNormal(constant SSFData& u_ssf [[buffer(0)]],
                              // output
                              texture2d<float, access::sample> u_depthIn [[texture(1)]],
                              texture2d<float, access::write> u_normalDepthOut [[texture(2)]],
                              uint3 tpig [[ thread_position_in_grid ]],
                              uint3 gridSize [[threads_per_grid]]) {
    /* global */
    float f_x = u_ssf.p_n / u_ssf.p_r;
    float f_y = u_ssf.p_n / u_ssf.p_t;
    float c_x = 2 / (u_ssf.canvasWidth * f_x);
    float c_y = 2 / (u_ssf.canvasHeight * f_y);

    /* (x, y) in [0, 1] */
    float x = float(tpig.x) / gridSize.x, y = float(tpig.y) / gridSize.y;
    float dx = 1 / u_ssf.canvasWidth, dy = 1 / u_ssf.canvasHeight;
    
    constexpr sampler depthSampler(mip_filter::nearest,
                                   mag_filter::nearest,
                                   min_filter::nearest);
    float z = u_depthIn.sample(depthSampler, float2(x, y)).r;
    float dzdx = u_depthIn.sample(depthSampler, float2(x + dx, y)).r - z;
    float dzdy = u_depthIn.sample(depthSampler, float2(x, y + dy)).r - z;
    float dzdx2 = z - u_depthIn.sample(depthSampler, float2(x - dx, y)).r;
    float dzdy2 = z - u_depthIn.sample(depthSampler, float2(x, y - dy)).r;
    
    /* Skip silhouette */
    bool keep_edge = true;
    if (keep_edge) {
        if (abs(dzdx2) < abs(dzdx)) dzdx = dzdx2;
        if (abs(dzdy2) < abs(dzdy)) dzdy = dzdy2;
    }
    
    float3 n = float3(-c_y * dzdx, -c_x * dzdy, c_x*c_y*z);
    if (length(n) == 0) {
        u_normalDepthOut.write(float4(0, 0, 0, z), tpig.xy);
    } else {
        u_normalDepthOut.write(float4(normalize(n), z), tpig.xy);
    }
}
