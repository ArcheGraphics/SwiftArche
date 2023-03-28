//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <metal_stdlib>
#import "../deferred/MainRendererUtilities.metal"
#import "../deferred/MainRenderer_shared.h"
#import "VegetationRenderer_shared.h"
#import "TerrainRendererUtilities.metal"
#import "TerrainRenderer_shared.h"
using namespace metal;

constant bool g_isShadowPass [[function_constant(0)]];

// Vertex-to-fragment interface for the vegetation shader
typedef struct
{
    float4 position [[position]];
    float3 color;
    float3 normal;

} VegetationVertexOut;

// Vertex shader that transforms the main camera matrix or with the auxillary, depth-only matrix for shadow cascades
vertex VegetationVertexOut vegetation_vertex(const device AAPLObjVertex* in [[ buffer(0) ]],
                                             const device float4x4* instances [[ buffer(1) ]],
                                             constant AAPLUniforms & uniforms [[ buffer(2) ]],
                                             uint vid [[vertex_id]],
                                             uint iid [[instance_id]],
                                             constant float4x4& depthOnlyMatrix[[buffer(6), function_constant(g_isShadowPass)]])
{
    VegetationVertexOut out;
    float4 position = float4(in[vid].position, 1.0);
    float4 world_pos = instances[iid] * position;

    if (g_isShadowPass)
    {
        out.position = depthOnlyMatrix * world_pos;
    }
    else
    {
        out.position    = uniforms.cameraUniforms.viewProjectionMatrix * world_pos;
        out.color       = (in[vid].color);
        out.normal      = (instances[iid] * float4(in[vid].normal, 0)).xyz;
    }
    return out;
}

// Fragment shader that renders the vegetation geometry for the deferred renderer
fragment GBufferFragOut vegetation_fragment(const VegetationVertexOut in [[stage_in]],
                                            constant AAPLUniforms& globalUniforms [[buffer(0)]])
{
    BrdfProperties b;
    b.albedo = saturate(in.color);
    b.normal = in.normal;
    b.specIntensity = 1.f;
    b.specPower = 1.f;
    b.ao = 0.f;
    b.shadow = 0.f;

    GBufferFragOut output = PackBrdfProperties(b);
#ifdef __METAL_IOS__
    output.gBufferDepth = in.position.z;
#endif
    return output;
}

// An alias of the MTLDrawIndexedPrimitivesIndirectArguments structure with an atomic instance
//  count since we are incrementing that across multiple thread/groups during spawning
typedef struct {
    uint32_t indexCount;
    atomic_int instanceCount;
    uint32_t indexStart;
    int32_t  baseVertex;
    uint32_t baseInstance;
} AtomicIndirectDrawArguments;

// Boing function to implement the "spring" effect animation when the vegetation changes
float boingEase(float f)
{
    return 1.0 - cos(20.0*f)*pow(2, f * -12.0);
}

