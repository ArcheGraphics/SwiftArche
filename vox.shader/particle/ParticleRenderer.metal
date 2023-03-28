//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <metal_stdlib>
#import <metal_atomic>
using namespace metal;
using namespace simd;

#import "../deferred/MainRenderer_shared.h"
#import "../terrian/TerrainRenderer_shared.h"
#import "../terrian/TerrainRendererUtilities.metal"
#import "ParticleRenderer_shared.h"

// This variable is set to true for the shadow pass.
// - it reduces the amount of computations done by the vertex shader and the number of varyings it exports
constant bool g_isDepthOnlyPass [[function_constant(0)]];
constant bool g_isNotDepthOnlyPass = !g_isDepthOnlyPass;

struct ParticleVertexOut
{
    float4 position [[position]];
    float3 worldPosition [[function_constant(g_isNotDepthOnlyPass)]];
    float3 normal [[function_constant(g_isNotDepthOnlyPass)]];
    float3 tangent [[function_constant(g_isNotDepthOnlyPass)]];
    float3 bitangent [[function_constant(g_isNotDepthOnlyPass)]];
    float2 uv [[function_constant(g_isNotDepthOnlyPass)]];
    int instanceId;
};

struct ParticleVertexIn
{
    half4 position;
    packed_half2 uv;
    packed_half3 normal;
    packed_half3 tangent;
    packed_half3 bitangent;
};

float3x3 rotationMatrix(float3 axis, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return float3x3(oc * axis.x * axis.x + c,
                    oc * axis.x * axis.y - axis.z * s,
                    oc * axis.z * axis.x + axis.y * s,
                    oc * axis.x * axis.y + axis.z * s,
                    oc * axis.y * axis.y + c,
                    oc * axis.y * axis.z - axis.x * s,
                    oc * axis.z * axis.x - axis.y * s,
                    oc * axis.y * axis.z + axis.x * s,
                    oc * axis.z * axis.z + c) ;
}

inline float getHeight(float3 worldPos,
                       texture2d<float> heightMap)
{
    float2 uv = WorldPosToNormPos(worldPos.xyz);
    constexpr sampler s(min_filter::linear, mag_filter::linear, mip_filter::nearest);
    return heightMap.sample(s, uv, level(0)).x*TERRAIN_HEIGHT;
}

float smoothStep(float time, float4 keyFrames, float4 keyValues)
{
    if(time < keyFrames.x) {
        return keyValues.x;
    }
    else if(time < keyFrames.y) {
        float interp = (time)/(keyFrames.y-keyFrames.x);
        return (keyValues.y-keyValues.x)*interp + keyValues.x;
    } else if(time < keyFrames.z) {
        float interp = (time - keyFrames.y)/(keyFrames.z-keyFrames.y);
        return (keyValues.z-keyValues.y)*interp + keyValues.y;
    } else if(time < keyFrames.w) {
        float interp = (time - keyFrames.z)/(keyFrames.w-keyFrames.z);
        return (keyValues.w-keyValues.z)*interp + keyValues.z;
    } else {
        return keyValues.w;
    }
}

struct ParticleData
{
    texture2d_array<float> texture;

    float3x3 orientation;
    float3x3 angularVelocity;
    float3   position;
    float3   velocity;
    float    age;
    float    scale;
    float    sphereRadius;
    float    opacity;
    uint     habitatIndex;
    uint     textureSliceIndex;

    // Cached value from the terrain IAB, to save a memory fetch in the vertex shader
    bool     castShadows;
};

constant float kRestitution = 0.5f;
constant float kFriction = 0.02f;
constant float kDrag = 0.99;

