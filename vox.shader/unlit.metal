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
                              constant matrix_float4x4 &u_MVPMat [[buffer(7)]],
                              constant float4 &u_tilingOffset [[buffer(8)]],
                              sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                              texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                              constant int &u_jointCount [[buffer(11), function_constant(hasSkinAndHasJointTexture)]],
                              constant matrix_float4x4 *u_jointMatrix [[buffer(12), function_constant(hasSkinNotHasJointTexture)]],
                              constant float *u_blendShapeWeights [[buffer(13), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.POSITION, 1.0);
    
    //blendshape
    if (hasBlendShape) {
        position.xyz += in.POSITION_BS0 * u_blendShapeWeights[0];
        position.xyz += in.POSITION_BS1 * u_blendShapeWeights[1];
        position.xyz += in.POSITION_BS2 * u_blendShapeWeights[2];
        position.xyz += in.POSITION_BS3 * u_blendShapeWeights[3];
    }
    
    //skinning
    if (hasSkin) {
        matrix_float4x4 skinMatrix;
        if (hasJointTexture) {
            skinMatrix =
            in.WEIGHTS_0.x * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.x, u_jointCount) +
            in.WEIGHTS_0.y * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.y, u_jointCount) +
            in.WEIGHTS_0.z * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.z, u_jointCount) +
            in.WEIGHTS_0.w * getJointMatrix(u_jointSampler, u_jointTexture, in.JOINTS_0.w, u_jointCount);
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
                               texture2d<float> u_baseTexture [[texture(0), function_constant(hasBaseTexture)]]) {
    constexpr sampler textureSampler(coord::normalized, filter::linear,
                                     address::repeat, compare_func:: less);
    
    float4 baseColor = u_baseColor;
    
    if (hasBaseTexture) {
        baseColor *= u_baseTexture.sample(textureSampler, in.v_uv);
    }
    
    if (needAlphaCutoff) {
        if( baseColor.a < u_alphaCutoff ) {
            discard_fragment();
        }
    }
    
    return baseColor;
}


