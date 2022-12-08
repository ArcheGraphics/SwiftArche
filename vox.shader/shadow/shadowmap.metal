//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "../function_constant.h"
#include "../function_common.h"
#include "../shader_common.h"

typedef struct {
    float4 position [[position]];
} VertexOut;

float3 applyShadowBias(float3 positionWS, float3 u_lightDirection, float2 u_shadowBias) {
    positionWS -= u_lightDirection * u_shadowBias.x;
    return positionWS;
}

float3 applyShadowNormalBias(float3 positionWS, float3 normalWS, float3 u_lightDirection, float2 u_shadowBias) {
    float invNdotL = 1.0 - clamp(dot(-u_lightDirection, normalWS), 0.0, 1.0);
    float scale = invNdotL * u_shadowBias.y;
    positionWS += normalWS * float3(scale);
    return positionWS;
}

vertex VertexOut vertex_shadowmap(const VertexIn in [[stage_in]],
                                  uint v_id [[vertex_id]],
                                  constant RendererData &u_renderer [[buffer(2)]],
                                  constant matrix_float4x4 &u_lightViewProjMat [[buffer(3)]],
                                  constant float4 &u_tilingOffset [[buffer(4)]],
                                  constant float2 &u_shadowBias [[buffer(5)]],
                                  constant float3 &u_lightDirection [[buffer(6)]],
                                  // skin
                                  texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                                  sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                                  constant int &u_jointCount [[buffer(5), function_constant(hasSkinAndHasJointTexture)]],
                                  constant matrix_float4x4 *u_jointMatrix [[buffer(16), function_constant(hasSkinNotHasJointTexture)]],
                                  // morph
                                  texture2d_array<float> u_blendShapeTexture [[texture(1), function_constant(hasBlendShape)]],
                                  sampler u_blendShapeSampler [[sampler(1), function_constant(hasBlendShape)]],
                                  constant int3 &u_blendShapeTextureInfo [[buffer(7), function_constant(hasBlendShape)]],
                                  constant float *u_blendShapeWeights [[buffer(8), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.POSITION, 1.0);
    float3 normal;
    if (!omitNormal && hasNormal) {
        normal = in.NORMAL;
    }
    
    //blendshape
    if (hasBlendShape) {
        int vertexOffset = v_id * u_blendShapeTextureInfo.x;
        for(int i = 0; i < blendShapeCount; i++){
            int vertexElementOffset = vertexOffset;
            float weight = u_blendShapeWeights[i];
            position.xyz += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
            
            if (!omitNormal && hasNormal && hasBlendShapeNormal) {
                vertexElementOffset += 1;
                normal += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
            }
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
        
        if (hasNormal && !omitNormal) {
            matrix_float3x3 skinNormalMatrix = inverse(matrix_float3x3(skinMatrix[0][0], skinMatrix[0][1], skinMatrix[0][2],
                                                                       skinMatrix[1][0], skinMatrix[1][1], skinMatrix[1][2],
                                                                       skinMatrix[2][0], skinMatrix[2][1], skinMatrix[2][2]));
            normal = normal * skinNormalMatrix;
        }
    }
    
    float4 positionWS = u_renderer.u_modelMat * position;

    positionWS.xyz = applyShadowBias(positionWS.xyz, u_lightDirection, u_shadowBias);
    if (!omitNormal && hasNormal) {
        float3 v_normal = normalize(matrix_float3x3(u_renderer.u_normalMat[0][0], u_renderer.u_normalMat[0][1], u_renderer.u_normalMat[0][2],
                                                    u_renderer.u_normalMat[1][0], u_renderer.u_normalMat[1][1], u_renderer.u_normalMat[1][2],
                                                    u_renderer.u_normalMat[2][0], u_renderer.u_normalMat[2][1], u_renderer.u_normalMat[2][2]) * normal);
        positionWS.xyz = applyShadowNormalBias(positionWS.xyz, v_normal, u_lightDirection, u_shadowBias);
    }
    
    out.position = u_lightViewProjMat * positionWS;
    out.position.z = max(out.position.z, 0.0);// clamp to min ndc z
    return out;
}
