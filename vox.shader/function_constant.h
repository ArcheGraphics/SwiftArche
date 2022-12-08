//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;
#import "macro_name.h"

#define DeclBoolMacro(NAME, INDEX) \
constant bool NAME##_decl [[function_constant(INDEX)]]; \
constant bool NAME = is_function_constant_defined(NAME##_decl) ? NAME##_decl : false;

#define DeclIntMacro(NAME, INDEX) \
constant int NAME##_decl [[function_constant(INDEX)]]; \
constant int NAME = is_function_constant_defined(NAME##_decl) ? NAME##_decl : 0;

//MARK: - Vertex
DeclBoolMacro(hasUV, HAS_UV)
DeclBoolMacro(hasNormal, HAS_NORMAL)
DeclBoolMacro(hasTangent, HAS_TANGENT)
DeclBoolMacro(hasVertexColor, HAS_VERTEXCOLOR)
DeclBoolMacro(omitNormal, OMIT_NORMAL)
constant bool notOmitNormalAndHasNormal = !omitNormal && hasNormal;
constant bool notOmitNormalAndHasTangent = !omitNormal && hasTangent;

//MARK: - Morph
DeclBoolMacro(hasBlendShape, HAS_BLENDSHAPE)
DeclIntMacro(blendShapeCount, BLENDSHAPE_COUNT)
DeclBoolMacro(hasBlendShapeNormal, HAS_BLENDSHAPE_NORMAL)
DeclBoolMacro(hasBlendShapeTangent, HAS_BLENDSHAPE_TANGENT)

//MARK: - Skin
DeclBoolMacro(hasSkin, HAS_SKIN)
DeclBoolMacro(hasJointTexture, HAS_JOINT_TEXTURE)
constant bool hasSkinAndHasJointTexture = hasSkin && hasJointTexture;
constant bool hasSkinNotHasJointTexture = hasSkin && !hasJointTexture;

//MARK: - Material
DeclBoolMacro(needAlphaCutoff, NEED_ALPHA_CUTOFF)
DeclBoolMacro(needWorldPos, NEED_WORLDPOS)
DeclBoolMacro(needTilingOffset, NEED_TILINGOFFSET)
DeclBoolMacro(hasNormalTexture, HAS_NORMAL_TEXTURE)
constant bool hasNormalAndHasTangentAndHasNormalTexture = hasNormal && hasTangent && hasNormalTexture;
constant bool hasNormalNotHasTangentOrHasNormalTexture = hasNormal && (!hasTangent || !hasNormalTexture);

DeclBoolMacro(hasBaseTexture, HAS_BASE_TEXTURE)
DeclBoolMacro(hasEmissiveTexture, HAS_EMISSIVE_TEXTURE)
DeclBoolMacro(hasOcclusionTexture, HAS_OCCLUSION_TEXTURE)
DeclBoolMacro(hasClearCoatTexture, HAS_CLEARCOAT_TEXTURE)
DeclBoolMacro(hasClearCoatRoughnessTexture, HAS_CLEARCOAT_ROUGHNESS_TEXTURE)
DeclBoolMacro(hasClearCoatNormalTexture, HAS_CLEARCOAT_NORMAL_TEXTURE)
DeclBoolMacro(hasSpecularGlossinessTexture, HAS_SPECULAR_GLOSSINESS_TEXTURE)
DeclBoolMacro(hasRoughnessMetallicTexture, HAS_ROUGHNESS_METALLIC_TEXTURE)

DeclBoolMacro(hasSpecularTexture, HAS_SPECULAR_TEXTURE)
DeclBoolMacro(isMetallicWorkFlow, IS_METALLIC_WORKFLOW)
DeclBoolMacro(isClearCoat, IS_CLEARCOAT);

//MARK: - Light
DeclIntMacro(directLightCount, DIRECT_LIGHT_COUNT);
constant bool hasDirectLight = directLightCount > 0;
DeclIntMacro(pointLightCount, POINT_LIGHT_COUNT);
constant bool hasPointLight = pointLightCount > 0;
DeclIntMacro(spotLightCount, SPOT_LIGHT_COUNT);
constant bool hasSpotLight = spotLightCount > 0;

DeclBoolMacro(hasSH, HAS_SH)
DeclBoolMacro(hasSpecularEnv, HAS_SPECULAR_ENV)

DeclBoolMacro(needReceiveShadow, NEED_RECEIVE_SHADOWS)
DeclIntMacro(cascadeCount, CASCADED_COUNT)
DeclBoolMacro(hasCascadeShadowMap, CASCADED_SHADOW_MAP)
DeclIntMacro(shadowMode, SHADOW_MODE)
constant bool needCalculateShadow = hasCascadeShadowMap && needReceiveShadow;

DeclIntMacro(fogMode, FOG_MODE)
constant bool hasFog = fogMode != 0;

DeclBoolMacro(isAutoExposure, IS_AUTO_EXPOSURE)
