//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <TargetConditionals.h>

//MARK:- Config Enables ---------------------------------------------------------------------------------

#define SUPPORT_MATERIAL_UPDATES                         (1)

#define USE_TEXTURE_STREAMING                            (1 && SUPPORT_MATERIAL_UPDATES)

#define SUPPORT_SPARSE_TEXTURES                          (1 && USE_TEXTURE_STREAMING)

#define SUPPORT_PAGE_ACCESS_COUNTERS                     (1 && SUPPORT_SPARSE_TEXTURES)

#define ENABLE_DEBUG_RENDERING                           (1)

#define SUPPORT_RASTERIZATION_RATE                       (1)

#define USE_RESOLVE_PASS                                 (1)

#define SUPPORT_TEMPORAL_ANTIALIASING                    (1 && USE_RESOLVE_PASS)

// High level flag to enable SAO.
#define USE_SCALABLE_AMBIENT_OBSCURANCE                  (1)

// Enable use of local lights in the scene.  When disabled, only the sun used.
#define USE_LOCAL_LIGHTS                                 (1)

// High level flag to enable the scatter volume.
#define USE_SCATTERING_VOLUME                            (1)

// Local lights contribute to the scattering volume.
#define LOCAL_LIGHT_SCATTERING                           (1 && USE_SCATTERING_VOLUME && USE_LOCAL_LIGHTS)

// Support using tile shaders for depth prepass on Apple Silicon.
#define SUPPORT_DEPTH_PREPASS_TILE_SHADERS               (1)

// Support using tile shaders for light culling on Apple Silicon.
#define SUPPORT_LIGHT_CULLING_TILE_SHADERS               (1 && SUPPORT_DEPTH_PREPASS_TILE_SHADERS)

// Uses tile shaders to downsample depth from the imageblock.
#define SUPPORT_DEPTH_DOWNSAMPLE_TILE_SHADER             (1 && SUPPORT_LIGHT_CULLING_TILE_SHADERS)

// Uses tile shaders to perform light clustering.
#define SUPPORT_LIGHT_CLUSTERING_TILE_SHADER             (1 && SUPPORT_LIGHT_CULLING_TILE_SHADERS)

// Enable code to perform deferred lighting in a single render pass using programable blending.
#define SUPPORT_SINGLE_PASS_DEFERRED                     (1)

// Enables the reset and optimization of command buffers after they are generated.
#define OPTIMIZE_COMMAND_BUFFERS                         (1)

#define RENDER_SHADOWS                                   (1)

// Create shadows for each spotlight. Created on the first frame and cached.
#define USE_SPOT_LIGHT_SHADOWS                           (1 && RENDER_SHADOWS)

// Enables use of vertex amplification to render to entire shadow cascade set in one encoder.
#define SUPPORT_SINGLE_PASS_CSM_GENERATION               (1 && RENDER_SHADOWS)

// Enables culling to generate an ICB that represents the difference between cascade 2 from cascade 1.
// Cascade 1 amplified to cascade 2, and only the difference ICB rendered to cascade 2.
#define SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION (1 && SUPPORT_SINGLE_PASS_CSM_GENERATION)

// Enables an onscrren menu.
#define SUPPORT_ON_SCREEN_SETTINGS                       (1 && TARGET_OS_IPHONE)


//MARK:- Config Constants --------------------------------------------------------------------------------

// Use Equal depth test when rendering GBuffer after depth prepass.
// Noticeable win on traditional GPUs
#define USE_EQUAL_DEPTH_TEST                (1)

#define MAX_FRAMES_IN_FLIGHT                (3)

#define TAA_JITTER_COUNT                    (8)

#define MAX_ANISOTROPY                      (10)

#define ALPHA_CUTOUT                        (0.1f)

// Size of tiles for depth bounds calculation in tile shaders.
#define TILE_DEPTH_BOUNDS_DISPATCH_SIZE     (8)

// Flag to indicate that this light is included in scattering and affects transparencies.
// Lights are culled without limiting to the opaque depth range in the tile.
#define LIGHT_FOR_TRANSPARENT_FLAG          (0x00000001)

#define LIGHT_CLUSTER_RANGE                 (100.0f)

// The maximum number of lights in a tile.
#define MAX_LIGHTS_PER_TILE                 (64)

#define MAX_LIGHTS_PER_CLUSTER              (16)

#define LIGHT_CLUSTER_DEPTH                 (64)

// The number of shadow cascades for the sun light.
#define SHADOW_CASCADE_COUNT                (3)


#if USE_SPOT_LIGHT_SHADOWS

#   define SPOT_SHADOW_MAX_COUNT            (32)

#   define SPOT_SHADOW_DEPTH_BIAS           (0.001f)

#endif


#if SUPPORT_DEPTH_PREPASS_TILE_SHADERS

#   define TILE_SHADER_DIMENSION            (16)

#   define TILE_SHADER_WIDTH                (TILE_SHADER_DIMENSION)

#   define TILE_SHADER_HEIGHT               (TILE_SHADER_DIMENSION)

#endif


#if SUPPORT_LIGHT_CULLING_TILE_SHADERS

// Light culling tile size for Apple Silicon devices.
#   define TBDR_LIGHT_CULLING_TILE_SIZE     (TILE_SHADER_DIMENSION)

// Light culling tile size for AMD and Intel devices.
#   define DEFAULT_LIGHT_CULLING_TILE_SIZE  (32)

#endif


#if USE_TEXTURE_STREAMING

#   define TEXTURE_HEAP_SIZE                (512 * 1024 * 1024)     // 512MB

#else // !USE_TEXTURE_STREAMING

#   if TARGET_OS_IPHONE

#       define TEXTURE_HEAP_SIZE            (512 * 1024 * 1024)     // 512MB

#   else

#       define TEXTURE_HEAP_SIZE            (1536 * 1024 * 1024)    // 1.5GB

#   endif

#endif // !USE_TEXTURE_STREAMING


#if USE_SCATTERING_VOLUME

// Size of scattering volume tiles in pixels.
#   define SCATTERING_TILE_SIZE             (8)

// Number of depth slices in scattering volume
#   define SCATTERING_VOLUME_DEPTH          (64)

// View space range of scattering volume.
#   define SCATTERING_RANGE                 (100.0f)

#endif // USE_SCATTERING_VOLUME