kernel void AnimateAndCleanupOldParticles
(// Pool containing particles data. Each entry might or might not be used
 //  Allocation size of MAX_PARTICLES
 device ParticleData* const    particleDataPool      [[ buffer (0) ]],

 // Indices of particles stored in particleDataPool that are alive so far (read-only)
 //  Allocation size of MAX_PARTICLES
 device const uint16_t* const  aliveIndicesList      [[ buffer (1) ]],
 constant const uint&          aliveIndicesCount     [[ buffer (2) ]],

 // Indices of particles stored in particleDataPool that are currently unused
 //  (read-write list, on which we may append indices)
 //  Allocation size of MAX_PARTICLES
 device uint16_t* const        unusedIndicesList     [[ buffer (3) ]],
 device atomic_uint* const     unusedIndicesCount    [[ buffer (4) ]],

 // Indices of particles that will still be alive at the end of the simulation
 //  Allocation size of MAX_PARTICLES
 device uint16_t* const        nextAliveIndicesList  [[ buffer (5) ]],

 // Must be set to zero
 device atomic_uint* const     nextAliveIndicesCount [[ buffer (6) ]],

 // A copy of aliveIndicesCount that is used when drawing particles
 device atomic_uint* const     drawParamsCount_CurFrame [[ buffer (7) ]],

 // The maximum amount of particles that may stay alive after the simulation
 constant const uint&          spawnCountToReserve   [[ buffer (8) ]],
 constant const AAPLUniforms&  uniforms              [[ buffer (12) ]],
 constant const TerrainParams& terrainParams         [[ buffer (14) ]],
 texture2d <float>             heightMap             [[ texture (0) ]],

 const uint3 threadPosInGrid [[ thread_position_in_grid ]],
 const uint3 threadsPerGrid  [[threads_per_grid]])
{

    if (threadPosInGrid.x >= aliveIndicesCount)
        return;

    const uint particleIndex = aliveIndicesList [threadPosInGrid.x];
    device ParticleData& particleData = particleDataPool [particleIndex];
    particleData.age += uniforms.frameTime;

    constant const TerrainHabitat::ParticleProperties& props = terrainParams.habitats[particleData.habitatIndex].particleProperties;

    const uint spaceAvailableOnRight = uint(MAX_PARTICLES)-aliveIndicesCount;
    const uint particlesToKill = (uint)max(0, (int)spawnCountToReserve - (int)spaceAvailableOnRight);
    const bool hasDied =    (particleData.age >= props.keyTimePoints.w)
    || (threadPosInGrid.x < particlesToKill);
    if (hasDied)
    {
        const uint unusedListIndex = atomic_fetch_add_explicit(unusedIndicesCount, 1, memory_order_relaxed);
        unusedIndicesList [unusedListIndex] = particleIndex;
        return;
    }

    const uint newAliveIndex = atomic_fetch_add_explicit(nextAliveIndicesCount, 1, memory_order_relaxed);
    nextAliveIndicesList [newAliveIndex] = particleIndex;
    atomic_fetch_add_explicit(drawParamsCount_CurFrame, 1, memory_order_relaxed);

    // Physics Simulation (lightweight/relaxed implementation)
    particleData.position += particleData.velocity * uniforms.frameTime;

    float terrainHeight = getHeight(particleData.position, heightMap);

    // Height map collisions in screen-space
    float overlap = terrainHeight - (particleData.position.y - particleData.sphereRadius * particleData.scale);
    if(props.doesCollide == 1)
    {
        if(overlap > 0)
        {
            // Calculating approximate world normal at point of collision
            float3 worldPos0 = particleData.position;
            worldPos0.y = terrainHeight;
            float3 worldPos1 = particleData.position + float3(1,0,0);
            worldPos1.y = getHeight(worldPos1, heightMap);
            float3 worldPos2 = particleData.position + float3(0,0,1);
            worldPos2.y = getHeight(worldPos2, heightMap);

            float3 normal = normalize(cross(worldPos2-worldPos0,worldPos1-worldPos0));
            float3 bitangent = cross(normal, particleData.velocity);
            float3 tangent;
            if (any(abs(bitangent) > float3(0.001,0.001,0.001)))
            {
                bitangent = normalize(bitangent);
                tangent = normalize(cross(normal,bitangent));
            }
            else
            {
                bitangent = float3(0,0,1);
                tangent = float3(1,0,0);
            }

            float nd = dot(particleData.velocity,normal);
            float td = dot(particleData.velocity,tangent);

            // Reflect
            if(nd < 0)
            {
                particleData.velocity = particleData.velocity - (1 + kRestitution) * nd * normal;
            }

            // Friction
            particleData.velocity = particleData.velocity - td * tangent * kFriction;

            // Remove the overlap
            particleData.position.y += overlap;

            // Base angular velocity on linear velocity during last ground contact
            float anglarVel = td / (particleData.sphereRadius * particleData.scale);
            float3 rotationAxis = cross(float3(0,1,0), particleData.velocity);
            if (all(abs(rotationAxis) < float3(0.0001, 0.0001, 0.0001)))
            {
                rotationAxis = float3(0,1,0);
            }
            else
            {
                rotationAxis = normalize(rotationAxis);
            }
            particleData.angularVelocity = rotationMatrix(rotationAxis, anglarVel * uniforms.frameTime);
        }
    }
    else
    {
        particleData.position.y = terrainHeight;
    }

    if(props.doesRotate)
    {
        particleData.orientation = particleData.angularVelocity * particleData.orientation;
    }
    particleData.velocity = (particleData.velocity + props.gravity.xyz * uniforms.frameTime) * kDrag;
    particleData.scale = smoothStep(particleData.age, props.keyTimePoints, props.scaleFactors);
    particleData.opacity = smoothStep(particleData.age, props.keyTimePoints, props.alphaFactors);
}

