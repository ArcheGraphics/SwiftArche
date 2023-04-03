//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

//------------------------------------------------------------------------------

// Standard Smith geometric shadowing function.
static float G1V(float NdV, float k) {
    return 1.0f / (NdV * (1.0f - k) + k);
}

// Standard GGX normal distribution function.
static float GGX_NDF(float NdH, float alpha) {
    float alpha2 = alpha * alpha;

    float denom = NdH * NdH * (alpha2 - 1.0f) + 1.0f;

    denom = max(denom, 1e-3);

    return alpha2 / (M_PI_F * denom * denom);
}

// Standard Schlick approximation to fresnel.
static float3 Fresnel_Schlick(xhalf3 F0, float LdH) {
    return (float3)(F0 + (1.0f - F0) * pow(1.0f - LdH, 5));
}

//------------------------------------------------------------------------------

// Evaluates the BRDF at a surface given view and light directions.
static xhalf3 evaluateBRDF(PixelSurfaceData surface,
                           xhalf3 viewDir,
                           xhalf3 lightDirection) {
    float3 H = normalize((float3)viewDir+(float3)lightDirection);

    float NdL = saturate(dot(surface.normal, lightDirection));
    float LdH = saturate(dot((float3)lightDirection, H));
    float NdH = saturate(dot((float3)surface.normal, H));
    float NdV = saturate(dot(surface.normal, viewDir));

    float alpha = surface.roughness * surface.roughness;
    float k =  alpha / 2.0f;

    float3 diffuse = (float3)surface.albedo/M_PI_F;
    float3 F = Fresnel_Schlick(surface.F0, LdH);
    float  G = G1V(NdL, k) * G1V(NdV, k);

    float3 specular = F * GGX_NDF(NdH, alpha) * G / 4.0f;

    return (xhalf3)(diffuse * (1 - F) + specular) * NdL;
}

//------------------------------------------------------------------------------

// Evaluates the Spherical Harmonics coefficients for a given direction.
static xhalf3 evaluateShCoefficients(xhalf3 n) {
    xhalf3 shCoefs[] =
    {
        xhalf3( 1.614944507896493,  1.541036092763475,  1.571013589299304), // L00, irradiance
        xhalf3(-0.253877086046911, -0.429470071197213, -0.690516354135927), // L1-1, irradiance
        xhalf3( 0.169490208844630,  0.354603612695152,  0.470313910537248), // L10, irradiance
        xhalf3( 0.097116881286676,  0.266256657319848,  0.359295544072626), // L11, irradiance
        xhalf3(-0.068539142976241, -0.113442880787374, -0.144920974765986), // L2-2, irradiance
        xhalf3(-0.155764013783923, -0.197141784218826, -0.219866180869429), // L2-1, irradiance
        xhalf3( 0.048072946052602,  0.047616845245505,  0.028245382387344), // L20, irradiance
        xhalf3( 0.222550351872431,  0.198626269418641,  0.175229058057126), // L21, irradiance
        xhalf3( 0.025198626854623, -0.020106073808714, -0.063087948829664), // L22, irradiance
    };

    return
        shCoefs[0]
        + shCoefs[1] * (n.y)
        + shCoefs[2] * (n.z)
        + shCoefs[3] * (n.x)
        + shCoefs[4] * (n.y * n.x)
        + shCoefs[5] * (n.y * n.z)
        + shCoefs[6] * (3.0 * n.z * n.z - 1.0)
        + shCoefs[7] * (n.z * n.x)
        + shCoefs[8] * (n.x * n.x - n.y * n.y);
}

