//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void gamma_correction(texture2d<float, access::read> framebufferInput [[ texture(0) ]],
                             texture2d<float, access::write> framebufferOutput [[ texture(1) ]],
                             uint3 tpig [[ thread_position_in_grid ]]) {
    float4 color = framebufferInput.read(tpig.xy);
    framebufferOutput.write(float4(pow(color.rgb, float3(1.0 / 2.2)), color.a), tpig.xy);
}
