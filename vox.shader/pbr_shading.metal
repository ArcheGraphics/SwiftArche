//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "pbr_shading.h"
#include "function_common.h"
#include "shadow/shadow_frag_share.h"

using namespace metal;

// MARK: - BRDF
float PBRShading::F_Schlick(float dotLH) {
    return 0.04 + 0.96 * (pow(1.0 - dotLH, 5.0));
}

float3 PBRShading::F_Schlick(float3 specularColor, float dotLH) {
    // Original approximation by Christophe Schlick '94
    // float fresnel = pow( 1.0 - dotLH, 5.0 );
    
    // Optimized variant (presented by Epic at SIGGRAPH '13)
    // https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
    float fresnel = exp2((-5.55473 * dotLH - 6.98316) * dotLH);
    
    return (1.0 - specularColor) * fresnel + specularColor;
}

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float PBRShading::G_GGX_SmithCorrelated(float alpha, float dotNL, float dotNV) {
    float a2 = pow2(alpha);
    
    // dotNL and dotNV are explicitly swapped. This is not a mistake.
    float gv = dotNL * sqrt(a2 + (1.0 - a2) * pow2(dotNV));
    float gl = dotNV * sqrt(a2 + (1.0 - a2) * pow2(dotNL));
    
    return 0.5 / max( gv + gl, numeric_limits<float>::epsilon());
}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float PBRShading::D_GGX(float alpha, float dotNH) {
    float a2 = pow2( alpha );
    float denom = pow2(dotNH) * (a2 - 1.0) + 1.0; // avoid alpha = 0 with dotNH = 1
    return M_1_PI_F * a2 / pow2(denom);
}