kernel void SpawnNewParticles(
 // Pool containing particles data. Each entry might or might not be used.
 device ParticleData* const    particleDataPool                   [[ buffer (0) ]], // allocation size of MAX_PARTICLES

 device uint&                  nextAliveIndicesCount_NextFrame    [[ buffer (2) ]],

 // Indices of particles stored in particleDataPool that are currently unused.
 // (read-write list, on which we will remove indices)
 device uint16_t* const        unusedIndicesList                  [[ buffer (3) ]], // allocation size of MAX_PARTICLES
 device atomic_uint* const     unusedIndicesCount                 [[ buffer (4) ]],

 // Indices of particles stored in particleDataPool that were alive right after the simulation
 // (named nextAliveIndicesList in AnimateAndCleanupOldParticles)
 // (read-write, we'll append indices in it)
 device uint16_t* const        aliveIndicesList                   [[ buffer (5) ]], // allocation size of MAX_PARTICLES
 device atomic_uint* const     aliveIndicesCount                  [[ buffer (6) ]],

 // Essentially a copy of aliveIndicesCount so far, used for drawing particles
 device uint&                  drawParamsCount_CurFrame           [[ buffer (7) ]],

 // Same thing, an integer that will be incremented next frame to count the number of particles to draw
 device uint&                  drawParamsCount_NextFrame          [[ buffer (10) ]],

 // An integer to set to zero. Will be used next frame as nextAliveIndicesCount in AnimateAndCleanupOldParticles
 device uint&                  dispatchTgCountNextFrame           [[ buffer (11) ]],

 constant const AAPLUniforms&  uniforms                           [[ buffer (12) ]],
 constant const TerrainParams& terrainParams                      [[ buffer (14) ]],
 constant const float4&        mouseBuffer                        [[ buffer (15) ]],
 texture2d <float>             heightMap                          [[ texture (0) ]],
 texture2d <float>             normalMap                          [[ texture (1) ]],
 texture2d <float>             propsMap                           [[ texture (2) ]],

 const uint3 threadPosInGrid [[ thread_position_in_grid ]],
 const uint3 threadsPerGrid  [[threads_per_grid]])
{

    // Thread 0 is not processing any particle but just writing out values
    if (all(threadPosInGrid == uint3(0,0,0)))
    {
        const uint totalAliveParticlesCurFrame = drawParamsCount_CurFrame + threadsPerGrid.x -1;

        drawParamsCount_CurFrame = totalAliveParticlesCurFrame;
        drawParamsCount_NextFrame = 0;
        nextAliveIndicesCount_NextFrame = 0;
        dispatchTgCountNextFrame = max(uint(1), (uint)ceil((float)totalAliveParticlesCurFrame / (float)PARTICLES_PER_THREADGROUP));
        return;
    }

    const uint unusedIndex = atomic_fetch_sub_explicit(unusedIndicesCount, 1, memory_order_relaxed) - 1;
    const uint particleIndex = unusedIndicesList [unusedIndex];
    const uint aliveIndex = atomic_fetch_add_explicit(aliveIndicesCount, 1, memory_order_relaxed);
    aliveIndicesList [aliveIndex] = particleIndex;

    constexpr float uintToUnitFloat = 1.f / uint(0xFFFFFFFF);

    uint randSeed = uint(threadPosInGrid.x) | (uint(fract(GAME_TIME)*4194303) << 10);

    randSeed = wang_hash(randSeed);
    const float randDist = pow(float(randSeed) * uintToUnitFloat, 0.5);
    randSeed = wang_hash(randSeed);
    const float randAngle = float(randSeed) * uintToUnitFloat * 2.f * 3.14159265359;
    randSeed = wang_hash(randSeed);
    const float unitFloat = float(randSeed) * uintToUnitFloat;
    const float initialRadius = unitFloat * 20.f + 10.f;
    const float initialAge = unitFloat * 0.5f;

    float3 mouseWorldPos = mouseBuffer.xyz;
    uint habitatIndex = 0;
    {
        constexpr sampler s(min_filter::linear, mag_filter::linear, mip_filter::nearest);

        float xOffset, yOffset;
        yOffset = sincos(randAngle, xOffset);

        mouseWorldPos.x += xOffset * uniforms.brushSize * 0.75 * randDist;
        mouseWorldPos.z += yOffset * uniforms.brushSize * 0.75 * randDist;

        float2 mouseUvPos = WorldPosToNormPos(mouseWorldPos.xyz);
        mouseWorldPos.y = heightMap.sample(s, mouseUvPos).x * TERRAIN_HEIGHT;

        float habitatPercentages [TerrainHabitatTypeCOUNT];
        float3 worldNormal;

        EvaluateTerrainAtLocation(mouseUvPos, mouseWorldPos, heightMap,
                                  normalMap, propsMap, terrainParams,
                                  habitatPercentages,
                                  worldNormal);

        float highestLevel = 0.f;
        for (uint i = 0; i < TerrainHabitatTypeCOUNT; i++)
        {
            if (habitatPercentages [i] > highestLevel)
            {
                highestLevel = habitatPercentages [i];
                habitatIndex = i;
            }
        }
    }

    ParticleData data;
    data.habitatIndex = habitatIndex;
    data.texture = terrainParams.habitats [habitatIndex].diffSpecTextureArray;
    data.textureSliceIndex = 0;
    data.orientation = float3x3(1,0,0, 0,1,0, 0,0,1);
    data.angularVelocity = float3x3(1,0,0, 0,1,0, 0,0,1);
    data.position = mouseWorldPos;
    data.velocity = float3(0,0,0);
    data.opacity = 1.f;
    data.age = initialAge * terrainParams.habitats [habitatIndex].particleProperties.keyTimePoints.w;
    data.scale = terrainParams.habitats [habitatIndex].particleProperties.scaleFactors.x;
    data.sphereRadius = initialRadius;
    data.castShadows = terrainParams.habitats [habitatIndex].particleProperties.castShadows;

    particleDataPool [particleIndex] = data;
}

