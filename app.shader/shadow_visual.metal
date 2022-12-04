//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "function_constant.h"
#include "../vox.shader/function_common.h"
#include "../vox.shader/shader_common.h"

typedef struct {
    float4 position [[position]];
    float3 v_pos;
} VertexOut;

vertex VertexOut vertex_unlit(const VertexIn in [[stage_in]],
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

int computeCascadeIndex(float3 positionWS, constant float4* u_shadowSplitSpheres) {
    float3 fromCenter0 = positionWS - u_shadowSplitSpheres[0].xyz;
    float3 fromCenter1 = positionWS - u_shadowSplitSpheres[1].xyz;
    float3 fromCenter2 = positionWS - u_shadowSplitSpheres[2].xyz;
    float3 fromCenter3 = positionWS - u_shadowSplitSpheres[3].xyz;
    
    float4 comparison = float4(dot(fromCenter0, fromCenter0) < u_shadowSplitSpheres[0].w,
                               dot(fromCenter1, fromCenter1) < u_shadowSplitSpheres[1].w,
                               dot(fromCenter2, fromCenter2) < u_shadowSplitSpheres[2].w,
                               dot(fromCenter3, fromCenter3) < u_shadowSplitSpheres[3].w);
    comparison.yzw = clamp(comparison.yzw - comparison.xyz,0.0,1.0);//keep the nearest
    float4 indexCoefficient = float4(4.0,3.0,2.0,1.0);
    int index = 4 - int(dot(comparison, indexCoefficient));
    return index;
}

fragment float4 shadowMap_visual(VertexOut in [[stage_in]],
                                 constant float4 &u_baseColor [[buffer(0)]],
                                 constant float4* u_shadowSplitSpheres [[buffer(11), function_constant(needCalculateShadow)]]) {
    float4 baseColor = u_baseColor;
    
    if (needCalculateShadow) {
        int cascadeIndex = computeCascadeIndex(in.v_pos, u_shadowSplitSpheres);
        if (cascadeIndex == 0) {
            baseColor = float4(1.0, 1.0, 1.0, 1.0);
        } else if (cascadeIndex == 1) {
            baseColor = float4(1.0, 0.0, 0.0, 1.0);
        } else if (cascadeIndex == 2) {
            baseColor = float4(0.0, 1.0, 0.0, 1.0);
        } else if (cascadeIndex == 3) {
            baseColor = float4(0.0, 0.0, 1.0, 1.0);
        }
    }
    
    return baseColor;
}