// Performs the Image Based Lighting element of the lighting.
static xhalf3 IBL(PixelSurfaceData surface,
                  texturecube<xhalf> envMap,
                  texture2d<xhalf> dfgLut,
                  xhalf3 viewDir,
                  float scale,
                  float specularScale) {
    constexpr sampler linearSampler (mip_filter::linear, mag_filter::linear, min_filter::linear);

    xhalf3 diffuseIBL = evaluateShCoefficients(-surface.normal) * surface.albedo;
    float perceptualRoughness = surface.roughness;

    float NoV = max(dot(surface.normal, viewDir), (xhalf)0.0);
    xhalf3 r = reflect(-viewDir, surface.normal);

    const float mipLevels = 8.0f;
    float lod = perceptualRoughness * mipLevels;
    xhalf4 envMapSample = envMap.sample(linearSampler, (float3)r, level(lod));
    xhalf3 indirectSpecular = 6.0 * envMapSample.rgb * envMapSample.a;
    xhalf2 dfg = dfgLut.sample(linearSampler, float2(NoV, perceptualRoughness), 0.0).rg;
    xhalf3 specularColor = surface.F0 * dfg.x + 1.0 * dfg.y;

    xhalf3 specularIBL = indirectSpecular * specularColor;

    xhalf3 result = diffuseIBL + specularIBL * specularScale;

    return result * scale;
}

//------------------------------------------------------------------------------

// Calculates the lighting contribution from a point light.
static xhalf3 applyPointLight(PixelSurfaceData surface,
                              PointLightData light,
                              float localLightIntensity,
                              float3 position,
                              xhalf3 viewDir) {
    float3 lightVector = light.posSqrRadius.xyz - position;

    if (dot(lightVector, lightVector) > light.posSqrRadius.w)
        return 0.0;

    float attenuation = getDistanceAttenuation(lightVector, 1.0/light.posSqrRadius.w);

    return evaluateBRDF(surface,
                        viewDir,
                        (xhalf3)normalize(lightVector)) * (xhalf3)(light.color.xyz * M_PI_F * localLightIntensity * attenuation);
}

// Calculates the lighting contribution from a point light.
static xhalf3 applySpotLight(PixelSurfaceData surface,
                             SpotLightData light,
                             float localLightIntensity,
                             float3 position,
                             xhalf3 viewDir
#if USE_SPOT_LIGHT_SHADOWS
                             , uint lightIdx
                             , depth2d_array<float> spotShadowMaps
#endif
                             ) {
    float3 lightVector = light.posAndHeight.xyz - position;
    xhalf3 lightForward = (xhalf3)light.dirAndOuterAngle.xyz;

    xhalf cosAngle = (xhalf)light.dirAndOuterAngle.w;
    float llightVector = length(lightVector);
    xhalf3 lightDirection = (xhalf3)(lightVector / llightVector);

    bool distCutoff = llightVector > light.posAndHeight.w;
    bool angleCutoff = dot(-lightDirection, lightForward) < cosAngle;
    if( distCutoff || angleCutoff)
        return 0.0;

    float attenuation = getDistanceAttenuation(lightVector, 1.0/(light.posAndHeight.w * light.posAndHeight.w));
    attenuation *= getAngleAttenuation(lightForward, -lightDirection, light.dirAndOuterAngle.w, light.colorAndInnerAngle.w);

    float shadow = 1.0;
#if USE_SPOT_LIGHT_SHADOWS
    constexpr sampler compareSampler (min_filter::linear, mag_filter::linear, compare_func::less, address::clamp_to_edge);

    float4 lightSpacePos = light.viewProjMatrix * float4(position.xyz, 1);
    lightSpacePos /= lightSpacePos.w;

    if (all(lightSpacePos.xyz < 1.0) && all(lightSpacePos.xyz > float3(-1,-1,0))) {
        shadow = 0.0f;
        float lightSpaceDepth = lightSpacePos.z - SPOT_SHADOW_DEPTH_BIAS;
        float2 shadowUv = lightSpacePos.xy * float2(0.5, -0.5) + 0.5;

        for (int j = -1; j <= 1; ++j) {
            for (int i = -1; i <= 1; ++i) {
                shadow += spotShadowMaps.sample_compare(compareSampler, shadowUv, lightIdx, lightSpaceDepth, int2(i,j));
            }
        }
        shadow /= 9;
    }
#endif

    //according to Moving Frostbite to PBR, intensity spot = 4.0 * intensity point
    return 4.0 * evaluateBRDF(surface, viewDir, lightDirection) * (xhalf3)(light.colorAndInnerAngle.xyz * M_PI_F * localLightIntensity * attenuation * shadow);
}

