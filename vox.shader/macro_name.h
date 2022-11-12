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
    HAS_BLENDSHAPE_NORMAL = 5,
    HAS_BLENDSHAPE_TANGENT = 6,

    // Skin
    HAS_SKIN = 7,
    HAS_JOINT_TEXTURE = 8,
    JOINTS_COUNT = 9,

    // Material
    NEED_ALPHA_CUTOFF = 10,
    NEED_WORLDPOS = 11,
    NEED_TILINGOFFSET = 12,

    OMIT_NORMAL = 13,
    HAS_NORMAL_TEXTURE = 14,
    HAS_BASE_TEXTURE = 15,
    HAS_EMISSIVE_TEXTURE = 16,
    HAS_OCCLUSION_TEXTURE = 17,
    HAS_CLEARCOAT_TEXTURE = 18,
    HAS_CLEARCOAT_ROUGHNESS_TEXTURE = 19,
    HAS_CLEARCOAT_NORMAL_TEXTURE = 20,
    HAS_SPECULAR_GLOSSINESS_TEXTURE = 21,
    HAS_ROUGHNESS_METALLIC_TEXTURE = 22,
    IS_METALLIC_WORKFLOW = 23,
    IS_CLEARCOAT = 24,
    HAS_SPECULAR_TEXTURE = 25,

    // Light
    DIRECT_LIGHT_COUNT = 27,
    POINT_LIGHT_COUNT = 28,
    SPOT_LIGHT_COUNT = 29,

    // Enviroment
    HAS_SH = 30,
    HAS_SPECULAR_ENV = 31,

    // Particle Render
    HAS_PARTICLE_TEXTURE = 32,
    NEED_ROTATE_TO_VELOCITY = 33,
    NEED_USE_ORIGIN_COLOR = 34,
    NEED_SCALE_BY_LIFE_TIME = 35,
    NEED_FADE_IN = 36,
    NEED_FADE_OUT = 37,
    IS_2D = 38,

    // Shadow
    NEED_GENERATE_SHADOW_MAP = 39,
    SHADOW_MAP_COUNT = 40,

    TOTAL_COUNT = 41,
} MacroName;
