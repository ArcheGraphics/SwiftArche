//   Copyright (c) 2022 Feng Yang
//
//   I am making my contributions/submissions to this project solely in my
//   personal capacity and am not conveying any rights to any intellectual
//   property of any third parties.

#pragma once

// int have no verb, other will use:
// HAS_ : Resouce
// OMMIT_ : Omit Resouce
// NEED_ : Shader Operation
// IS_ : Shader control flow
// _COUNT: type int constant
typedef enum {
    HAS_UV = 0,
    HAS_NORMAL = 1,
    HAS_TANGENT = 2,
    HAS_VERTEXCOLOR = 3,

    // Blend Shape
    HAS_BLENDSHAPE = 4,
    BLENDSHAPE_COUNT = 5,
    HAS_BLENDSHAPE_NORMAL = 6,
    HAS_BLENDSHAPE_TANGENT = 7,
    
    // Skin
    HAS_SKIN = 8,
    HAS_JOINT_TEXTURE = 9,
    JOINTS_COUNT = 10,

    // Material
    NEED_ALPHA_CUTOFF = 11,
    NEED_WORLDPOS = 12,
    NEED_TILINGOFFSET = 13,

    OMIT_NORMAL = 14,
    HAS_NORMAL_TEXTURE = 15,
    HAS_BASE_TEXTURE = 16,
    HAS_EMISSIVE_TEXTURE = 17,
    HAS_OCCLUSION_TEXTURE = 18,
    HAS_CLEARCOAT_TEXTURE = 19,
    HAS_CLEARCOAT_ROUGHNESS_TEXTURE = 20,
    HAS_CLEARCOAT_NORMAL_TEXTURE = 21,
    HAS_SPECULAR_GLOSSINESS_TEXTURE = 22,
    HAS_ROUGHNESS_METALLIC_TEXTURE = 23,
    IS_METALLIC_WORKFLOW = 24,
    IS_CLEARCOAT = 25,
    HAS_SPECULAR_TEXTURE = 26,

    // Light
    DIRECT_LIGHT_COUNT = 27,
    POINT_LIGHT_COUNT = 28,
    SPOT_LIGHT_COUNT = 29,

    // Enviroment
    HAS_SH = 30,
    HAS_SPECULAR_ENV = 31,
    DECODE_ENV_RGBM = 32,

    // Shadow
    NEED_RECEIVE_SHADOWS = 33,
    CASCADED_COUNT = 34,
    CASCADED_SHADOW_MAP = 35,
    SHADOW_MODE = 36,

    TOTAL_COUNT = 37,
} MacroName;
