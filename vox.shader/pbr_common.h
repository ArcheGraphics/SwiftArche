//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

// Create the Environment BRDF look-up texture

// http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html

float radicalInverse_VdC(uint bits);

float2 Hammersley(uint i, uint N);

// http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float G_Smith(float roughness, float NoV, float NoL, bool ibl);
float3 ImportanceSampleGGX(float2 Xi, float Roughness, float3 N);
float2 IntegrateBRDF(float Roughness, float NoV);
float3 PrefilterEnvMap(float Roughness, float3 R,
                       texturecube<float, access::sample>EnvMap);
float3 convertUVToDirection(uint face, float2 uv);
