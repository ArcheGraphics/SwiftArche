//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "pbr_common.h"
#include "function_common.h"

// MARK: - BRDF
float F_Schlick(float dotLH) {
    return 0.04 + 0.96 * (pow(1.0 - dotLH, 5.0));
}

float3 F_Schlick(float3 specularColor, float dotLH) {
    // Original approximation by Christophe Schlick '94
    // float fresnel = pow( 1.0 - dotLH, 5.0 );
    
    // Optimized variant (presented by Epic at SIGGRAPH '13)
    // https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
    float fresnel = exp2((-5.55473 * dotLH - 6.98316) * dotLH);
    
    return (1.0 - specularColor) * fresnel + specularColor;
}

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float G_GGX_SmithCorrelated(float alpha, float dotNL, float dotNV) {
    float a2 = pow2(alpha);
    
    // dotNL and dotNV are explicitly swapped. This is not a mistake.
    float gv = dotNL * sqrt(a2 + (1.0 - a2) * pow2(dotNV));
    float gl = dotNV * sqrt(a2 + (1.0 - a2) * pow2(dotNL));
    
    return 0.5 / max( gv + gl, numeric_limits<float>::epsilon());
}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX(float alpha, float dotNH) {
    float a2 = pow2( alpha );
    float denom = pow2(dotNH) * (a2 - 1.0) + 1.0; // avoid alpha = 0 with dotNH = 1
    return M_1_PI_F * a2 / pow2(denom);
}

// GGX Distribution, Schlick Fresnel, GGX-Smith Visibility
float3 BRDF_Specular_GGX(float3 incidentDirection, float3 viewDir, float3 normal, float3 specularColor, float roughness) {
    float alpha = pow2(roughness); // UE4's roughness
    
    float3 halfDir = normalize(incidentDirection + viewDir);
    
    float dotNL = saturate(dot(normal, incidentDirection));
    float dotNV = saturate(dot(normal, viewDir));
    float dotNH = saturate(dot(normal, halfDir));
    float dotLH = saturate(dot(incidentDirection, halfDir));
    
    float3 F = F_Schlick(specularColor, dotLH);
    float G = G_GGX_SmithCorrelated(alpha, dotNL, dotNV);
    float D = D_GGX(alpha, dotNH);
    
    return F * (G * D);
}

float3 BRDF_Diffuse_Lambert(float3 diffuseColor) {
    return M_1_PI_F * diffuseColor;
}

// MARK: - IBL
float3 getLightProbeIrradiance(float3 sh[9], float3 normal){
    normal.x = -normal.x;
    float3 result = sh[0] +
    sh[1] * (normal.y) +
    sh[2] * (normal.z) +
    sh[3] * (normal.x) +
    
    sh[4] * (normal.y * normal.x) +
    sh[5] * (normal.y * normal.z) +
    sh[6] * (3.0 * normal.z * normal.z - 1.0) +
    sh[7] * (normal.z * normal.x) +
    sh[8] * (normal.x * normal.x - normal.y * normal.y);
    
    return max(result, float3(0.0));
    
}

// ref: https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
float3 envBRDFApprox(float3 specularColor,float roughness, float dotNV ) {
    const float4 c0 = float4(-1, -0.0275, -0.572, 0.022);
    const float4 c1 = float4(1, 0.0425, 1.04, -0.04);
    float4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * dotNV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return specularColor * AB.x + AB.y;
}

float getSpecularMIPLevel(float roughness, int maxMIPLevel ) {
    return roughness * float(maxMIPLevel);
}

float3 getLightProbeRadiance(float3 viewDir, float3 normal, float roughness, int maxMIPLevel, float specularIntensity,
                             sampler u_env_specularSampler, texturecube<float> u_env_specularTexture) {
    if (hasSpecularEnv) {
        float3 reflectVec = reflect( -viewDir, normal );
        reflectVec.x = -reflectVec.x; // TextureCube is left-hand,so x need inverse
        
        float specularMIPLevel = getSpecularMIPLevel(roughness, maxMIPLevel );
        float4 envMapColor = u_env_specularTexture.sample(u_env_specularSampler, reflectVec, level(specularMIPLevel));
        return envMapColor.rgb * specularIntensity;
    } else {
        return float3(0);
    }
}

// MARK: - Irradiance
void addDirectRadiance(float3 incidentDirection, float3 color, Geometry geometry, Material material, thread ReflectedLight& reflectedLight) {
    float attenuation = 1.0;
    
    if (isClearCoat) {
        float clearCoatDotNL = saturate( dot( geometry.clearCoatNormal, incidentDirection ) );
        float3 clearCoatIrradiance = clearCoatDotNL * color;
        
        reflectedLight.directSpecular += material.clearCoat * clearCoatIrradiance * BRDF_Specular_GGX(incidentDirection, geometry.viewDir,
                                                                                                      geometry.clearCoatNormal, float3(0.04),
                                                                                                      material.clearCoatRoughness);
        attenuation -= material.clearCoat * F_Schlick(geometry.clearCoatDotNV);
    }
    
    float dotNL = saturate( dot( geometry.normal, incidentDirection ) );
    float3 irradiance = dotNL * color * M_PI_F;
    
    reflectedLight.directSpecular += attenuation * irradiance * BRDF_Specular_GGX( incidentDirection, geometry.viewDir,
                                                                                  geometry.normal, material.specularColor, material.roughness);
    reflectedLight.directDiffuse += attenuation * irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
    
}

void addDirectionalDirectLightRadiance(DirectLight directionalLight, Geometry geometry,
                                       Material material, thread ReflectedLight& reflectedLight) {
    float3 color = directionalLight.color;
    float3 direction = -directionalLight.direction;
    addDirectRadiance( direction, color, geometry, material, reflectedLight );
}

void addPointDirectLightRadiance(PointLight pointLight, Geometry geometry,
                                 Material material, thread ReflectedLight& reflectedLight) {

    float3 lVector = pointLight.position - geometry.position;
    float3 direction = normalize(lVector);
    float lightDistance = length(lVector);
    float3 color = pointLight.color;
    color *= clamp(1.0 - pow(lightDistance/pointLight.distance, 4.0), 0.0, 1.0);
    
    addDirectRadiance( direction, color, geometry, material, reflectedLight );
}

void addSpotDirectLightRadiance(SpotLight spotLight, Geometry geometry, Material material, thread ReflectedLight& reflectedLight) {
    float3 lVector = spotLight.position - geometry.position;
    float3 direction = normalize(lVector);

    float lightDistance = length(lVector);
    float angleCos = dot(direction, -spotLight.direction);

    float spotEffect = smoothstep(spotLight.penumbraCos, spotLight.angleCos, angleCos);
    float decayEffect = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);

    float3 color = spotLight.color;
    color *= spotEffect * decayEffect;
    
    addDirectRadiance(direction, color, geometry, material, reflectedLight);
}
