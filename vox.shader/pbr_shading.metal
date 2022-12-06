//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "pbr_shading.h"
#include "function_common.h"
#include "shader_common.h"

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
float3 PBRShading::getLightProbeIrradiance(float3 normal){
    array<float3, 9> env_sh;
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 3; j++) {
            env_sh[i][j] = u_env_sh[i * 3 + j];
        }
    }

    normal.x = -normal.x;
    float3 result = env_sh[0] +
    env_sh[1] * (normal.y) +
    env_sh[2] * (normal.z) +
    env_sh[3] * (normal.x) +
    
    env_sh[4] * (normal.y * normal.x) +
    env_sh[5] * (normal.y * normal.z) +
    env_sh[6] * (3.0 * normal.z * normal.z - 1.0) +
    env_sh[7] * (normal.z * normal.x) +
    env_sh[8] * (normal.x * normal.x - normal.y * normal.y);
        
    return max(result / u_env_sh[27], float3(0.0));
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

float3 PBRShading::getLightProbeRadiance(float3 normal, float roughness) {
    if (hasSpecularEnv) {
        float3 reflectVec = reflect( -geometry.viewDir, normal );
        reflectVec.x = -reflectVec.x; // TextureCube is left-hand,so x need inverse
        
        float specularMIPLevel = getSpecularMIPLevel(roughness, u_envMapLight.mipMapLevel );
        float4 envMapColor = u_env_specularTexture.sample(u_env_specularSampler, reflectVec, level(specularMIPLevel));
        return envMapColor.rgb * u_envMapLight.specularIntensity;
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
            shadowAttenuation *= shadowShading.sampleShadowMap();
            sunIndex = int(u_shadowInfo.z);
        }
        
        DirectLightData directionalLight;
        for (int i = 0; i < directLightCount; i++) {
            directionalLight.color = directLight[i].color;
            if (needCalculateShadow) {
                if (i == sunIndex) {
                    directionalLight.color *= shadowAttenuation;
                }
            }
            directionalLight.direction = directLight[i].direction;
            addDirectionalDirectLightRadiance( directionalLight);
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
        baseColor *= u_baseTexture.sample(u_baseSampler, v_uv);
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

float PBRShading::computeFogIntensity(float fogDepth, FogData u_fog) {
    if (fogMode == 1) {
        // (end-z) / (end-start) = z * (-1/(end-start)) + (end/(end-start))
        return clamp(fogDepth * u_fog.params.x + u_fog.params.y, 0.0, 1.0);
    } else if (fogMode == 2) {
        // exp(-z * density) = exp2((-z * density)/ln(2)) = exp2(-z * density/ln(2))
        return  clamp(exp2(-fogDepth * u_fog.params.z), 0.0, 1.0);
    } else if (fogMode == 3) {
        // exp(-(z * density)^2) = exp2(-(z * density)^2/ln(2)) = exp2(-(z * density/sprt(ln(2)))^2)
        float factor = fogDepth * u_fog.params.w;
        return clamp(exp2(-factor * factor), 0.0, 1.0);
    }
    return 1.0;
}

float4 PBRShading::execute() {
    initGeometry();
    initMaterial();
    
    // Direct Light
    addTotalDirectRadiance();
    
    // IBL diffuse
    float3 irradiance = float3(0.0);
    if (hasSH) {
        irradiance = getLightProbeIrradiance(geometry.normal);
        irradiance *= u_envMapLight.diffuseIntensity;
    } else {
        irradiance = u_envMapLight.diffuse * u_envMapLight.diffuseIntensity;
        irradiance *= M_PI_F;
    }
    
    reflectedLight.indirectDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );
    
    // IBL specular
    float3 radiance = getLightProbeRadiance(geometry.normal, material.roughness);
    float radianceAttenuation = 1.0;
    
    if (isClearCoat) {
        float3 clearCoatRadiance = getLightProbeRadiance(geometry.clearCoatNormal, material.clearCoatRoughness);
        
        reflectedLight.indirectSpecular += clearCoatRadiance * material.clearCoat * envBRDFApprox(float3( 0.04 ), material.clearCoatRoughness, geometry.clearCoatDotNV);
        radianceAttenuation -= material.clearCoat * F_Schlick(geometry.clearCoatDotNV);
    }
    
    reflectedLight.indirectSpecular += radianceAttenuation * radiance * envBRDFApprox(material.specularColor, material.roughness, geometry.dotNV );
    
    
    // Occlusion
    if (hasOcclusionTexture) {
        float2 aoUV = v_uv;
        float ambientOcclusion = (u_occlusionTexture.sample(u_occlusionSampler, aoUV).r - 1.0) * u_occlusionIntensity + 1.0;
        reflectedLight.indirectDiffuse *= ambientOcclusion;
        if (hasSpecularEnv) {
            reflectedLight.indirectSpecular *= computeSpecularOcclusion(ambientOcclusion, material.roughness, geometry.dotNV);
        }
    }
    
    // Emissive
    float3 emissiveRadiance = u_emissiveColor;
    if (hasEmissiveTexture) {
        emissiveRadiance *= u_emissiveTexture.sample(u_emissiveSampler, v_uv).rgb;
    }
    
    float3 totalRadiance = reflectedLight.directDiffuse +
    reflectedLight.indirectDiffuse +
    reflectedLight.directSpecular +
    reflectedLight.indirectSpecular +
    emissiveRadiance;
    
    if (hasFog) {
        float fogIntensity = computeFogIntensity(length(v_positionVS), u_fog);
        totalRadiance.rgb = mix(u_fog.color.rgb, totalRadiance.rgb, fogIntensity);
    }
    
    return float4(totalRadiance, material.opacity);
}

// MARK: - Entry

typedef struct {
    float4 position [[position]];
    float3 v_pos [[function_constant(needWorldPos)]];
    float2 v_uv;
    float4 v_color [[function_constant(hasVertexColor)]];
    float3 normalW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentOrHasNormalTexture)]];
    float3 v_positionVS [[function_constant(hasFog)]];
} VertexOut;

