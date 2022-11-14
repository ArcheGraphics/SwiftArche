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
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_unlit(const VertexIn in [[stage_in]],
                              uint v_id [[vertex_id]],
                              constant matrix_float4x4 &u_MVPMat [[buffer(3)]],
                              constant float4 &u_tilingOffset [[buffer(4)]],
                              // skin
                              texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                              constant int &u_jointCount [[buffer(5), function_constant(hasSkinAndHasJointTexture)]],
                              constant matrix_float4x4 *u_jointMatrix [[buffer(6), function_constant(hasSkinNotHasJointTexture)]],
                              // morph
                              texture2d_array<float> u_blendShapeTexture [[texture(1), function_constant(hasBlendShape)]],
                              constant int3 &u_blendShapeTextureInfo [[buffer(7), function_constant(hasBlendShape)]],
                              constant float *u_blendShapeWeights [[buffer(8), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.POSITION, 1.0);
    
    //blendshape
    if (hasBlendShape) {
        int vertexOffset = v_id * u_blendShapeTextureInfo.x;
        for(int i = 0; i < blendShapeCount; i++){
            int vertexElementOffset = vertexOffset;
            float weight = u_blendShapeWeights[i];
            position.xyz += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
        }
    }
    
    //skinning
    if (hasSkin) {
        matrix_float4x4 skinMatrix;
        if (hasJointTexture) {
            skinMatrix =
            in.WEIGHTS_0.x * getJointMatrix(u_jointTexture, in.JOINTS_0.x, u_jointCount) +
            in.WEIGHTS_0.y * getJointMatrix(u_jointTexture, in.JOINTS_0.y, u_jointCount) +
            in.WEIGHTS_0.z * getJointMatrix(u_jointTexture, in.JOINTS_0.z, u_jointCount) +
            in.WEIGHTS_0.w * getJointMatrix(u_jointTexture, in.JOINTS_0.w, u_jointCount);
        } else {
            skinMatrix =
            in.WEIGHTS_0.x * u_jointMatrix[int(in.JOINTS_0.x)] +
            in.WEIGHTS_0.y * u_jointMatrix[int(in.JOINTS_0.y)] +
            in.WEIGHTS_0.z * u_jointMatrix[int(in.JOINTS_0.z)] +
            in.WEIGHTS_0.w * u_jointMatrix[int(in.JOINTS_0.w)];
        }
        position = skinMatrix * position;
    }
    
    // uv
    if (hasUV) {
        out.v_uv = in.TEXCOORD_0;
    } else {
        out.v_uv = float2(0.0, 0.0);
    }
    if (needTilingOffset) {
        out.v_uv = out.v_uv * u_tilingOffset.xy + u_tilingOffset.zw;
    }
    
    out.position = u_MVPMat * position;
    
    return out;
}

fragment float4 fragment_unlit(VertexOut in [[stage_in]],
                               constant float4 &u_baseColor [[buffer(0)]],
                               constant float &u_alphaCutoff [[buffer(1)]],
                               sampler u_baseSampler [[sampler(0), function_constant(hasBaseTexture)]],
                               texture2d<float> u_baseTexture [[texture(0), function_constant(hasBaseTexture)]]) {
    float4 baseColor = u_baseColor;
    
    if (hasBaseTexture) {
        baseColor *= u_baseTexture.sample(u_baseSampler, in.v_uv);
    }
    
    if (needAlphaCutoff) {
        if( baseColor.a < u_alphaCutoff ) {
            discard_fragment();
        }
    }
    
    return baseColor;
}


