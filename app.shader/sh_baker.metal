//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void compute_sh(texturecube<float, access::sample> input [[ texture(0) ]],
                       device atomic_float* u_sh [[buffer(0)]],
                       uint3 tpig [[ thread_position_in_grid ]]) {
    constexpr sampler s(mip_filter::linear, filter::linear);
    float inputWidth = input.get_width();
    
    float3 totalRadiance = float3(0);
    float totalSolidAngle = 0;
    for (int i = 0; i < inputWidth; i++) {
        for (int j = 0; j < inputWidth; j++) {
            float2 inputuv = float2(i, j) / inputWidth;
            float u = 2.0 * inputuv.x - 1.0;
            float v = -2.0 * inputuv.y + 1.0;
            
            // color sample
            float3 dir;
            switch(tpig.y) {
                case 0:
                    dir = float3(1.0, v, -u);
                    break;
                case 1:
                    dir = float3(-1.0, v, u);
                    break;
                case 2:
                    dir = float3(u, 1.0, -v);
                    break;
                case 3:
                    dir = float3(u, -1.0, v);
                    break;
                case 4:
                    dir = float3(u, v, 1.0);
                    break;
                case 5:
                    dir = float3(-u, v, -1.0);
                    break;
            }
            auto color = input.sample(s, dir).rgb;
            /**
             * dA = cos = S / r = 4 / r
             * dw = dA / r2 = 4 / r / r2
             */
            float solid_angle = 4.f / (length(dir) * length_squared(dir));
            totalSolidAngle += solid_angle;
            dir = normalize(dir);
            
            /**
             * Implements `EvalSHBasis` from [Projection from Cube maps] in http://www.ppsloan.org/publications/StupidSH36.pdf.
             *
             * Basis constants
             * 0: std::sqrt(1/(4 * M_PI_F))
             *
             * 1: -std::sqrt(3 / (4 * M_PI_F))
             * 2: std::sqrt(3 / (4 * M_PI_F))
             * 3: -std::sqrt(3 / (4 * M_PI_F))
             *
             * 4: std::sqrt(15 / (4 * M_PI_F))
             * 5: -std::sqrt(15 / (4 * M_PI_F))
             * 6: std::sqrt(5 / (16 * M_PI_F))
             * 7: -std::sqrt(15 / (4 * M_PI_F)）
             * 8: std::sqrt(15 / (16 * M_PI_F))
             *
             * Convolution kernel
             * 0: M_PI_F
             * 1: (2 * M_PI_F) / 3
             * 2: M_PI_F / 4
             */
            float param = 0;
            switch(tpig.x) {
                case 0:
                    param = 0.282095f * 0.886227;
                    break;
                case 1:
                    param = -0.488603f * dir.y * -1.023327;
                    break;
                case 2:
                    param = 0.488603f * dir.z * 1.023327;
                    break;
                case 3:
                    param = -0.488603f * dir.x * -1.023327;
                    break;
                case 4:
                    param = 1.092548f * (dir.x * dir.y) * 0.858086;
                    break;
                case 5:
                    param = -1.092548f * (dir.y * dir.z) * -0.858086;
                    break;
                case 6:
                    param = 0.315392f * (3 * dir.z * dir.z - 1) * 0.247708;
                    break;
                case 7:
                    param = -1.092548f * (dir.x * dir.z) * -0.858086;
                    break;
                case 8:
                    param = 0.546274f * (dir.x * dir.x - dir.y * dir.y) * 0.429042;
                    break;
            }
            param *= 4 * M_PI_F;
            totalRadiance += color * solid_angle * param;
        }
    }
    
    atomic_fetch_add_explicit(&u_sh[tpig.x * 3], totalRadiance.x, memory_order::memory_order_relaxed);
    atomic_fetch_add_explicit(&u_sh[tpig.x * 3 + 1], totalRadiance.y, memory_order::memory_order_relaxed);
    atomic_fetch_add_explicit(&u_sh[tpig.x * 3 + 2], totalRadiance.z, memory_order::memory_order_relaxed);
    if (tpig.x == 0) {
        atomic_fetch_add_explicit(&u_sh[27], totalSolidAngle, memory_order::memory_order_relaxed);
    }
}
