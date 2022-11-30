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
    HAS_UV =                             65535,
    HAS_NORMAL =                         65534,
    HAS_TANGENT =                        65533,
    HAS_VERTEXCOLOR =                    65532,

    // Blend Shape
    HAS_BLENDSHAPE =                     65531,
    BLENDSHAPE_COUNT =                   65530,
    HAS_BLENDSHAPE_NORMAL =              65529,
    HAS_BLENDSHAPE_TANGENT =             65528,
     
    // Skin
    HAS_SKIN =                           65527,
    HAS_JOINT_TEXTURE =                  65526,
    JOINTS_COUNT =                       65525,

    // Material
    NEED_ALPHA_CUTOFF =                  65524,
    NEED_WORLDPOS =                      65523,
    NEED_TILINGOFFSET =                  65522,

    OMIT_NORMAL =                        65521,
    HAS_NORMAL_TEXTURE =                 65520,
    HAS_BASE_TEXTURE =                   65519,
    HAS_EMISSIVE_TEXTURE =               65518,
    HAS_OCCLUSION_TEXTURE =              65517,
    HAS_CLEARCOAT_TEXTURE =              65516,
    HAS_CLEARCOAT_ROUGHNESS_TEXTURE =    65515,
    HAS_CLEARCOAT_NORMAL_TEXTURE =       65514,
    HAS_SPECULAR_GLOSSINESS_TEXTURE =    65513,
    HAS_ROUGHNESS_METALLIC_TEXTURE =     65512,
    IS_METALLIC_WORKFLOW =               65511,
    IS_CLEARCOAT =                       65510,
    HAS_SPECULAR_TEXTURE =               65509,

    // Light
    DIRECT_LIGHT_COUNT =                 65508,
    POINT_LIGHT_COUNT =                  65507,
    SPOT_LIGHT_COUNT =                   65506,

    // Enviroment
    HAS_SH =                             65505,
    HAS_SPECULAR_ENV =                   65504,
    DECODE_ENV_RGBM =                    65503,

    // Shadow
    NEED_RECEIVE_SHADOWS =               65502,
    CASCADED_COUNT =                     65501,
    CASCADED_SHADOW_MAP =                65500,
    SHADOW_MODE =                        65499
} MacroName;
