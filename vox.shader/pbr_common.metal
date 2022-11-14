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
