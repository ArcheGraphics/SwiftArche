//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

// Calculates a slice of a depth pyramid from a higher resolution slice.
//  Handles downsampling from odd sized depth textures.
kernel void depthPyramid(depth2d<float, access::sample> inDepth        [[texture(0)]],
                         texture2d<float, access::write> outDepth      [[texture(1)]],
                         constant uint4& inputRect                     [[buffer(XBufferIndexDepthPyramidSize)]],
                         uint2 tid                                     [[thread_position_in_grid]])
{
    constexpr sampler sam (min_filter::nearest, mag_filter::nearest, coord::pixel);
    uint source_width   = inputRect.x;
    uint source_height  = inputRect.y;
    float2 src          = float2(tid * 2 + inputRect.zw);

    float minval        = inDepth.sample(sam, src);
    minval              = max(minval, inDepth.sample(sam, src + float2(0, 1)));
    minval              = max(minval, inDepth.sample(sam, src + float2(1, 0)));
    minval              = max(minval, inDepth.sample(sam, src + float2(1, 1)));
    bool edge_x         = (tid.x * 2 == source_width - 3);
    bool edge_y         = (tid.y * 2 == source_height - 3);

    if (edge_x)
    {
        minval = max(minval, inDepth.sample(sam, src + float2(2, 0)));
        minval = max(minval, inDepth.sample(sam, src + float2(2, 1)));
    }
    if (edge_y)
    {
        minval = max(minval, inDepth.sample(sam, src + float2(0, 2)));
        minval = max(minval, inDepth.sample(sam, src + float2(1, 2)));
    }
    if (edge_x && edge_y) minval = max(minval, inDepth.sample(sam, src + float2(2, 2)));

    outDepth.write(float4(minval), tid);
}
