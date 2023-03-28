//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>

#ifdef __METAL_VERSION__
#import <metal_stdlib>
using namespace metal;
#define CONSTANT constant
#else
#define CONSTANT
#endif

// Amount of cameras we have, needed to allocate instance lists
CONSTANT uint  kCameraCount         = NUM_CASCADES + 1;

// The amount of populations we have loaded (hardcoded; needs to match up with loaded assets)
CONSTANT uint  kPopulationCount     = 21;

// The maximum amount of rules that is evaluated per habitat
CONSTANT uint  kRulesPerHabitat     = 4;

// grid resolution used when placing; the distance between two placed vegetation objects
CONSTANT uint  kGridResolution      = 64;

// The maximum amount of instances of a single population
CONSTANT uint  kMaxInstanceCount    = 1024 * 16;

// The scale applied on all meshes to fit within the overal world unit scale
CONSTANT float kVegetationScale     = 200.0f;

// Helper function to find the "bin" (which is the instance buffer) for each population within each viewport/camera
uint GetBinFor(uint inPopulationIndex, uint inCameraIndex)
{
    return inPopulationIndex + inCameraIndex * kPopulationCount;
}

// A rule that is evaluated on GPU, it specifies what range of population lives within a certain habitat
// and at what density. Four of these rules are defined per habitat
#ifdef __METAL_VERSION__
struct AAPLPopulationRule
{
    float   densityInHabitat     = 0.0f;    // value of 0 ... 1 in terms of density
    float   scale                = 1.0f;    // scale of asset
    uint    populationStartIndex = 0;       // index in VegetationRenderer::populations
    uint    populationIndexCount = 0;       // a list of populations can be defined; density is evenly distributed between them
};
#else
struct AAPLPopulationRule
{
    float   densityInHabitat     ;    // value of 0 ... 1 in terms of density
    float   scale                ;    // scale of asset
    uint    populationStartIndex ;       // index in VegetationRenderer::populations
    uint    populationIndexCount ;       // a list of populations can be defined; density is evenly distributed between them
};
#endif
