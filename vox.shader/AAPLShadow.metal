//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

// Include header shared between this Metal shader code and C code executing Metal API commands
#include "AAPLShaderTypes.h"

struct ShadowOutput
{
    float4 position [[position]];
};

vertex ShadowOutput shadow_vertex(const device AAPLShadowVertex * positions [[ buffer(AAPLBufferIndexMeshPositions) ]],
                                  constant     AAPLFrameData    & frameData [[ buffer(AAPLBufferFrameData) ]],
                                  uint                            vid       [[ vertex_id ]])
{
    ShadowOutput out;

    // Add vertex pos to fairy position and project to clip-space
    out.position = frameData.shadow_mvp_matrix * float4(positions[vid].position, 1.0);

    return out;
}
