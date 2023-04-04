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
#include "arguments.h"

typedef struct {
    float4 position [[position]];
    float2 v_uv;
    float3 v_positionVS [[function_constant(hasFog)]];
} VertexOut;

vertex VertexOut vertex_unlit(const VertexIn in [[stage_in]],
                              uint v_id [[vertex_id]],
                              constant CameraData &u_camera [[buffer(2)]],
                              constant RendererData &u_renderer [[buffer(3)]],
                              constant BaseMaterial &u_baseMaterial [[buffer(4)]],
                              // skin
                              texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                              constant int &u_jointCount [[buffer(5), function_constant(hasSkinAndHasJointTexture)]],
                              constant matrix_float4x4 *u_jointMatrix [[buffer(6), function_constant(hasSkinNotHasJointTexture)]],
                              // morph
                              texture2d_array<float> u_blendShapeTexture [[texture(1), function_constant(hasBlendShape)]],
                              constant uint3 &u_blendShapeTextureInfo [[buffer(7), function_constant(hasBlendShape)]],
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
        out.v_uv = out.v_uv * u_baseMaterial.tilingOffset.xy + u_baseMaterial.tilingOffset.zw;
    }
    
    // fog
    if (hasFog) {
        out.v_positionVS = (u_camera.u_viewMat * u_renderer.u_modelMat * position).xyz;
    }
    
    out.position = u_camera.u_VPMat * u_renderer.u_modelMat * position;
    
    return out;
}

float computeFogIntensity(float fogDepth, FogData u_fog) {
    if (fogMode == 1) {
        // (end-z) / (end-start) = z * (-1/(end-start)) + (end/(end-start))
        return clamp(fogDepth * u_fog.params.x + u_fog.params.y, 0.0, 1.0);
    } else if (fogMode == 2) {
        // exp(-z * density) = exp2((-z * density)/ln(2)) = exp2(-z * density/ln(2))
        return  clamp(exp2(-fogDepth * u_fog.params.z), 0.0, 1.0);
    } else if (fogMode == 3) {
        // exp(-(z * density)^2) = exp2(-(z * density)^2/ln(2)) = exp2(-(z * density/sprt(ln(2)))^2)
        float factor = fogDepth * u_fog.params.w;
        return clamp(exp2(-factor * factor), 0.0, 1.0);
    }
    return 1.0;
}

fragment float4 fragment_unlit(VertexOut in [[stage_in]],
                               constant BaseMaterial& u_baseMaterial [[buffer(1)]],
                               constant UnlitMaterial& u_unlitMaterial [[buffer(2)]],
                               constant FogData &u_fog [[buffer(3), function_constant(hasFog)]]) {
    float4 baseColor = u_unlitMaterial.u_baseColor;
    
    if (hasBaseTexture) {
        baseColor *= u_unlitMaterial.u_baseTexture.sample(u_unlitMaterial.u_baseSampler, in.v_uv);
    }
    
    if (needAlphaCutoff) {
        if( baseColor.a < u_baseMaterial.alphaCutoff ) {
            discard_fragment();
        }
    }
    
    if (hasFog) {
        float fogIntensity = computeFogIntensity(length(in.v_positionVS), u_fog);
        baseColor.rgb = mix(u_fog.color.rgb, baseColor.rgb, fogIntensity);
    }
    
    return baseColor;
}
