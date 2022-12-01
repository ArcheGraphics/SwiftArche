//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"
#include "../vox.shader/shader_common.h"

typedef struct {
    float4 position [[position]];
} VertexOut;

vertex VertexOut vertex_atomic(const VertexIn in [[stage_in]],
                               uint v_id [[vertex_id]],
                               constant CameraData &u_camera [[buffer(2)]],
                               constant RendererData &u_renderer [[buffer(3)]],
                               constant float4 &u_tilingOffset [[buffer(4)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.POSITION, 1.0);
    out.position = u_camera.u_VPMat * u_renderer.u_modelMat * position;
    
    return out;
}

fragment float4 fragment_atomic(VertexOut in [[stage_in]],
                                constant uint* u_atomic[[buffer(10)]]) {
    uint atomic = u_atomic[0] % 255;
    return float4(atomic/255.0, 1 - atomic/255.0, atomic/255.0, 1.0);
}

kernel void compute_atomic(device atomic_uint* u_atomic[[buffer(0)]],
                           uint3 position [[ thread_position_in_grid ]]) {
    //    atomic_store_explicit(counter, 0, memory_order::memory_order_relaxed);
    //    threadgroup_barrier(mem_flags::mem_device);
    atomic_fetch_add_explicit(u_atomic, 1, memory_order::memory_order_relaxed);
}