// Helper function that adds instances to the scene from the main spawning function
// - The instance is then culled against the frustum planes for the main and shadow cameras
// - It appends an instance matrix to the correct bin for the correct population and camera where needed
void vegetationSpawnInstance(uint populationIndex, float4x4 worldMatrix, float4 boundingSphere, constant AAPLUniforms& globalUniforms, device float4x4* instances, device AtomicIndirectDrawArguments* indirect)
{
    if (dot(globalUniforms.cameraUniforms.frustumPlanes[0], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
        dot(globalUniforms.cameraUniforms.frustumPlanes[1], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
        dot(globalUniforms.cameraUniforms.frustumPlanes[2], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
        dot(globalUniforms.cameraUniforms.frustumPlanes[3], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
        dot(globalUniforms.cameraUniforms.frustumPlanes[4], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
        dot(globalUniforms.cameraUniforms.frustumPlanes[5], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w)
    {
        uint bin = GetBinFor(populationIndex, 0);
        uint instance_slot = atomic_fetch_add_explicit(&(indirect[bin].instanceCount), 1, memory_order_relaxed); // increment index to allocate matrix pos
        if (instance_slot < kMaxInstanceCount)
            instances[instance_slot + bin*kMaxInstanceCount] = worldMatrix;
        else
            atomic_fetch_sub_explicit(&(indirect[bin].instanceCount), 1, memory_order_relaxed); // bin full, rewind index
    }

    // Cull against 6 shadow camera planes
    for (uint shadow_idx = 0; shadow_idx < 3; shadow_idx++)
    {
        if (dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[0], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
            dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[1], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
            dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[2], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
            dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[3], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
            dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[4], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w &&
            dot(globalUniforms.shadowCameraUniforms[shadow_idx].frustumPlanes[5], float4(boundingSphere.xyz, 1.0)) > -boundingSphere.w)
        {
            uint bin = GetBinFor(populationIndex, 1 + shadow_idx);
            uint instance_slot = atomic_fetch_add_explicit(&(indirect[bin].instanceCount), 1, memory_order_relaxed); // increment index to allocate matrix pos
            if (instance_slot < kMaxInstanceCount)
                instances[instance_slot + bin*kMaxInstanceCount] = worldMatrix;
            else
                atomic_fetch_sub_explicit(&(indirect[bin].instanceCount), 1, memory_order_relaxed); // bin full, rewind index
        }
    }
}

// The main work-horse function for the vegetation rendering
// - generates the instances for a single frame for all cameras and populations at once
kernel void vegetation_instanceGenerate(texture2d<float> heightMap                      [[texture(0)]],
                                        texture2d<float> normalMap                      [[texture(1)]],
                                        texture2d<float> propertiesMap                  [[texture(2)]],
                                        device float4x4* instances                      [[buffer(0)]],
                                        device AtomicIndirectDrawArguments* indirect    [[buffer(1)]],
                                        constant AAPLUniforms& globalUniforms           [[buffer(2)]],
                                        constant TerrainParams& terrainParams           [[buffer(3)]],
                                        constant AAPLPopulationRule* rules              [[buffer(4)]],
                                        device  uint* history                           [[buffer(5)]],
                                         uint2 tid                                       [[thread_position_in_grid]])
{
    constexpr sampler sam(min_filter::linear, mag_filter::linear, mip_filter::none, address::clamp_to_edge, coord::normalized);

    // Initialize some random variables to get a randomized batch of vegetation
    uint rnd0 = wang_hash(tid.x + tid.y * 0xABBA);
    uint rnd1 = wang_hash(rnd0);
    float nrnd0 = (rnd0&0xFFFF)/65535.0f;
    float nrnd1 = (rnd1&0xFFFF)/65535.0f;
    float2 vrnd0(sin(float(rnd0%0xFF)), cos(float(rnd0&0xFF)));
    float2 vrnd1(sin(float(rnd1%0xFF)), cos(float(rnd1&0xFF)));

    // Generate position of new vegetation spot
    float2 uv_pos = (vrnd0*.5 + (float2(tid.xy))) / (float) kGridResolution;

    // Read height and terrain the potential location
    float sample_height = heightMap.sample(sam, uv_pos).r;
    float world_height = sample_height * TERRAIN_HEIGHT;
    float3 world_pos;
    world_pos.xz = (uv_pos - 0.5f) * TERRAIN_SCALE;
    world_pos.y = world_height;

    float habitatPercentages[TerrainHabitatTypeCOUNT];
    float3 worldNormal;

    // Determine habitat at the current position
    EvaluateTerrainAtLocation(uv_pos, world_pos, heightMap,
                              normalMap, propertiesMap, terrainParams,
                              habitatPercentages,
                              worldNormal);

    // Initialize our "chosen" type to invalid with a default scale
    uint pop_idx = kPopulationCount;
    float population_scale = 1.0f;

    // Stochastic value that will sample our distributed density. Value ranges between 0 and 1
    float s = (nrnd1);

    // Iterate throught the habitat types and reduce the value with each habitat's percentage
    // whenever `s` dips below 0, we have selected our habitat. This ensures the random choice reflects the percentages
    for (uint h = 0; h < TerrainHabitatTypeCOUNT; h++)
    {
        s -= habitatPercentages[h];

        // Crossed the 0, selected habitat
        if (s < 0)
        {
            for (uint r = 0; r < kRulesPerHabitat; r++)
            {
                // `s` is now a random negative number between the (chosen habitat percentage) and 0
                // Apply the same principle between the various rules that are defined for this habitat, again to reflect the rule densities
                uint rule_index = h*kRulesPerHabitat+r;
                s += rules[rule_index].densityInHabitat;
                if (s > 0) // crossed the 0, selected rule
                {
                    // Now we index into our population index range of the rule
                    pop_idx = rules[rule_index].populationStartIndex + uint((s / rules[rule_index].densityInHabitat * float(rules[rule_index].populationIndexCount)));

                    // Scale the chosen population by the scale defined in the rule
                    population_scale = rules[rule_index].scale;
                    break;
                }
            }
            break;
        }
    }

    // Now that we have selected a population to place for this frame, we check the history of this position and start/stop
    // a fade in/fade out animation of the asset.
    // - Our history frame contains four values:
    //      1. a fade-in population
    //      2. a fade-out population
    //      3. the frame of the animation
    //      4. the index of the animation
    if (pop_idx < kPopulationCount)
    {
        // Unpack the history buffer
        uint history_idx            = tid.x + tid.y * kGridResolution;
        uint packed_hist            = history[history_idx];
        uint fade_in_popidx         = (packed_hist&0x000000FF) >> 0;
        uint fade_in_frame          = (packed_hist&0x0000FF00) >> 8;
        uint fade_out_popidx        = (packed_hist&0x00FF0000) >> 16;
        uint fade_out_frame         = (packed_hist&0xFF000000) >> 24;

        if (fade_in_frame < 255) fade_in_frame++;
        if (fade_out_frame < 255) fade_out_frame++;

        // We swap our "old" vegetation choice for a new one
        if (fade_in_popidx != pop_idx)
        {
            // Previous vegetation was fully faded in? start fading it out
            if (fade_in_frame == 255)
            {
                fade_out_popidx     = pop_idx;
                fade_out_frame      = 0;
            }

            // Fade in new asset
            fade_in_popidx = pop_idx;
            fade_in_frame = 0;
        }

        // Pack it all into the history buffer again
        packed_hist                  = fade_in_popidx;
        packed_hist                 |= fade_in_frame << 8;
        packed_hist                 |= fade_out_popidx << 16;
        packed_hist                 |= fade_out_frame << 24;
        history[history_idx]         = packed_hist;

        // Translates frames to seconds for animations (assume 60fps)
        float fade_in_seconds        = float(fade_in_frame) / 60;
        float fade_out_seconds       = float(fade_out_frame) / 60;
        // Grow factor calculation for fade-in
        float grow_factor            = boingEase(saturate(fade_in_seconds - nrnd0*3.0));


        // Now we can start to create the main matrix which is used by the fade-in and "normal" visualisation of the mesh
        //  sample two additional height samples to create world matrix basis
        float y_s = heightMap.sample(sam, uv_pos + float2(0, 1.0/TERRAIN_SCALE)).r * TERRAIN_HEIGHT;
        float y_t = heightMap.sample(sam, uv_pos + float2(1.0/TERRAIN_SCALE, 0)).r * TERRAIN_HEIGHT;
        float3 terrain_up = -(cross(normalize(float3(1, y_s-world_height, 0)), normalize(float3(0, y_t-world_height, 1)))).zyx;

        // Simulate a little bit of wind
        // non-random for OATS tests
        float wind_speed =  0.1 + 0.4 * saturate(1.0 + (cos(GAME_TIME * 0.8 + nrnd1 * 1.0 + world_pos.z * -0.0002 + sin(world_pos.x * -0.001))));
        float windx = (1.0 + 0.2 * sin(GAME_TIME * 20.0f * (nrnd0-.5))) * wind_speed;
        float windy = (1.0 + 0.2 * cos(GAME_TIME * 20.0f * (nrnd0-.5))) * wind_speed;

        // Nudge the tree with a bit of random rotation and upwards
        float3 nudge    = float3(vrnd1.x + windy, 8.0, vrnd1.y + windx);
        float3 up       = normalize(terrain_up + nudge);

        // Rotate around the up vector
        float3 right    = normalize(cross(up, float3(vrnd0.x, 0, vrnd0.y)));
        float3 fwd      = cross(up, right);
        float4x4 world_matrix = (float4x4) {    float4(fwd*kVegetationScale*population_scale*grow_factor, 0),
            float4(up*kVegetationScale*population_scale*grow_factor, 0),
            float4(right*kVegetationScale*population_scale*grow_factor, 0),
            float4(world_pos, 1) };

        // Since the asset can grow/shrink, we adjust its bounding radius in order to cull it
        // - (we know our obj space radius is always < 2.0 for all assets)
        float radius = kVegetationScale * 2.0 * population_scale;

        // Spawn the vegetation asset
        vegetationSpawnInstance(pop_idx, world_matrix, float4(world_pos, radius), globalUniforms, instances, indirect);

        // If there is a fade-out animation present, spawn the fade-out population with a simple adjusted "tumble" matrix (it flies up and shrinks quickly)
        if (fade_out_frame < 100)
        {
            float3 tumble_pos = world_pos + float3(0, fade_out_seconds * 4000.0f, 0);
            float tumble_scale = saturate(1.0 - fade_out_seconds * 4.0);
            float4x4 tumble_world_matrix = (float4x4) {     float4(fwd*kVegetationScale*tumble_scale, 0),
                float4(up*kVegetationScale*tumble_scale, 0),
                float4(right*kVegetationScale*tumble_scale, 0),
                float4(tumble_pos, 1) };
            vegetationSpawnInstance(fade_out_popidx, tumble_world_matrix, float4(tumble_pos, radius), globalUniforms, instances, indirect);
        }
    }
}
