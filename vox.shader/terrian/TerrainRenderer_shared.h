//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#include "TerrainRenderer_define.h"

// Macro to affix the argument buffer index onto the property name if we're running on the GPU
#ifdef __METAL_VERSION__
#define IAB_INDEX(x) [[id(x)]]
#else
#define IAB_INDEX(x)
#endif

enum TerrainHabitatType : uint8_t
{
    TerrainHabitatTypeSand,
    TerrainHabitatTypeGrass,
    TerrainHabitatTypeRock,
    TerrainHabitatTypeSnow,

    // The number of variations of each type, for added realism
    TerrainHabitatTypeCOUNT
};

#define VARIATION_COUNT_PER_HABITAT 4

enum class TerrainHabitat_MemberIds: uint32_t
{
    slopeStrength = 0,
    slopeThreshold,
    elevationStrength,
    elevationThreshold,
    specularPower,
    textureScale,
    flipNormal,

    // The "particle_" properties must match TerrainHabitat::ParticleProperties fields
    particle_keyTimePoints,
    particle_scaleFactors,
    particle_alphaFactors,
    particle_gravity,
    particle_lightingCoefficients,
    particle_doesCollide,
    particle_doesRotate,
    particle_castShadows,
    particle_distanceDependent,
    diffSpecTextureArray,
    normalTextureArray,
    COUNT,
};

// The argument buffer that defines materials and particle properties
struct TerrainHabitat
{
    float slopeStrength      IAB_INDEX(TerrainHabitat_MemberIds::slopeStrength);
    float slopeThreshold     IAB_INDEX(TerrainHabitat_MemberIds::slopeThreshold);
    float elevationStrength  IAB_INDEX(TerrainHabitat_MemberIds::elevationStrength);
    float elevationThreshold IAB_INDEX(TerrainHabitat_MemberIds::elevationThreshold);
    float specularPower      IAB_INDEX(TerrainHabitat_MemberIds::specularPower);
    float textureScale       IAB_INDEX(TerrainHabitat_MemberIds::textureScale);
    bool  flipNormal         IAB_INDEX(TerrainHabitat_MemberIds::flipNormal);

    struct ParticleProperties
    {
        // The fields of this struct must be reflected in TerrainHabitat_MemberIds
        simd_float4    keyTimePoints;
        simd_float4    scaleFactors;
        simd_float4    alphaFactors;
        simd_float4    gravity;
        simd_float4    lightingCoefficients;
        int             doesCollide;
        int             doesRotate;
        int             castShadows;
        int             distanceDependent;
    } particleProperties;

#ifdef __METAL_VERSION__
    texture2d_array <float,access::sample> diffSpecTextureArray IAB_INDEX(TerrainHabitat_MemberIds::diffSpecTextureArray);
    texture2d_array <float,access::sample> normalTextureArray   IAB_INDEX(TerrainHabitat_MemberIds::normalTextureArray);
#endif
};

enum class TerrainParams_MemberIds : uint32_t
{
    ambientOcclusionScale = int(TerrainHabitat_MemberIds::COUNT) * TerrainHabitatTypeCOUNT + 1,
    ambientOcclusionContrast,
    ambientLightScale,
    atmosphereScale,
    COUNT
};

// Each habitat type has a few slightly different variations for added realism
struct TerrainParams
{
    TerrainHabitat habitats [TerrainHabitatTypeCOUNT];
    float ambientOcclusionScale    IAB_INDEX(TerrainParams_MemberIds::ambientOcclusionScale);
    float ambientOcclusionContrast IAB_INDEX(TerrainParams_MemberIds::ambientOcclusionContrast);
    float ambientLightScale        IAB_INDEX(TerrainParams_MemberIds::ambientLightScale);
    float atmosphereScale          IAB_INDEX(TerrainParams_MemberIds::atmosphereScale);
};

struct TerrainAdjustParams
{
    simd_float4x4  inverseViewProjectionMatrix;
    simd_float4x4  viewProjectionMatrix;
    simd_float3    cameraPosition;
    simd_float2    invScreenSize;
    simd_float2    invHeightmapSize;
    float           power;
    float           radiusScale;
    float           brushHighlight;
    uint32_t        component;
    bool            useTargetMap;
};
