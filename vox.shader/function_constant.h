//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;
#import "macro_name.h"

constant bool hasUV [[function_constant(HAS_UV)]];
constant bool hasNormal [[function_constant(HAS_NORMAL)]];
constant bool hasTangent [[function_constant(HAS_TANGENT)]];
constant bool hasVertexColor [[function_constant(HAS_VERTEXCOLOR)]];
constant bool omitNormal [[function_constant(OMIT_NORMAL)]];
constant bool notOmitNormalAndHasNormal = !omitNormal && hasNormal;
constant bool notOmitNormalAndHasTangent = !omitNormal && hasTangent;

constant bool hasBlendShape [[function_constant(HAS_BLENDSHAPE)]];
constant int blendShapeCount [[function_constant(BLENDSHAPE_COUNT)]];
constant bool hasBlendShapeNormal [[function_constant(HAS_BLENDSHAPE_NORMAL)]];
constant bool hasBlendShapeTangent [[function_constant(HAS_BLENDSHAPE_TANGENT)]];

constant bool hasSkin [[function_constant(HAS_SKIN)]];
constant bool hasJointTexture [[function_constant(HAS_JOINT_TEXTURE)]];
constant bool hasSkinAndHasJointTexture = hasSkin && hasJointTexture;
constant bool hasSkinNotHasJointTexture = hasSkin && !hasJointTexture;
constant int jointsCount [[function_constant(JOINTS_COUNT)]];

constant bool needAlphaCutoff [[function_constant(NEED_ALPHA_CUTOFF)]];
constant bool needWorldPos [[function_constant(NEED_WORLDPOS)]];
constant bool needTilingOffset [[function_constant(NEED_TILINGOFFSET)]];
constant bool hasNormalTexture [[function_constant(HAS_NORMAL_TEXTURE)]];
constant bool hasNormalAndHasTangentAndHasNormalTexture = hasNormal && hasTangent && hasNormalTexture;
constant bool hasNormalNotHasTangentOrHasNormalTexture = hasNormal && (!hasTangent || !hasNormalTexture);

constant bool hasBaseTexture [[function_constant(HAS_BASE_TEXTURE)]];
constant bool hasEmissiveTexture [[function_constant(HAS_EMISSIVE_TEXTURE)]];
constant bool hasOcclusionTexture [[function_constant(HAS_OCCLUSION_TEXTURE)]];
constant bool hasClearCoatTexture [[function_constant(HAS_CLEARCOAT_TEXTURE)]];
constant bool hasClearCoatRoughnessTexture [[function_constant(HAS_CLEARCOAT_ROUGHNESS_TEXTURE)]];
constant bool hasSpecularGlossinessTexture [[function_constant(HAS_SPECULAR_GLOSSINESS_TEXTURE)]];
constant bool hasRoughnessMetallicTexture [[function_constant(HAS_ROUGHNESS_METALLIC_TEXTURE)]];
constant bool hasSpecularTexture [[function_constant(HAS_SPECULAR_TEXTURE)]];
constant bool isMetallicWorkFlow [[function_constant(IS_METALLIC_WORKFLOW)]];
constant bool isClearCoat [[function_constant(IS_CLEARCOAT)]];

constant int directLightCount [[function_constant(DIRECT_LIGHT_COUNT)]];
constant bool hasDirectLight = directLightCount > 0;
constant int pointLightCount [[function_constant(POINT_LIGHT_COUNT)]];
constant bool hasPointLight = pointLightCount > 0;
constant int spotLightCount [[function_constant(SPOT_LIGHT_COUNT)]];
constant bool hasSpotLight = spotLightCount > 0;

constant bool hasSH [[function_constant(HAS_SH)]];
constant bool hasSpecularEnv [[function_constant(HAS_SPECULAR_ENV)]];

constant bool needReceiveShadow [[function_constant(NEED_RECEIVE_SHADOWS)]];
