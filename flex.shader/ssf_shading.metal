//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
#include "type_common.h"
#include "function_constant.h"
using namespace metal;

typedef struct {
    float3 position [[attribute(Position)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_ssf(const VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 1.0);
    out.v_uv = in.position.xy * 0.5 + 0.5;
    out.v_uv.y = 1 - out.v_uv.y;
    return out;
}

struct fragmentOut {
    float4 color[[color(0)]];
    float depth[[depth(greater)]];
};

class ScreenSpaceFluid {
public:
    enum ShadingOption {
        depth,
        thick,
        normal,
        fresnel_scale,
        reflect,
        refract,
        refract_tinted,
        fresnel
    };
    
    fragmentOut execute() {
        // ze to z_ndc to gl_FragDepth
        // REF: https://computergraphics.stackexchange.com/questions/6308/why-does-this-gl-fragdepth-calculation-work?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
        float ze = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).w;
        float z_ndc = proj(-ze);
        
        fragmentOut out;
        out.depth = ze;
        switch(shading_option) {
            case depth:
                out.color = shading_depth();
                break;
            case thick:
                out.color = shading_thick();
                break;
            case normal:
                out.color = shading_normal();
                break;
            case fresnel_scale:
                out.color = shading_fresnel_scale();
                break;
            case reflect:
                out.color = shading_reflect();
                break;
            case refract:
                out.color = shading_refract();
                break;
            case refract_tinted:
                out.color = shading_refract_tinted();
                break;
            case fresnel:
                out.color = shading_fresnel();
                break;
        }
        
        return out;
    }
    
    float proj(float ze) {
        return (u_ssf.p_f + u_ssf.p_n) / (u_ssf.p_f - u_ssf.p_n) + 2 * u_ssf.p_f * u_ssf.p_n / ((u_ssf.p_f - u_ssf.p_n) * ze);
    }

    float3 getPos() {
        /* Return in right-hand coord */
        float z = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).w;
        float x = texCoord.x, y = texCoord.y;
        x = (2 * x - 1) * u_ssf.p_r * z / u_ssf.p_n;
        y = (2 * y - 1) * u_ssf.p_t * z / u_ssf.p_n;
        return float3(x, y, -z);
    }

    float4 shading_normal() {
        return float4(u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz, 1.0);
    }
    
    float4 shading_fresnel_scale() {
        float3 n = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz;
        float3 e = normalize(-getPos());
        float r = r0 + (1 - r0)*pow(1 - dot(n, e), 2);
        return float4(r, r, r, 1.0);
    }

    float3 trace_color(float3 p, float3 d) {
        float4 world_pos = iview * float4(p, 1);
        float3 world_d = matrix_float3x3(iview.columns[0].xyz, iview.columns[1].xyz, iview.columns[2].xyz) * d;
        float t = -world_pos.z / world_d.z;
        float3 world_its = world_pos.xyz + t * world_d;

        if (t > 0 && abs(world_its.x) < 5 && abs(world_its.y) < 5) {
            float scale = 10;
            float2 uv = scale * (world_its.xy - float2(-5, -5)) / 10;
            float u = fmod(uv.x, 1), v = fmod(uv.y, 1);
            int flip = 1;
            if (u > 0.5) flip = 1 - flip;
            if (v > 0.5) flip = 1 - flip;

            if (flip == 1)
                return float3(0.8, 0.8, 0.8);
            else
                return float3(0.6, 0.6, 0.6);
        } else {
            if (hasSpecularEnv) {
                return u_skyboxTexture.sample(u_skyboxSampler, world_d).rgb;
            } else {
                return u_envMapLight.diffuse;
            }
        }
    }
    
    float4 shading_fresnel() {
        float3 n = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz;
        float3 p = getPos();
        float3 e = normalize(-p);
        float r = r0 + (1 - r0)*pow(1 - dot(n, e), 3);

        float3 view_reflect = -e + 2 * n * dot(n, e);
        float3 view_refract = -e - 0.2*n;

        float thickness = u_thickTexture.sample(u_thickSampler, texCoord).x;
        float attenuate = max(exp(0.5*-thickness), 0.2);
        float3 tint_color = float3(6, 105, 217) / 256;
        // vec3 refract_color = mix(tint_color, trace_color(p, view_refract), 0.8);
        float3 refract_color = mix(tint_color, trace_color(p, view_refract), attenuate);
        float3 reflect_color = trace_color(p, view_reflect);

        return float4(mix(refract_color, reflect_color, r), 1);
    }

    float4 shading_refract_tinted() {
        float3 n = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz;
        float3 p = getPos();
        float3 e = normalize(-p);

        float3 view_refract = -e - 0.2*n;

        float thickness = u_thickTexture.sample(u_thickSampler, texCoord).x;
        float attenuate = max(exp(0.5*-thickness), 0.2);
        float3 tint_color = float3(6, 105, 217) / 256;
        // vec3 refract_color = mix(tint_color, trace_color(p, view_refract), 0.8);
        float3 refract_color = mix(tint_color, trace_color(p, view_refract), attenuate);

        return float4(refract_color, 1);
    }
    
    float4 shading_refract() {
        float3 n = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz;
        float3 p = getPos();
        float3 e = normalize(-p);

        float3 view_refract = -e - 0.2*n;

        float3 refract_color = trace_color(p, view_refract);

        return float4(refract_color, 1);
    }

    float4 shading_reflect() {
        float3 n = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).xyz;
        float3 p = getPos();
        float3 e = normalize(-p);

        float3 view_reflect = -e + 2 * n * dot(n, e);

        float3 reflect_color = trace_color(p, view_reflect);

        return float4(reflect_color, 1);
    }
    
    float4 shading_depth() {
        float z = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).w;
        if (z > 50) discard_fragment();

        float c = exp(z)/(exp(z)+1);
        c = (c - 0.5) * 2;

        return float4(c,c,c,1);
    }

    float4 shading_thick() {
        float z = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).w;
        if (z > 50) discard_fragment();
        float t = u_thickTexture.sample(u_thickSampler, texCoord).x;

        t = exp(t) / (exp(t) + 1);
        t = (t - 0.5) * 2;

        return float4(t, t, t, 1);
    }
    
