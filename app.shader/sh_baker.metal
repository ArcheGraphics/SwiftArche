//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

class SHBaker {
public:
    SHBaker(device atomic_float* sh):sh(sh) {}
    
    void addLight(const float3 direction, const float4 c, float delta_solid_angle) {
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
         */
        
        auto color = c * delta_solid_angle;
        
        const float kBv0 = 0.282095f;                                                            // basis0 = 0.886227
        const float kBv1 = -0.488603f * direction.y;                                             // basis1 = -0.488603
        const float kBv2 = 0.488603f * direction.z;                                              // basis2 = 0.488603
        const float kBv3 = -0.488603f * direction.x;                                             // basis3 = -0.488603
        const float kBv4 = 1.092548f * (direction.x * direction.y);                              // basis4 = 1.092548
        const float kBv5 = -1.092548f * (direction.y * direction.z);                             // basis5 = -1.092548
        const float kBv6 = 0.315392f * (3 * direction.z * direction.z - 1);                      // basis6 = 0.315392
        const float kBv7 = -1.092548f * (direction.x * direction.z);                             // basis7 = -1.092548
        const float kBv8 = 0.546274f * (direction.x * direction.x - direction.y * direction.y);  // basis8 = 0.546274
        
        atomic_fetch_add_explicit(&sh[0], color.r * kBv0, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[1], color.g * kBv0, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[2], color.b * kBv0, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[3], color.r * kBv1, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[4], color.g * kBv1, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[5], color.b * kBv1, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[6], color.r * kBv2, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[7], color.g * kBv2, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[8], color.b * kBv2, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[9], color.r * kBv3, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[10], color.g * kBv3, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[11], color.b * kBv3, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[12], color.r * kBv4, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[13], color.g * kBv4, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[14], color.b * kBv4, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[15], color.r * kBv5, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[16], color.g * kBv5, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[17], color.b * kBv5, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[18], color.r * kBv6, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[19], color.g * kBv6, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[20], color.b * kBv6, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[21], color.r * kBv7, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[22], color.g * kBv7, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[23], color.b * kBv7, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[24], color.r * kBv8, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[25], color.g * kBv8, memory_order::memory_order_relaxed);
        atomic_fetch_add_explicit(&sh[26], color.b * kBv8, memory_order::memory_order_relaxed);
    }
    
    
public:
    device atomic_float* sh;
};

kernel void compute_sh(texturecube<float, access::sample> input [[ texture(0) ]],
                       device atomic_float* u_sh [[buffer(0)]],
                       uint3 tpig [[ thread_position_in_grid ]]) {
    SHBaker baker(u_sh);
    
    float inputWidth = input.get_width();
    uint face = tpig.z;
    float2 inputuv = float2(tpig.xy) / inputWidth;

    float u = 2.0 * inputuv.x - 1.0;
    float v = -2.0 * inputuv.y + 1.0;

    float3 dir;
    switch(face) {
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
    
    constexpr sampler s(mip_filter::linear, filter::linear);
    auto color = input.sample(s, dir);
    
    float solid_angle = 4.f / (length(dir) * length_squared(dir));
    baker.addLight(normalize(dir), color, solid_angle);
    atomic_fetch_add_explicit(&u_sh[27], solid_angle, memory_order::memory_order_relaxed);
}