vertex ParticleVertexOut ParticleVs(
              uint                vertexId         [[vertex_id]],
 constant     AAPLUniforms&       globalParams     [[buffer(0)]],
 const device ParticleData* const instanceParams   [[buffer(1)]],
 const device uint16_t* const     aliveIndicesList [[buffer(2)]],
              uint                instanceId       [[instance_id]],
 constant     float4x4&           depthOnlyMatrix  [[buffer(6), function_constant(g_isDepthOnlyPass)]],
 constant     ParticleVertexIn*   sandVB           [[buffer(10)]],
 constant     ParticleVertexIn*   grassVB          [[buffer(11)]],
 constant     ParticleVertexIn*   rockVB           [[buffer(12)]],
 constant     ParticleVertexIn*   snowVB           [[buffer(13)]])
{
    const uint particleIndex = aliveIndicesList [instanceId];
    device const ParticleData& params = instanceParams [particleIndex];

    ParticleVertexIn in;
    switch (params.habitatIndex)
    {
        case 0:  in = sandVB[vertexId];  break;
        case 1:  in = grassVB[vertexId]; break;
        case 2:  in = rockVB[vertexId];  break;
        default: in = snowVB[vertexId];  break;
    }

    float kModelSize = 2.0f;
    float3 objPos = (params.orientation * float4(in.position).xyz * (params.sphereRadius*params.scale*kModelSize)) + params.position;
    float3 worldPosition = objPos;

    ParticleVertexOut v_out;

    if (g_isNotDepthOnlyPass)
    {
        float3 normal = params.orientation * (float3)in.normal;
        float3 worldTangent = params.orientation * (float3)in.tangent;
        float3 worldBitangent = params.orientation * (float3)in.bitangent;

        v_out.position = globalParams.cameraUniforms.viewProjectionMatrix * float4(worldPosition, 1);
        v_out.worldPosition = worldPosition;
        v_out.normal = normal;
        v_out.tangent = worldTangent;
        v_out.bitangent = worldBitangent;
        v_out.instanceId = particleIndex;
        v_out.uv = float2(in.uv);
    } else {
        v_out.position = depthOnlyMatrix * float4(worldPosition, 1.f);
        if(! params.castShadows)
        {
            // Kill the vertex
            v_out.position.w = -1.0f;
        }
    }

    return v_out;
}

