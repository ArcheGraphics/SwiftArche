//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"
#include "function_common.h"
#include "shader_common.h"

typedef struct {
    float4 POSITION [[attribute(Position)]];
    float2 TEXCOORD_0 [[attribute(UV_0)]];
} TextVertexIn;

struct TransformedTextVertex {
    float4 position [[ position ]];
    float2 texCoords;
};

vertex TransformedTextVertex vertex_text(const TextVertexIn in [[stage_in]],
                                        constant CameraData &u_camera [[buffer(5)]]) {
    TransformedTextVertex outVert;
    outVert.position = u_camera.u_VPMat * in.POSITION;
    outVert.texCoords = in.TEXCOORD_0;
    return outVert;
}

fragment half4 fragment_text(TransformedTextVertex vert [[ stage_in ]],
                            constant float4& color [[ buffer(0) ]],
                            sampler sampler [[ sampler(0) ]],
                            texture2d<float, access::sample> texture [[ texture(0) ]]) {
    // Outline of glyph is the isocontour with value 50%.
    float edgeDistance = 0.5;
    // Sample the signed-distance field to find distance from this fragment to the glyph outline.
    float sampleDistance = texture.sample(sampler, vert.texCoords).r;
    // Use local automatic gradients to find anti-aliased anisotropic edge width, cf. Gustavson 2012.
    float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
    // Smooth the glyph edge by interpolating across the boundary in a band with the width determined above.
    float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
    return half4(color.r, color.g, color.b, insideness);
}
