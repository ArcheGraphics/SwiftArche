//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "function_constant.h"
#include "light_common.h"

struct ReflectedLight {
    float3 directDiffuse;
    float3 directSpecular;
    float3 indirectDiffuse;
    float3 indirectSpecular;
};

struct Geometry {
    float3 position;
    float3 normal;
    float3 viewDir;
    float dotNV;
    float3 clearCoatNormal [[function_constant(isClearCoat)]];
    float clearCoatDotNV [[function_constant(isClearCoat)]];
};

struct Material {
    float3 diffuseColor;
    float roughness;
    float3 specularColor;
    float opacity;
    float clearCoat [[function_constant(isClearCoat)]];
    float clearCoatRoughness [[function_constant(isClearCoat)]];
};

// MARK: - BRDF
float F_Schlick(float dotLH);

float3 F_Schlick(float3 specularColor, float dotLH);

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float G_GGX_SmithCorrelated(float alpha, float dotNL, float dotNV );

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX(float alpha, float dotNH);

// GGX Distribution, Schlick Fresnel, GGX-Smith Visibility
float3 BRDF_Specular_GGX(float3 incidentDirection, float3 viewDir, float3 normal, float3 specularColor, float roughness);

float3 BRDF_Diffuse_Lambert(float3 diffuseColor);

// MARK: - IBL
float3 getLightProbeIrradiance(float3 sh[9], float3 normal);

// ref: https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
float3 envBRDFApprox(float3 specularColor,float roughness, float dotNV);

float getSpecularMIPLevel(float roughness, int maxMIPLevel);

float3 getLightProbeRadiance(float3 viewDir, float3 normal, float roughness, int maxMIPLevel, float specularIntensity,
                             sampler u_env_specularSampler, texturecube<float> u_env_specularTexture);

// MARK: - Irradiance
void addDirectRadiance(float3 incidentDirection, float3 color, Geometry geometry,
                       Material material, thread ReflectedLight& reflectedLight);
