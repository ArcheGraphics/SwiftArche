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
#include "shadow_shading.h"

typedef struct {
    float4 position [[position]];
    float3 v_pos;
} VertexOut;

vertex VertexOut vertex_unlit_worldPos(const VertexIn in [[stage_in]],
                                       uint v_id [[vertex_id]],
                                       constant CameraData &u_camera [[buffer(2)]],
                                       constant RendererData &u_renderer [[buffer(3)]],
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
    
    float4 temp = u_renderer.u_modelMat * position;
    out.v_pos = temp.xyz / temp.w;
    out.position = u_camera.u_VPMat * u_renderer.u_modelMat * position;
    
    return out;
}


fragment float4 fragment_transparent_shadow(VertexOut in [[stage_in]],
                                            constant float4 &u_baseColor [[buffer(0)]],
                                            constant float4* u_shadowSplitSpheres [[buffer(11), function_constant(needCalculateShadow)]],
                                            constant matrix_float4x4* u_shadowMatrices [[buffer(12), function_constant(needCalculateShadow)]],
                                            constant float4 &u_shadowMapSize [[buffer(13), function_constant(needCalculateShadow)]],
                                            constant float3 &u_shadowInfo [[buffer(14), function_constant(needCalculateShadow)]],
                                            depth2d<float> u_shadowMap [[texture(11), function_constant(needCalculateShadow)]],
                                            sampler u_shadowMapSampler [[sampler(11), function_constant(needCalculateShadow)]]) {
    float4 baseColor = u_baseColor;
    
    float shadowAttenuation = 1.0;
    if (needCalculateShadow) {
        auto shadowShading = ShadowShading();
        shadowShading.v_pos = in.v_pos;
        shadowShading.u_shadowMap = u_shadowMap;
        shadowShading.u_shadowMapSampler = u_shadowMapSampler;
        shadowShading.u_shadowInfo = u_shadowInfo;
        shadowShading.u_shadowMapSize = u_shadowMapSize;
        shadowShading.u_shadowMatrices = u_shadowMatrices;
        shadowShading.u_shadowSplitSpheres = u_shadowSplitSpheres;
        shadowAttenuation *= shadowShading.sampleShadowMap();
    }
    
    return float4(baseColor.rgb, saturate(1.0 - shadowAttenuation) * baseColor.a);
}