//------------------------------------------------------------------------------

/// Reusable function for applying lighting.
///  Includes overrides for debug visualization if the gEnableDebugView function
///  constant is set to true.
template <typename PointLightDataArray, typename SpotLightDataArray, typename IndexArray>
static xhalf3 lightingShader(PixelSurfaceData surfaceData,
                             xhalf aoSample,
                             float depth,
                             float4 worldPosition,
                             constant FrameConstants & frameData,
                             constant CameraData & cameraParams,
                             depth2d_array<float, access::sample> shadowMap,
                             texture2d<xhalf, access::sample> dfgLutTex,
                             texturecube<xhalf> envMap,
                             PointLightDataArray pointLightBuffer,
                             SpotLightDataArray spotLightBuffer,
                             IndexArray pointLightIndices,
                             IndexArray spotLightIndices,
#if USE_SPOT_LIGHT_SHADOWS
                             depth2d_array<float, access::sample> spotShadowMaps,
#endif
                             bool debugView) {
    uint cascadeIndex;
    xhalf shadow = (xhalf)evaluateCascadeShadows(frameData, worldPosition.xyz, shadowMap, cascadeIndex, true);
    xhalf3 viewDir = (xhalf3)normalize(cameraParams.u_viewInvMat[3].xyz - worldPosition.xyz);

    const xhalf3 lightDirection = (xhalf3)frameData.sunDirection;
    const xhalf3 light = (xhalf3)(frameData.sunColor * M_PI_F);

    xhalf3 result = evaluateBRDF(surfaceData, viewDir, lightDirection) * light * shadow;
    result += IBL(surfaceData, envMap, dfgLutTex, viewDir, frameData.iblScale, frameData.iblSpecularScale);

    result *= aoSample;

    result += surfaceData.emissive * frameData.emissiveScale;

    //dynamic lights
    uint perTilePointLightCount = pointLightIndices[0];
    for(uint i = 0; i < perTilePointLightCount; i++) {
        uint lightIdx = pointLightIndices[i+1];
        xhalf3 out = applyPointLight(surfaceData,
                                     pointLightBuffer[lightIdx],
                                     frameData.localLightIntensity,
                                     worldPosition.xyz,
                                     viewDir);
        result += out;
    }

    uint perTileSpotLightCount = spotLightIndices[0];
    for(uint i = 0; i < perTileSpotLightCount; i++) {
        uint lightIdx = spotLightIndices[i+1];

        xhalf3 out = applySpotLight(surfaceData,
                                    spotLightBuffer[lightIdx],
                                    frameData.localLightIntensity,
                                    worldPosition.xyz,
                                    viewDir
#if USE_SPOT_LIGHT_SHADOWS
                                    , lightIdx
                                    , spotShadowMaps
#endif
                                    );
        result += out;
        //return float4(result,1);
    }

    if(depth == 1.0f) {
        result = (xhalf3)frameData.skyColor;
    }

    if(debugView) {
        if(frameData.debugView == 1)
            result = surfaceData.albedo.rgb;
        else if(frameData.debugView == 2)
            result = surfaceData.normal.rgb * 0.5f + 0.5f;
        else if(frameData.debugView == 3)
            result = surfaceData.F0.rgb;
        else if(frameData.debugView == 4)
            result = surfaceData.roughness;
        else if(frameData.debugView == 5)
            result = surfaceData.emissive.rgb;
        else if(frameData.debugView == 6)
            result = fmod(linearizeDepth(cameraParams, depth), 1.0f);
        else if(frameData.debugView == 7)
            result = shadow;
        else if(frameData.debugView == 8) {
            if(cascadeIndex == 0)
                result.gb = 0.0f;
            else if(cascadeIndex == 1)
                result.rb = 0.0f;
            else if(cascadeIndex == 2)
                result.rg = 0.0f;
        }
        else if(frameData.debugView == 9)
            result = aoSample;
    }

    return result;
}