// GGX Distribution, Schlick Fresnel, GGX-Smith Visibility
float3 PBRShading::BRDF_Specular_GGX(float3 incidentDirection, float3 viewDir, float3 normal, float3 specularColor, float roughness) {
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

float3 PBRShading::BRDF_Diffuse_Lambert(float3 diffuseColor) {
    return M_1_PI_F * diffuseColor;
}

// MARK: - IBL
float3 PBRShading::getLightProbeIrradiance(float3 sh[9], float3 normal){
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
float3 PBRShading::envBRDFApprox(float3 specularColor,float roughness, float dotNV ) {
    const float4 c0 = float4(-1, -0.0275, -0.572, 0.022);
    const float4 c1 = float4(1, 0.0425, 1.04, -0.04);
    float4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * dotNV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return specularColor * AB.x + AB.y;
}

float PBRShading::getSpecularMIPLevel(float roughness, int maxMIPLevel ) {
    return roughness * float(maxMIPLevel);
}

float3 PBRShading::getLightProbeRadiance(float3 viewDir, float3 normal, float roughness, int maxMIPLevel, float specularIntensity,
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
void PBRShading::addDirectRadiance(float3 incidentDirection, float3 color) {
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

void PBRShading::addDirectionalDirectLightRadiance(DirectLightData directionalLight) {
    float3 color = directionalLight.color;
    float3 direction = -directionalLight.direction;
    addDirectRadiance(direction, color);
}

void PBRShading::addPointDirectLightRadiance(PointLightData pointLight) {
    
    float3 lVector = pointLight.position - geometry.position;
    float3 direction = normalize(lVector);
    float lightDistance = length(lVector);
    float3 color = pointLight.color;
    color *= clamp(1.0 - pow(lightDistance/pointLight.distance, 4.0), 0.0, 1.0);
    
    addDirectRadiance(direction, color);
}

void PBRShading::addSpotDirectLightRadiance(SpotLightData spotLight) {
    float3 lVector = spotLight.position - geometry.position;
    float3 direction = normalize(lVector);
    
    float lightDistance = length(lVector);
    float angleCos = dot(direction, -spotLight.direction);
    
    float spotEffect = smoothstep(spotLight.penumbraCos, spotLight.angleCos, angleCos);
    float decayEffect = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);
    
    float3 color = spotLight.color;
    color *= spotEffect * decayEffect;
    
    addDirectRadiance(direction, color);
}

void PBRShading::addTotalDirectRadiance() {
    float shadowAttenuation = 1.0;
    int sunIndex = 0;
    
    if (hasDirectLight) {
        shadowAttenuation = 1.0;
        if (needCalculateShadow) {
            shadowAttenuation *= sampleShadowMap(view_pos, u_shadowSplitSpheres, u_shadowMatrices,
                                                 u_shadowMap, u_shadowMapSampler, u_shadowMapSize, u_shadowInfo);
            sunIndex = int(u_shadowInfo.z);
        }
        
        DirectLightData directionalLight;
        for (int i = 0; i < directLightCount; i++) {
            directionalLight.color = directLight[i].color;
            if (needCalculateShadow) {
                if (i == sunIndex) {
                    directionalLight.color *= shadowAttenuation;
                }
                directionalLight.direction = directLight[i].direction;
                addDirectionalDirectLightRadiance( directionalLight);
            }
        }
    }
    
    for (int i = 0; i < pointLightCount; i++) {
        addPointDirectLightRadiance(pointLight[i]);
    }
    
    for ( int i = 0; i < spotLightCount; i ++ ) {
        addSpotDirectLightRadiance(spotLight[i]);
    }
}

// MARK: - Helper
float PBRShading::computeSpecularOcclusion(float ambientOcclusion, float roughness, float dotNV ) {
    return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}

float PBRShading::getAARoughnessFactor(float3 normal) {
    // Kaplanyan 2016, "Stable specular highlights"
    // Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
    // Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"
    float3 dxy = max( abs(dfdx(normal)), abs(dfdy(normal)) );
    return 0.04 + max( max(dxy.x, dxy.y), dxy.z );
}

void PBRShading::initGeometry(){
    geometry.position = view_pos;
    geometry.viewDir =  normalize(u_cameraPos - view_pos);
    
    matrix_float3x3 tbn;
    if (hasNormalTexture || hasClearCoatNormalTexture) {
        tbn = normalShading.getTBN();
    }
    
    if (hasNormalTexture) {
        geometry.normal = normalShading.getNormalByNormalTexture(tbn, u_normalTexture, u_normalSampler,
                                                                 u_normalIntensity, v_uv);
    } else {
        geometry.normal = normalShading.getNormal();
    }
    
    geometry.dotNV = saturate( dot(geometry.normal, geometry.viewDir) );
    
    if (isClearCoat) {
        if (hasClearCoatNormalTexture) {
            geometry.clearCoatNormal = normalShading.getNormalByNormalTexture(tbn, u_clearCoatNormalTexture,
                                                                              u_clearCoatNormalSampler, u_normalIntensity, v_uv);
        } else {
            geometry.clearCoatNormal = normalShading.getNormal();
        }
        geometry.clearCoatDotNV = saturate( dot(geometry.clearCoatNormal, geometry.viewDir) );
    }
}

void PBRShading::initMaterial(){
    float4 baseColor = u_baseColor;
    float metal = u_metal;
    float roughness = u_roughness;
    float3 specularColor = u_PBRSpecularColor;
    float glossiness = u_glossiness;
    float alphaCutoff = u_alphaCutoff;
    
    if (hasBaseTexture) {
        float4 baseTextureColor = u_baseTexture.sample(u_baseSampler, v_uv);
#ifndef OASIS_COLORSPACE_GAMMA
        baseTextureColor = gammaToLinear(baseTextureColor);
#endif
        baseColor *= baseTextureColor;
    }
    
    if (hasVertexColor) {
        baseColor *= v_color;
    }
    
    if (needAlphaCutoff) {
        if( baseColor.a < alphaCutoff ) {
            discard_fragment();
        }
    }
    
    if (hasRoughnessMetallicTexture) {
        float4 metalRoughMapColor = u_roughnessMetallicTexture.sample(u_roughnessMetallicSampler, v_uv );
        roughness *= metalRoughMapColor.g;
        metal *= metalRoughMapColor.b;
    }
    
    if (hasSpecularGlossinessTexture) {
        float4 specularGlossinessColor = u_specularGlossinessTexture.sample(u_specularGlossinessSampler, v_uv );
#ifndef OASIS_COLORSPACE_GAMMA
        specularGlossinessColor = gammaToLinear(specularGlossinessColor);
#endif
        specularColor *= specularGlossinessColor.rgb;
        glossiness *= specularGlossinessColor.a;
    }
    
    if (isMetallicWorkFlow) {
        material.diffuseColor = baseColor.rgb * ( 1.0 - metal );
        material.specularColor = mix( float3( 0.04), baseColor.rgb, metal );
        material.roughness = roughness;
    } else {
        float specularStrength = max( max( specularColor.r, specularColor.g ), specularColor.b );
        material.diffuseColor = baseColor.rgb * ( 1.0 - specularStrength );
        material.specularColor = specularColor;
        material.roughness = 1.0 - glossiness;
    }
    
    material.roughness = max(material.roughness, getAARoughnessFactor(geometry.normal));
    
    if (isClearCoat) {
        material.clearCoat = u_clearCoat;
        material.clearCoatRoughness = u_clearCoatRoughness;
        if (hasClearCoatTexture) {
            material.clearCoat *= u_clearCoatTexture.sample(u_clearCoatSampler, v_uv ).r;
        }
        if (hasClearCoatRoughnessTexture) {
            material.clearCoatRoughness *= u_clearCoatRoughnessTexture.sample(u_clearCoatRoughnessSampler, v_uv ).g;
        }
        material.clearCoat = saturate( material.clearCoat );
        material.clearCoatRoughness = max(material.clearCoatRoughness, getAARoughnessFactor(geometry.clearCoatNormal));
    }
    
    material.opacity = baseColor.a;
}