fragment GBufferFragOut ParticlePs(const ParticleVertexOut in [[stage_in]],
                                   constant AAPLUniforms &globalParams [[buffer(0)]],
                                   device const ParticleData* const instanceParams [[buffer(1)]])
{
    constexpr sampler s(min_filter::linear, mag_filter::linear, mip_filter::nearest);

    // This is a screen space matrix to shuffle the particle opacity in order to fade out smoothly
    const float4x4 bayerDitheringValues = float4x4( 0,  8,  2, 10,
                                                   12,  4, 14,  6,
                                                   3, 11,  1,  9,
                                                   15,  7, 13,  5) * (1.f/16.f);

    device const ParticleData& params = instanceParams[in.instanceId];
    float4 texColor = params.texture.sample(s, in.uv, params.textureSliceIndex);

    if (params.opacity < 1.f)
    {
        uint col = uint(in.position.x) & 3;
        uint row = uint(in.position.y) & 3;
        float thld = bayerDitheringValues [col][row];

        // - Note: we are inserting the discard invokation _AFTER_ the texture has
        // been sampled (in texColor). This is very important: when sampling a texture,
        // the current fragment thread communicates with its neighboring threads to
        // evaluate the texture derivatives. If one calls discard before sampling, it may
        // not be providing its neighbors information required for the drivatives
        // computation - making the sampling operation for others behave incorrectly.
        if (params.opacity <= thld) discard_fragment();
    }

    float3 localNormal = float3(0,0,1);
    float3x3 localToWorld = float3x3(in.tangent, in.bitangent, in.normal);

    float3 worldNormal = normalize(localToWorld * localNormal);

    BrdfProperties finalBrdf = {};
    finalBrdf.albedo = texColor.xyz;
    finalBrdf.specIntensity = texColor.w;
    finalBrdf.specPower = 2.f;
    finalBrdf.normal = worldNormal;

    GBufferFragOut output = PackBrdfProperties(finalBrdf);
#ifdef __METAL_IOS__
    output.gBufferDepth = in.position.z;
#endif
    return output;
}