public:
    ShadingOption shading_option = depth;
    /* Schlick's approximation on Fresnel factor (reflection coef)
     * r0: Reflection coef when incoming light parallel to the normal
     * r0 = [(n1 - n2)/(n1 + n2)]^2
     */
    float r0;
    SSFData u_ssf;
    
    float2 texCoord;
    matrix_float4x4 iview;
    
    sampler u_normalDepthSampler;
    texture2d<float> u_normalDepthTexture;
    sampler u_thickSampler;
    texture2d<float> u_thickTexture;
    
    EnvMapLight u_envMapLight;
    sampler u_skyboxSampler;
    texturecube<float> u_skyboxTexture;
};

fragment fragmentOut fragment_ssf(VertexOut in [[stage_in]],
                                  constant CameraData& u_camera [[buffer(1)]],
                                  constant SSFData& u_ssf [[buffer(2)]],
                                  // texture
                                  sampler u_normalDepthSampler [[sampler(0)]],
                                  texture2d<float> u_normalDepthTexture [[texture(0)]],
                                  sampler u_thickSampler [[sampler(1)]],
                                  texture2d<float> u_thickTexture [[texture(1)]],
                                  // env
                                  constant EnvMapLight &u_envMapLight [[buffer(5)]],
                                  texturecube<float> u_env_specularTexture [[texture(2), function_constant(hasSpecularEnv)]],
                                  sampler u_env_specularSampler [[sampler(2), function_constant(hasSpecularEnv)]]) {
    ScreenSpaceFluid ssf;
    ssf.u_normalDepthSampler = u_normalDepthSampler;
    ssf.u_normalDepthTexture = u_normalDepthTexture;
    ssf.u_thickTexture = u_thickTexture;
    ssf.u_thickSampler = u_thickSampler;
    // env
    ssf.u_envMapLight = u_envMapLight;
    if (hasSpecularEnv) {
        ssf.u_skyboxTexture = u_env_specularTexture;
        ssf.u_skyboxSampler = u_env_specularSampler;
    }
    
    float n1 = 1.3333f;
    float t = (n1 - 1) / (n1 + 1);
    ssf.r0 = t * t;
    ssf.u_ssf = u_ssf;
    
    ssf.texCoord = in.v_uv;
    ssf.iview = u_camera.u_viewInvMat;
    
    ssf.shading_option = ScreenSpaceFluid::depth;
    
    return ssf.execute();
}
