//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
#include "type_common.h"
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
    out.v_uv = in.position.xy;
    
    return out;
}

struct fragmentOut {
    float4 color[[color(0)]];
    float depth[[depth(greater)]];
};

class ScreenSpaceFluid {
public:
    fragmentOut execute() {
        // ze to z_ndc to gl_FragDepth
        // REF: https://computergraphics.stackexchange.com/questions/6308/why-does-this-gl-fragdepth-calculation-work?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
        float ze = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).w;
        float z_ndc = proj(-ze);
        
        fragmentOut out;
        out.depth = 0.5 * (z_ndc + 1);
        int shading_option = 1;
        if (shading_option == 1)
            out.color = shading_depth();
        else if (shading_option == 2)
            out.color = shading_thick();
        else if (shading_option == 3)
            out.color = shading_normal();
        else if (shading_option == 4)
            out.color = shading_fresnel_scale();
        else if (shading_option == 5)
            out.color = shading_reflect();
        else if (shading_option == 6)
            out.color = shading_refract();
        else if (shading_option == 7)
            out.color = shading_refract_tinted();
        else
            out.color = shading_fresnel();
        
        return out;
    }
    
    float proj(float ze) {
        return (p_f + p_n) / (p_f - p_n) + 2 * p_f*p_n / ((p_f - p_n) * ze);
    }

    float3 getPos() {
        /* Return in right-hand coord */
        float z = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord).z;
        float x = texCoord.x, y = texCoord.y;
        x = (2 * x - 1)*p_r*z / p_n;
        y = (2 * y - 1)*p_t*z / p_n;
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
        }
        else
            return u_skyboxTexture.sample(u_skyboxSampler, world_d).rgb;
            // return float3(0.8, 0.8, 0.8);
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
        float r = r0 + (1 - r0)*pow(1 - dot(n, e), 3);

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
        float4 normalDepth = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord);
        float3 n = normalDepth.xyz;
        float3 p = getPos();
        float3 e = normalize(-p);
        float z = normalDepth.w;
        if (z > 50) discard_fragment();

        float c = exp(z)/(exp(z)+1);
        c = (c - 0.5) * 2;

        return float4(c,c,c,1);
    }

    float4 shading_thick() {
        float4 normalDepth = u_normalDepthTexture.sample(u_normalDepthSampler, texCoord);
        float3 n = normalDepth.xyz;
        float3 p = getPos();
        float3 e = normalize(-p);
        float z = normalDepth.w;
        if (z > 50) discard_fragment();
        float t = u_thickTexture.sample(u_thickSampler, texCoord).x;

        t = exp(t) / (exp(t) + 1);
        t = (t - 0.5) * 2;

        return float4(t, t, t, 1);
    }
    
public:
    /* Schlick's approximation on Fresnel factor (reflection coef)
     * r0: Reflection coef when incoming light parallel to the normal
     * r0 = [(n1 - n2)/(n1 + n2)]^2
     */
    float r0;
    float p_n;
    float p_f;
    float p_t;
    float p_r;
    
    float2 texCoord;
    matrix_float4x4 iview;
    
    sampler u_normalDepthSampler;
    texture2d<float> u_normalDepthTexture;
    sampler u_thickSampler;
    texture2d<float> u_thickTexture;
    sampler u_skyboxSampler;
    texturecube<float> u_skyboxTexture;
};

fragment fragmentOut fragment_ssf(VertexOut in [[stage_in]],
                                  constant matrix_float4x4& iview [[buffer(1)]],
                                  constant float& p_n [[buffer(2)]],
                                  constant float& p_f [[buffer(3)]],
                                  constant float& p_t [[buffer(4)]],
                                  constant float& p_r [[buffer(5)]],
                                  constant float& r0 [[buffer(6)]],
                                  // texture
                                  sampler u_normalDepthSampler [[sampler(0)]],
                                  texture2d<float> u_normalDepthTexture [[texture(0)]],
                                  sampler u_thickSampler [[sampler(1)]],
                                  texture2d<float> u_thickTexture [[texture(1)]],
                                  sampler u_skyboxSampler [[sampler(2)]],
                                  texturecube<float> u_skyboxTexture [[texture(2)]]) {
    ScreenSpaceFluid ssf;
    ssf.texCoord = in.v_uv;
    ssf.u_normalDepthSampler = u_normalDepthSampler;
    ssf.u_normalDepthTexture = u_normalDepthTexture;
    ssf.u_thickTexture = u_thickTexture;
    ssf.u_thickSampler = u_thickSampler;
    ssf.u_skyboxTexture = u_skyboxTexture;
    ssf.u_skyboxSampler = u_skyboxSampler;
    
    return ssf.execute();
}