vertex VertexOut vertex_pbr(const VertexIn in [[stage_in]],
                            uint v_id [[vertex_id]],
                            constant CameraData &u_camera [[buffer(2)]],
                            constant RendererData &u_renderer [[buffer(3)]],
                            constant float4 &u_tilingOffset [[buffer(4)]],
                            // skin
                            texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                            constant int &u_jointCount [[buffer(5), function_constant(hasSkinAndHasJointTexture)]],
                            constant matrix_float4x4 *u_jointMatrix [[buffer(6), function_constant(hasSkinNotHasJointTexture)]],
                            // morph
                            texture2d_array<float> u_blendShapeTexture [[texture(1), function_constant(hasBlendShape)]],
                            constant int3 &u_blendShapeTextureInfo [[buffer(7), function_constant(hasBlendShape)]],
                            constant float *u_blendShapeWeights [[buffer(8), function_constant(hasBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( in.POSITION, 1.0);
    
    //begin normal
    float3 normal;
    float4 tangent;
    if (!omitNormal) {
        if (hasNormal) {
            normal = in.NORMAL;
        }
        if (hasTangent) {
            tangent = in.TANGENT;
        }
    }
    
    //blendshape
    if (hasBlendShape) {
        int vertexOffset = v_id * u_blendShapeTextureInfo.x;
        for(int i = 0; i < blendShapeCount; i++){
            int vertexElementOffset = vertexOffset;
            float weight = u_blendShapeWeights[i];
            position.xyz += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
            
            if (!omitNormal) {
                if (hasNormal && hasBlendShapeNormal) {
                    vertexElementOffset += 1;
                    normal += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
                }
                
                if (hasNormal && hasBlendShapeTangent && (hasNormalTexture || hasClearCoatNormalTexture)) {
                    vertexElementOffset += 1;
                    tangent.xyz += getBlendShapeVertexElement(i, vertexElementOffset, u_blendShapeTextureInfo ,u_blendShapeTexture) * weight;
                }
            }
        }
    }
    
    //skinning
    if (hasSkin) {
        matrix_float4x4 skinMatrix;
        if (hasJointTexture) {
            skinMatrix =
            in.WEIGHTS_0.x * getJointMatrix(u_jointTexture, in.JOINTS_0.x, u_jointCount) +
            in.WEIGHTS_0.y * getJointMatrix(u_jointTexture, in.JOINTS_0.y, u_jointCount) +
            in.WEIGHTS_0.z * getJointMatrix(u_jointTexture, in.JOINTS_0.z, u_jointCount) +
            in.WEIGHTS_0.w * getJointMatrix(u_jointTexture, in.JOINTS_0.w, u_jointCount);
        } else {
            skinMatrix =
            in.WEIGHTS_0.x * u_jointMatrix[int(in.JOINTS_0.x)] +
            in.WEIGHTS_0.y * u_jointMatrix[int(in.JOINTS_0.y)] +
            in.WEIGHTS_0.z * u_jointMatrix[int(in.JOINTS_0.z)] +
            in.WEIGHTS_0.w * u_jointMatrix[int(in.JOINTS_0.w)];
        }
        position = skinMatrix * position;
        
        if (hasNormal && !omitNormal) {
            matrix_float3x3 skinNormalMatrix = inverse(matrix_float3x3(skinMatrix[0][0], skinMatrix[0][1], skinMatrix[0][2],
                                                                       skinMatrix[1][0], skinMatrix[1][1], skinMatrix[1][2],
                                                                       skinMatrix[2][0], skinMatrix[2][1], skinMatrix[2][2]));
            normal = normal * skinNormalMatrix;
            if (hasTangent && (hasNormalTexture || hasClearCoatNormalTexture)) {
                tangent.xyz = tangent.xyz * skinNormalMatrix;
            }
        }
    }
    
    // uv
    if (hasUV) {
        out.v_uv = in.TEXCOORD_0;
    } else {
        out.v_uv = float2(0.0, 0.0);
    }
    if (needTilingOffset) {
        out.v_uv = out.v_uv * u_tilingOffset.xy + u_tilingOffset.zw;
    }
    
    // color
    if (hasVertexColor) {
        out.v_color = in.COLOR_0;
    }
    
    // normal
    if (!omitNormal) {
        if (hasNormal) {
            auto u_normalMat = float3x3(u_renderer.u_normalMat.columns[0].xyz,
                                        u_renderer.u_normalMat.columns[1].xyz,
                                        u_renderer.u_normalMat.columns[2].xyz);
            out.v_normal = normalize(u_normalMat * normal);
            if (hasTangent && (hasNormalTexture || hasClearCoatNormalTexture)) {
                out.normalW = normalize(u_normalMat * normal.xyz);
                out.tangentW = normalize(u_normalMat * tangent.xyz);
                out.bitangentW = cross(out.normalW, out.tangentW) * tangent.w;
            }
        }
    }
    
    // world pos
    if (needWorldPos) {
        float4 temp_pos = u_renderer.u_modelMat * position;
        out.v_pos = temp_pos.xyz / temp_pos.w;
    }
    
    // fog
    if (hasFog) {
        out.v_positionVS = (u_camera.u_viewMat * u_renderer.u_modelMat * position).xyz;
    }
    
    out.position = u_camera.u_VPMat * u_renderer.u_modelMat * position;
    
    return out;
}

fragment float4 fragment_pbr(VertexOut in [[stage_in]],
                             // common_frag
                             constant CameraData &u_camera [[buffer(0)]],
                             constant RendererData &u_renderer [[buffer(1)]],
                             // direct light
                             constant DirectLightData *u_directLight [[buffer(2), function_constant(hasDirectLight)]],
                             constant PointLightData *u_pointLight [[buffer(3), function_constant(hasPointLight)]],
                             constant SpotLightData *u_spotLight [[buffer(4), function_constant(hasSpotLight)]],
                             // indirect light
                             constant EnvMapLight &u_envMapLight [[buffer(5)]],
                             constant float *u_env_sh [[buffer(6), function_constant(hasSH)]],
                             texturecube<float> u_env_specularTexture [[texture(1), function_constant(hasSpecularEnv)]],
                             sampler u_env_specularSampler [[sampler(1), function_constant(hasSpecularEnv)]],
                             //pbr base frag define
                             constant float& u_alphaCutoff [[buffer(7)]],
                             constant PBRBaseData &u_pbrBase [[buffer(8)]],
                             constant PBRData &u_pbr [[buffer(9)]],
                             constant PBRSpecularData &u_pbrSpecular [[buffer(10)]],
                             // pbr_texture_frag_define
                             texture2d<float> u_baseColorTexture [[texture(2), function_constant(hasBaseTexture)]],
                             sampler u_baseColorSampler [[sampler(2), function_constant(hasBaseTexture)]],
                             texture2d<float> u_normalTexture [[texture(3), function_constant(hasNormalTexture)]],
                             sampler u_normalSampler [[sampler(3), function_constant(hasNormalTexture)]],
                             texture2d<float> u_emissiveTexture [[texture(4), function_constant(hasEmissiveTexture)]],
                             sampler u_emissiveSampler [[sampler(4), function_constant(hasEmissiveTexture)]],
                             texture2d<float> u_metallicRoughnessTexture [[texture(5), function_constant(hasRoughnessMetallicTexture)]],
                             sampler u_metallicRoughnessSampler [[sampler(5), function_constant(hasRoughnessMetallicTexture)]],
                             texture2d<float> u_specularGlossinessTexture [[texture(6), function_constant(hasSpecularGlossinessTexture)]],
                             sampler u_specularGlossineseSampler [[sampler(6), function_constant(hasSpecularGlossinessTexture)]],
                             texture2d<float> u_occlusionTexture [[texture(7), function_constant(hasOcclusionTexture)]],
                             sampler u_occlusionSampler [[sampler(7), function_constant(hasOcclusionTexture)]],
                             texture2d<float> u_clearCoatTexture [[texture(8), function_constant(hasClearCoatTexture)]],
                             sampler u_clearCoatSampler [[sampler(8), function_constant(hasClearCoatTexture)]],
                             texture2d<float> u_clearCoatNormalTexture [[texture(9), function_constant(hasClearCoatNormalTexture)]],
                             sampler u_clearCoatNormalSampler [[sampler(9), function_constant(hasClearCoatNormalTexture)]],
                             texture2d<float> u_clearCoatRoghnessTexture [[texture(10), function_constant(hasClearCoatRoughnessTexture)]],
                             sampler u_clearCoatRoghnessSampler [[sampler(10), function_constant(hasClearCoatRoughnessTexture)]],
                             // shadow
                             constant float4* u_shadowSplitSpheres [[buffer(11), function_constant(needCalculateShadow)]],
                             constant matrix_float4x4* u_shadowMatrices [[buffer(12), function_constant(needCalculateShadow)]],
                             constant float4 &u_shadowMapSize [[buffer(13), function_constant(needCalculateShadow)]],
                             constant float3 &u_shadowInfo [[buffer(14), function_constant(needCalculateShadow)]],
                             depth2d<float> u_shadowTexture [[texture(11), function_constant(needCalculateShadow)]],
                             sampler u_shadowSampler [[sampler(11), function_constant(needCalculateShadow)]],
                             // fog
                             constant FogData &u_fog [[buffer(15), function_constant(hasFog)]],
                             bool is_front_face [[front_facing]]) {
    PBRShading shading;
    
    shading.normalShading.isFrontFacing = is_front_face;
    if (needWorldPos) {
        shading.normalShading.v_pos = in.v_pos;
    }
    if (!omitNormal) {
        if (hasNormal) {
            shading.normalShading.v_normal = in.v_normal;
            if (hasTangent && (hasNormalTexture || hasClearCoatNormalTexture)) {
                shading.normalShading.v_TBN = matrix_float3x3(in.tangentW, in.bitangentW, in.normalW);
            }
        }
    }
    
    if (needWorldPos) {
        shading.shadowShading.v_pos = in.v_pos;
    }
    
    if (needCalculateShadow) {
        shading.shadowShading.u_shadowMap = u_shadowTexture;
        shading.shadowShading.u_shadowMapSampler = u_shadowSampler;
        shading.shadowShading.u_shadowInfo = u_shadowInfo;
        shading.shadowShading.u_shadowMapSize = u_shadowMapSize;
        shading.shadowShading.u_shadowMatrices = u_shadowMatrices;
        shading.shadowShading.u_shadowSplitSpheres = u_shadowSplitSpheres;
    }
    
    if (hasDirectLight) {
        shading.directLight = u_directLight;
    }
    if (hasSpotLight) {
        shading.spotLight = u_spotLight;
    }
    if (hasPointLight) {
        shading.pointLight = u_pointLight;
    }
    
    shading.u_envMapLight = u_envMapLight;
    if (hasSH) {
        shading.u_env_sh = u_env_sh;
    }
    if (hasSpecularEnv) {
        shading.u_env_specularSampler = u_env_specularSampler;
        shading.u_env_specularTexture = u_env_specularTexture;
    }
    
    shading.u_alphaCutoff = u_alphaCutoff;
    shading.u_baseColor = u_pbrBase.baseColor;
    shading.u_emissiveColor = u_pbrBase.emissiveColor;
    shading.u_normalIntensity = u_pbrBase.normalTextureIntensity;
    shading.u_occlusionIntensity = u_pbrBase.occlusionTextureIntensity;
    shading.u_occlusionTextureCoord = u_pbrBase.occlusionTextureCoord;
    
    if (isMetallicWorkFlow) {
        shading.u_metal = u_pbr.metallic;
        shading.u_roughness = u_pbr.roughness;
    } else {
        shading.u_PBRSpecularColor = u_pbrSpecular.specularColor;
        shading.u_glossiness = u_pbrSpecular.glossiness;
    }
    
    if (isClearCoat) {
        shading.u_clearCoat = u_pbrBase.clearCoat;
        shading.u_clearCoatRoughness = u_pbrBase.clearCoatRoughness;
    }
    
    if (hasBaseTexture) {
        shading.u_baseTexture = u_baseColorTexture;
        shading.u_baseSampler = u_baseColorSampler;
    }
    
    if (hasNormalTexture) {
        shading.u_normalTexture = u_normalTexture;
        shading.u_normalSampler = u_normalSampler;
    }
    
    if (hasEmissiveTexture) {
        shading.u_emissiveTexture = u_emissiveTexture;
        shading.u_emissiveSampler = u_emissiveSampler;
    }
    
    if (hasRoughnessMetallicTexture) {
        shading.u_roughnessMetallicTexture = u_metallicRoughnessTexture;
        shading.u_roughnessMetallicSampler = u_metallicRoughnessSampler;
    }
    
    if (hasSpecularGlossinessTexture) {
        shading.u_specularGlossinessTexture = u_specularGlossinessTexture;
        shading.u_specularGlossinessSampler = u_specularGlossineseSampler;
    }
    
    if (hasOcclusionTexture) {
        shading.u_occlusionTexture = u_occlusionTexture;
        shading.u_occlusionSampler = u_occlusionSampler;
    }
    
    if (hasClearCoatTexture) {
        shading.u_clearCoatTexture = u_clearCoatTexture;
        shading.u_clearCoatSampler = u_clearCoatSampler;
    }
    
    if (hasClearCoatNormalTexture) {
        shading.u_clearCoatNormalTexture = u_clearCoatNormalTexture;
        shading.u_clearCoatNormalSampler = u_clearCoatNormalSampler;
    }
    
    if (hasClearCoatRoughnessTexture) {
        shading.u_clearCoatRoughnessTexture = u_clearCoatRoghnessTexture;
        shading.u_clearCoatRoughnessSampler = u_clearCoatRoghnessSampler;
    }
    
    if (hasVertexColor) {
        shading.v_color = in.v_color;
    }
    shading.v_uv = in.v_uv;
    shading.u_cameraPos = u_camera.u_cameraPos;
    if (needWorldPos) {
        shading.view_pos = in.v_pos;
    }
    
    if (hasFog) {
        shading.v_positionVS = in.v_positionVS;
        shading.u_fog = u_fog;
    }
    
    return shading.execute();
}
