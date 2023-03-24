//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "ShaderCommon.h"
#import "LightCullingShared.h"

constant uint2 gTileSize               [[function_constant(XFunctionConstIndexTileSize)]];

constant uint2 gDispatchSize           [[function_constant(XFunctionConstIndexDispatchSize)]];

constant bool gUseRasterizationRate    [[function_constant(XFunctionConstIndexRasterizationRate)]];

constant uint gLightCullingTileSize    [[function_constant(XFunctionConstIndexLightCullingTileSize)]];

constant uint gLightClusteringTileSize [[function_constant(XFunctionConstIndexLightClusteringTileSize)]];


struct XTileFrustum
{
    float tileMinZ;
    float tileMaxZ;
    float4 minZFrustumXY;
    float4 maxZFrustumXY;
    float4 tileBoundingSphere;
    float4 tileBoundingSphereTransparent;
};

// No additional tests for point lights
static bool isLightVisibleFine(XPointLightCullingData lightData, float4 tileBoundingSphere) { return true; }

// More accurate cone vs sphere test. Only used for spot lights.
static bool isLightVisibleFine(XSpotLightCullingData lightData, float4 tileBoundingSphere)
{
    float cosAngle = lightData.dirAndOuterAngle.w;
    float sinAngle = sqrt(1.0f - cosAngle * cosAngle);

    float3 v = tileBoundingSphere.xyz - lightData.posAndHeight.xyz;
    float vLengthSquared = length_squared(v);
    float v1Length = dot(v, lightData.dirAndOuterAngle.xyz);
    float distanceClosestPoint = cosAngle * sqrt(vLengthSquared - v1Length * v1Length) - v1Length * sinAngle;

    const bool angleCull = distanceClosestPoint > tileBoundingSphere.w;
    const bool frontCull = v1Length > tileBoundingSphere.w + lightData.posAndHeight.w;
    const bool backCull = v1Length < -tileBoundingSphere.w;
    return !(angleCull || frontCull || backCull);
}

// Tests light bounding sphere against the frustum
template<typename LightCullingData>
static bool intersectsFrustumTile(LightCullingData light, float3 lightPosView, float r, XTileFrustum frustum, bool transparent)
{
    float4 boundingSphere = transparent ? frustum.tileBoundingSphereTransparent : frustum.tileBoundingSphere;
    float3 tileCenter = boundingSphere.xyz;
    float tileMinZ = transparent ? 0.0f : frustum.tileMinZ;
    float4 minZFrustumXY = transparent ? 0.0f : frustum.minZFrustumXY;

    float3 normal = normalize(tileCenter - lightPosView.xyz);

    //Separate Axis Theorem Test - frustum OBB vs light bounding sphere
    float min_d1 = -dot(normal, lightPosView.xyz);
    float min_d2 = min_d1;
    min_d1 += min(normal.x * minZFrustumXY.x, normal.x * minZFrustumXY.y);
    min_d1 += min(normal.y * minZFrustumXY.z, normal.y * minZFrustumXY.w);
    min_d1 += normal.z * tileMinZ;
    min_d2 += min(normal.x * frustum.maxZFrustumXY.x, normal.x * frustum.maxZFrustumXY.y);
    min_d2 += min(normal.y * frustum.maxZFrustumXY.z, normal.y * frustum.maxZFrustumXY.w);
    min_d2 += normal.z * frustum.tileMaxZ;
    float min_d = min(min_d1, min_d2);

    return (min_d <= r) && isLightVisibleFine(light, boundingSphere);
}

// Culls a list of light bounding spheres against frustum planes defined by a tile.
template <typename LightDataArray, typename IndexArrayShared, typename IndexArray, typename AtomicCounter>
static void cullLightList(uint threadId,
                          uint2 blockDim,
                          uint2 groupId,
                          XTileFrustum frustum,
                          LightDataArray lightSphereBuffer,
                          constant ushort4 * coarseCulledXY,
                          IndexArray lightIndices,
                          IndexArrayShared lightIndicesTransparent,
                          AtomicCounter lightCounter,
                          AtomicCounter lightCounterTransparent,
                          uint lightCount,
                          uint maxLights)
{
    for(uint i = threadId; i < lightCount; i += blockDim.x*blockDim.y)
    {
        auto lightData = lightSphereBuffer[i];
        float3 lightPosView = lightData.posRadius.xyz;
        bool transparentFlag = lightData.posRadius.w >= 0.0;
        float r = abs(lightData.posRadius.w);

        bool inFrustumMinZ = (lightPosView.z + r) > -frustum.tileMinZ;
        bool inFrustumMaxZ = (lightPosView.z - r) < frustum.tileMaxZ;
        bool inFrustumNearZ = (lightPosView.z + r) > 0; // near camera - for transparents

        ushort4 lightMask = coarseCulledXY[i];
        if((uint)(groupId.x - lightMask.x) < lightMask.y
           && (uint)(groupId.y - lightMask.z) < lightMask.w
           && inFrustumMaxZ)
        {
            if (inFrustumMinZ)
            {
                bool visible = intersectsFrustumTile(lightData, lightPosView, r, frustum, false);
                if (visible)
                {
                    uint32_t idx = atomic_fetch_add_explicit(lightCounter, 1, metal::memory_order_relaxed);
                    if(idx + 1 < maxLights)
                        lightIndices[idx + 1] = i;
                }
            }

            if (inFrustumNearZ && transparentFlag)
            {
                bool visible = intersectsFrustumTile(lightData, lightPosView, r, frustum, true);
                if (visible)
                {
                    uint32_t idx = atomic_fetch_add_explicit(lightCounterTransparent, 1, metal::memory_order_relaxed);
                    if(idx + 1 < maxLights)
                        lightIndicesTransparent[idx + 1] = i;
                }
            }
        }
    }
}

// Reusable light culling function for a tile.
template <typename PointLightDataArray, typename SpotLightDataArray, typename IndexArray, typename IndexArrayShared, typename AtomicCounter>
static void lightCulling(uint threadId,
                         uint2 groupId,
                         uint2 blockDim,
                         XTileFrustum frustum,
                         AtomicCounter pointLightCounter,
                         AtomicCounter pointLightCounterTransparent,
                         AtomicCounter spotLightCounter,
                         AtomicCounter spotLightCounterTransparent,
                         IndexArray pointLightIndices,
                         IndexArrayShared pointLightIndicesTransparent,
                         IndexArray spotLightIndices,
                         IndexArrayShared spotLightIndicesTransparent,
                         constant XCameraParams & cameraParams,
                         PointLightDataArray pointLightBuffer,
                         SpotLightDataArray spotLightBuffer,
                         constant ushort4 * pointCoarseCulledXY,
                         constant ushort4 * spotCoarseCulledXY,
                         uint2 lightCount,
                         uint maxLights)
{

    uint pointLightCount = lightCount.x;
    cullLightList(threadId,
                  blockDim,
                  groupId,
                  frustum,
                  pointLightBuffer,
                  pointCoarseCulledXY,
                  pointLightIndices,
                  pointLightIndicesTransparent,
                  pointLightCounter,
                  pointLightCounterTransparent,
                  pointLightCount,
                  maxLights);

    uint spotLightCount = lightCount.y;
    cullLightList(threadId,
                  blockDim,
                  groupId,
                  frustum,
                  spotLightBuffer,
                  spotCoarseCulledXY,
                  spotLightIndices,
                  spotLightIndicesTransparent,
                  spotLightCounter,
                  spotLightCounterTransparent,
                  spotLightCount,
                  maxLights);
}

// Culls lights against the cluster.
// Because we are reusing the light list from tiled culling pass
// we can ignore tile XY tests and only do test for tile Z.
template <typename PointLightDataArray, typename SpotLightDataArray>
static void LightClustering(uint tileIdx,
                            float tileMinZ,
                            float tileMaxZ,
                            XTileFrustum frustum,
                            uint pointLightCount,
                            uint spotLightCount,
                            PointLightDataArray pointLightIndicesTransparent,
                            SpotLightDataArray spotLightIndicesTransparent,
                            constant XPointLightCullingData * pointLightCullingBuffer,
                            constant XSpotLightCullingData *  spotLightCullingBuffer,
                            device uint8_t * pointLightClusterIndices,
                            device uint8_t * spotLightClusterIndices)
{
    uint totalPointLights = 0;
    for(uint i = 0; i < pointLightCount; i++)
    {
        uint lightIndex = pointLightIndicesTransparent[tileIdx + i + 1];

        auto lightData = pointLightCullingBuffer[lightIndex];
        float3 lightPosView = lightData.posRadius.xyz;
        bool transparentFlag = lightData.posRadius.w >= 0.0;
        float r = abs(lightData.posRadius.w);

        bool isInsideCluster = (lightPosView.z - r <= tileMaxZ) && (lightPosView.z + r >= tileMinZ);
        if(isInsideCluster && transparentFlag)
        {
            bool visible = intersectsFrustumTile(lightData, lightPosView, r, frustum, false);
            if (visible)
            {
                uint32_t idx = totalPointLights++;
                if(idx + 1 < MAX_LIGHTS_PER_CLUSTER)
                    pointLightClusterIndices[idx + 1] = lightIndex;
            }
        }
    }

    uint totalSpotLights = 0;
    for(uint i = 0; i < spotLightCount; i++)
    {
        uint lightIndex = spotLightIndicesTransparent[tileIdx + i + 1];

        auto lightData = spotLightCullingBuffer[lightIndex];
        float3 lightPosView = lightData.posRadius.xyz;
        bool transparentFlag = lightData.posRadius.w >= 0.0;
        float r = abs(lightData.posRadius.w);

        bool isInsideCluster = (lightPosView.z - r <= tileMaxZ) && (lightPosView.z + r >= tileMinZ);
        if (isInsideCluster && transparentFlag)
        {
            bool visible = intersectsFrustumTile(lightData, lightPosView, r, frustum, false);
            if (visible)
            {
                uint32_t idx = totalSpotLights++;
                if(idx + 1 < MAX_LIGHTS_PER_CLUSTER)
                    spotLightClusterIndices[idx + 1] = lightIndex;
            }
        }
    }

    pointLightClusterIndices[0] = min(totalPointLights, (uint)MAX_LIGHTS_PER_CLUSTER-1);
    spotLightClusterIndices[0] = min(totalSpotLights, (uint)MAX_LIGHTS_PER_CLUSTER-1);
}

// Fills XTileFrustum structure with all the informations about the tile frustum
// that we need to perform culling.
XTileFrustum computeTileFrustum(constant XFrameConstants & frameData,
                                   constant XCameraParams & cameraParams,
                                   constant rasterization_rate_map_data * rrData,
                                   uint2 groupId,
                                   float tileMinZ,
                                   float tileMaxZ)
{
    float2 tileScale = float2(frameData.physicalSize) / float2(2 * gLightClusteringTileSize);

    float2 tileMinScale = float2(tileMinZ) / float2(cameraParams.projectionMatrix[0][0], cameraParams.projectionMatrix[1][1]);
    float2 tileMaxScale = float2(tileMaxZ) / float2(cameraParams.projectionMatrix[0][0], cameraParams.projectionMatrix[1][1]);

    // calculate frustum corner positions
    float2 frustumMinClipSpace = (1.0 - float2((int2)groupId.xy - 1) / tileScale.xy) * float2(-1.0, 1.0);
    float2 frustumMaxClipSpace = (1.0 - float2((int2)groupId.xy + 1) / tileScale.xy) * float2(-1.0, 1.0);

    // convert to screen space [0,1] so we can transform it if VRR is enabled
    float2 frustumMinScreenSpace = frustumMinClipSpace * float2(0.5, -0.5) + 0.5;
    float2 frustumMaxScreenSpace = frustumMaxClipSpace * float2(0.5, -0.5) + 0.5;

#if SUPPORT_RASTERIZATION_RATE
    if (gUseRasterizationRate)
    {
        rasterization_rate_map_decoder decoder(*rrData);
        frustumMinScreenSpace = decoder.map_physical_to_screen_coordinates(frustumMinScreenSpace * frameData.physicalSize) * frameData.invScreenSize;
        frustumMaxScreenSpace = decoder.map_physical_to_screen_coordinates(frustumMaxScreenSpace * frameData.physicalSize) * frameData.invScreenSize;
    }
#endif

    //back to clip space [-1, 1]
    frustumMinClipSpace = frustumMinScreenSpace * 2.0 - 1.0;
    frustumMinClipSpace.y *= -1.0;
    frustumMaxClipSpace = frustumMaxScreenSpace * 2.0 - 1.0;
    frustumMaxClipSpace.y *= -1.0;

    float4 minZFrustumXY, maxZFrustumXY;
    minZFrustumXY.xz = frustumMinClipSpace.xy;
    minZFrustumXY.yw = frustumMaxClipSpace.xy;

    maxZFrustumXY.xz = frustumMinClipSpace.xy;
    maxZFrustumXY.yw = frustumMaxClipSpace.xy;

    // Transform to view/camera space
    minZFrustumXY *= tileMinScale.xxyy;
    maxZFrustumXY *= tileMaxScale.xxyy;

    // using frustum corners calculate the bounding sphere for the tile frustum
    float3 minZcenter = { (minZFrustumXY.x + minZFrustumXY.y) / 2, (minZFrustumXY.z + minZFrustumXY.w) / 2, tileMinZ };
    float3 maxZcenter = { (maxZFrustumXY.x + maxZFrustumXY.y) / 2, (maxZFrustumXY.z + maxZFrustumXY.w) / 2, tileMaxZ };

    float3 tileCenter = (minZcenter + maxZcenter) / 2;
    float3 tileMaxOffset;
    tileMaxOffset.xy = max(abs(minZFrustumXY.xz - tileCenter.xy), abs(minZFrustumXY.yw - tileCenter.xy));
    tileMaxOffset.xy = max(abs(maxZFrustumXY.xz - tileCenter.xy), abs(maxZFrustumXY.yw - tileCenter.xy));
    tileMaxOffset.z = (tileMaxZ - tileMinZ) / 2;
    float4 tileBoundingSphere = float4(tileCenter, length(tileMaxOffset));

    //bounding sphere for transparent objects with minZ = 0
    tileCenter = (maxZcenter) / 2;
    tileMaxOffset.xy = max(abs(tileCenter.xy), abs(tileCenter.xy));
    tileMaxOffset.xy = max(abs(maxZFrustumXY.xz - tileCenter.xy), abs(maxZFrustumXY.yw - tileCenter.xy));
    tileMaxOffset.z = (tileMaxZ) / 2;

    float4 tileBoundingSphereTransparent = float4(tileCenter, length(tileMaxOffset));

    return { tileMinZ, tileMaxZ, minZFrustumXY, maxZFrustumXY, tileBoundingSphere, tileBoundingSphereTransparent };
}

// Kernel that reads the list of lights from tiled culling light pass
// and culls each light against the cluster.
// Each thread processes one cluster.
kernel void traditionalLightClustering(uint3 coordinates        [[thread_position_in_grid]],
                                       uint3 outputSize         [[threadgroups_per_grid]],
                                       constant rasterization_rate_map_data * rrData                [[buffer(XBufferIndexRasterizationRateMap),function_constant(gUseRasterizationRate)]],
                                       device uint8_t * pointLightClusterIndices                    [[buffer(XBufferIndexPointLightIndices)]],
                                       constant uint8_t * pointLightIndicesTransparent              [[buffer(XBufferIndexTransparentPointLightIndices)]],
                                       device uint8_t * spotLightClusterIndices                     [[buffer(XBufferIndexSpotLightIndices)]],
                                       constant uint8_t * spotLightIndicesTransparent               [[buffer(XBufferIndexTransparentSpotLightIndices)]],
                                       constant XFrameConstants & frameData                      [[buffer(XBufferIndexFrameData)]],
                                       constant XCameraParams & cameraParams                     [[buffer(XBufferIndexCameraParams)]],
                                       constant XPointLightCullingData * pointLightCullingBuffer [[buffer(XBufferIndexPointLights)]],
                                       constant XSpotLightCullingData * spotLightCullingBuffer   [[buffer(XBufferIndexSpotLights)]],
                                       constant uint2 & lightCount                                  [[buffer(XBufferIndexLightCount)]])
{
    uint outputIdx = (coordinates.x + coordinates.y * outputSize.x + coordinates.z * outputSize.x * outputSize.y) * MAX_LIGHTS_PER_CLUSTER;

    uint tileIdx = (coordinates.x + outputSize.x * coordinates.y) * MAX_LIGHTS_PER_TILE;

#if LOCAL_LIGHT_SCATTERING
    float tileMinZ = scatterSliceToZ(coordinates.z);
    float tileMaxZ = scatterSliceToZ(coordinates.z + 1);
#else
    float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
    float tileMinZ = depthStep * coordinates.z;
    float tileMaxZ = depthStep * (coordinates.z + 1);
#endif

    pointLightClusterIndices += outputIdx;
    spotLightClusterIndices += outputIdx;

    XTileFrustum frustum = computeTileFrustum(frameData, cameraParams,
                                             gUseRasterizationRate ? rrData : nullptr,
                                             coordinates.xy, tileMinZ, tileMaxZ);

    uint pointLightCount = pointLightIndicesTransparent[tileIdx];
    uint spotLightCount = spotLightIndicesTransparent[tileIdx];

    LightClustering(tileIdx,
                    tileMinZ,
                    tileMaxZ,
                    frustum,
                    pointLightCount,
                    spotLightCount,
                    pointLightIndicesTransparent,
                    spotLightIndicesTransparent,
                    pointLightCullingBuffer,
                    spotLightCullingBuffer,
                    pointLightClusterIndices,
                    spotLightClusterIndices);

}

// Compute kernel to perform light culling to device memory buffers using the
//  depth from the depth buffer.
kernel void traditionalLightCulling(uint2 coordinates        [[thread_position_in_grid]],
                                    uint threadId            [[thread_index_in_threadgroup]],
                                    uint2 groupId            [[threadgroup_position_in_grid]],
                                    uint2 outputSize         [[threadgroups_per_grid]],
                                    uint2 blockDim           [[threads_per_threadgroup]],
                                    uint quadLaneId          [[thread_index_in_quadgroup]],

                                    device uint8_t * pointLightIndices                           [[buffer(XBufferIndexPointLightIndices)]],
                                    device uint8_t * pointLightIndicesTransparent                [[buffer(XBufferIndexTransparentPointLightIndices)]],
                                    device uint8_t * spotLightIndices                            [[buffer(XBufferIndexSpotLightIndices)]],
                                    device uint8_t * spotLightIndicesTransparent                 [[buffer(XBufferIndexTransparentSpotLightIndices)]],
                                    constant XFrameConstants & frameData                      [[buffer(XBufferIndexFrameData)]],
                                    constant XCameraParams & cameraParams                     [[buffer(XBufferIndexCameraParams)]],
                                    constant XPointLightCullingData * pointLightCullingBuffer [[buffer(XBufferIndexPointLights)]],
                                    constant XSpotLightCullingData * spotLightCullingBuffer   [[buffer(XBufferIndexSpotLights)]],
                                    constant uint2 & lightCount                                  [[buffer(XBufferIndexLightCount)]],
                                    constant rasterization_rate_map_data * rrData                [[buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate)]],
                                    constant ushort4 * pointCoarseCulledXY                       [[buffer(XBufferIndexPointLightCoarseCullingData)]],
                                    constant ushort4 * spotCoarseCulledXY                        [[buffer(XBufferIndexSpotLightCoarseCullingData)]],
                                    depth2d<float, access::read> depthTexture                    [[texture(0)]])
{
#if TARGET_OS_IPHONE
    float z = depthTexture.read(coordinates);
    float depth = dot(float2(z,1), cameraParams.invProjZ.xz) / dot(float2(z,1), cameraParams.invProjZ.yw);
#else
    float4 zs;
    zs.x = depthTexture.read(coordinates*2 + uint2(0,0));
    zs.y = depthTexture.read(coordinates*2 + uint2(1,0));
    zs.z = depthTexture.read(coordinates*2 + uint2(0,1));
    zs.w = depthTexture.read(coordinates*2 + uint2(1,1));

    float4 depths;
    depths.x =  dot(float2(zs.x,1), cameraParams.invProjZ.xz) / dot(float2(zs.x,1), cameraParams.invProjZ.yw);
    depths.y =  dot(float2(zs.y,1), cameraParams.invProjZ.xz) / dot(float2(zs.y,1), cameraParams.invProjZ.yw);
    depths.z =  dot(float2(zs.z,1), cameraParams.invProjZ.xz) / dot(float2(zs.z,1), cameraParams.invProjZ.yw);
    depths.w =  dot(float2(zs.w,1), cameraParams.invProjZ.xz) / dot(float2(zs.w,1), cameraParams.invProjZ.yw);

    float4 minDepths = depths;
    minDepths.xy = min(minDepths.xy, minDepths.zw);
    float minDepth = min(minDepths.x, minDepths.y);

    float4 maxDepths = depths;
    maxDepths.xy = max(maxDepths.xy, maxDepths.zw);
    float maxDepth = max(maxDepths.x, maxDepths.y);
#endif

    uint outputIdx = (groupId.x + groupId.y * outputSize.x) * MAX_LIGHTS_PER_TILE;

    threadgroup atomic_uint pointLightIndex;
    threadgroup atomic_uint pointLightIndexTransparent;
    threadgroup atomic_uint spotLightIndex;
    threadgroup atomic_uint spotLightIndexTransparent;

    threadgroup atomic_uint atomicMinZ;
    threadgroup atomic_uint atomicMaxZ;

    atomic_store_explicit(&pointLightIndex, 0, metal::memory_order_relaxed);
    atomic_store_explicit(&pointLightIndexTransparent, 0, metal::memory_order_relaxed);
    atomic_store_explicit(&spotLightIndex, 0, metal::memory_order_relaxed);
    atomic_store_explicit(&spotLightIndexTransparent, 0, metal::memory_order_relaxed);

    atomic_store_explicit(&atomicMinZ, 0x7F7FFFFF, metal::memory_order_relaxed);
    atomic_store_explicit(&atomicMaxZ, 0, metal::memory_order_relaxed);

    threadgroup_barrier(mem_flags::mem_threadgroup);

#if TARGET_OS_IPHONE
    // Determine the min and max depth in the quad group.  Note that quad groups execute in step,
    //  so barriers are unnecessary to determine the min and max depth value in the group.

    float minDepth = depth;
    minDepth = min(minDepth, quad_shuffle_xor(minDepth, 2));
    minDepth = min(minDepth, quad_shuffle_xor(minDepth, 1));

    float maxDepth = depth;
    maxDepth = max(maxDepth, quad_shuffle_xor(maxDepth, 2));
    maxDepth = max(maxDepth, quad_shuffle_xor(maxDepth, 1));

    // For one quad lane...
    if (quadLaneId == 0)
    {
        // ...compare vs every other depth value of eadh quad in the threadgroups and set the min
        // and/or max value of the current quad if it is less than/greater than other quads in the
        // tile.
        atomic_fetch_min_explicit(&atomicMinZ, as_type<uint>(minDepth), memory_order_relaxed);
        atomic_fetch_max_explicit(&atomicMaxZ, as_type<uint>(maxDepth), memory_order_relaxed);
    }

#else
    atomic_fetch_min_explicit(&atomicMinZ, as_type<uint>(minDepth), memory_order_relaxed);
    atomic_fetch_max_explicit(&atomicMaxZ, as_type<uint>(maxDepth), memory_order_relaxed);
#endif

    threadgroup_barrier(mem_flags::mem_threadgroup);

    float tileMinZ = as_type<float>(atomic_load_explicit(&atomicMinZ, memory_order_relaxed));
    float tileMaxZ = as_type<float>(atomic_load_explicit(&atomicMaxZ, memory_order_relaxed));

    XTileFrustum frustum = computeTileFrustum(frameData, cameraParams,
                                             gUseRasterizationRate ? rrData : nullptr,
                                             groupId, tileMinZ, tileMaxZ);

    pointLightIndices += outputIdx;
    pointLightIndicesTransparent += outputIdx;
    spotLightIndices += outputIdx;
    spotLightIndicesTransparent += outputIdx;

    lightCulling(threadId,
                 groupId,
                 blockDim,
                 frustum,
                 &pointLightIndex,
                 &pointLightIndexTransparent,
                 &spotLightIndex,
                 &spotLightIndexTransparent,
                 pointLightIndices,
                 pointLightIndicesTransparent,
                 spotLightIndices,
                 spotLightIndicesTransparent,
                 cameraParams,
                 pointLightCullingBuffer,
                 spotLightCullingBuffer,
                 pointCoarseCulledXY,
                 spotCoarseCulledXY,
                 lightCount,
                 MAX_LIGHTS_PER_TILE);

    threadgroup_barrier( mem_flags::mem_none );

    uint totalPointLights = atomic_load_explicit(&pointLightIndex, memory_order_relaxed);
    pointLightIndices[0] = min(totalPointLights, (uint)MAX_LIGHTS_PER_TILE-1);

    uint totalPointLightsTransparent = atomic_load_explicit(&pointLightIndexTransparent, memory_order_relaxed);
    pointLightIndicesTransparent[0] = min(totalPointLightsTransparent, (uint)MAX_LIGHTS_PER_TILE-1);

    uint totalSpotLights = atomic_load_explicit(&spotLightIndex, memory_order_relaxed);
    spotLightIndices[0] = min(totalSpotLights, (uint)MAX_LIGHTS_PER_TILE-1);

    uint totalSpotLightsTransparent = atomic_load_explicit(&spotLightIndexTransparent, memory_order_relaxed);
    spotLightIndicesTransparent[0] = min(totalSpotLightsTransparent, (uint)MAX_LIGHTS_PER_TILE-1);
}

//------------------------------------------------------------------------------

#if SUPPORT_LIGHT_CULLING_TILE_SHADERS

// Helper to combine [min, max] depth bounds.
static float2 combineDepthBounds(float2 bounds0, float2 bounds1)
{
    return float2(min(bounds0.x, bounds1.x), max(bounds0.y, bounds1.y));
}

// Initializes threadgroup storage for the tile.
kernel void tileInit(threadgroup float *atomicMinMaxZ                     [[ threadgroup(XTileThreadgroupIndexDepthBounds) ]],
                     threadgroup atomic_uint *lightCounts                 [[ threadgroup(XTileThreadgroupIndexLightCounts) ]])
{
    atomicMinMaxZ[0] = FLT_MAX;
    atomicMinMaxZ[1] = 0.0f;

    atomic_store_explicit(&lightCounts[0], 0, memory_order_relaxed);
    atomic_store_explicit(&lightCounts[1], 0, memory_order_relaxed);
    atomic_store_explicit(&lightCounts[2], 0, memory_order_relaxed);
    atomic_store_explicit(&lightCounts[3], 0, memory_order_relaxed);
}

// Calculates the depth bounds for the tile.
//  Reads depth data from the imageblock from a previous pass.
kernel void tileDepthBounds(imageblock<DepthData> img_blk,
                            ushort2 tile_coord                       [[ thread_position_in_threadgroup ]],
                            uint qid                                 [[ thread_index_in_quadgroup ]],
                            uint2 groupId                            [[ threadgroup_position_in_grid ]],
                            ushort2 blockDim                         [[ threads_per_threadgroup ]],
                            constant XCameraParams & cameraParams [[ buffer(XBufferIndexCameraParams) ]],
                            threadgroup atomic_uint *atomicMinMaxZ   [[ threadgroup(XTileThreadgroupIndexDepthBounds) ]]
                            )
{
    float2 bounds;

    for (ushort y = 0; y < gTileSize.y; y += gDispatchSize.y)
    {
        for (ushort x = 0; x < gTileSize.x; x += gDispatchSize.x)
        {
            float z = img_blk.read(tile_coord + ushort2(x, y)).depth;

            if (!x && !y)
                bounds = float2(z);
            else
                bounds = combineDepthBounds(bounds, float2(z));
        }
    }

    bounds = combineDepthBounds(bounds, quad_shuffle_down(bounds, 2));
    bounds = combineDepthBounds(bounds, quad_shuffle_down(bounds, 1));

    // accumulate into tile variable
    if (!qid)
    {
        bounds.x = linearizeDepth(cameraParams, bounds.x);
        bounds.y = linearizeDepth(cameraParams, bounds.y);

        uint2 boundsAsUint = as_type<uint2>(bounds);
        atomic_fetch_min_explicit(atomicMinMaxZ + 0, boundsAsUint.x, memory_order_relaxed);
        atomic_fetch_max_explicit(atomicMinMaxZ + 1, boundsAsUint.y, memory_order_relaxed);
    }
}

#if SUPPORT_DEPTH_DOWNSAMPLE_TILE_SHADER
kernel void tileDepthDownsample(imageblock<DepthData> img_blk,
                                ushort2 tile_coord                              [[ thread_position_in_threadgroup ]],
                                ushort2 coordinates                             [[ thread_position_in_grid ]],
                                uint qid                                        [[ thread_index_in_quadgroup ]],

                                texture2d<float, access::write> depthTexture    [[texture(0)]]
                                )
{
    for (ushort y = 0; y < gTileSize.y; y += gDispatchSize.y)
    {
        for (ushort x = 0; x < gTileSize.x; x += gDispatchSize.x)
        {
            float z = img_blk.read(tile_coord + ushort2(x, y)).depth;

            z = max(z, quad_shuffle_down(z, 2));
            z = max(z, quad_shuffle_down(z, 1));
            if (!qid)
                depthTexture.write(float4(z), (coordinates + ushort2(x, y))/2);
        }
    }
}
#endif

// Performs light culling using the depth bounds calculated for the tile,
//  writing the light lists back to the tile for future shaders.
kernel void tileLightCulling(uint threadId                  [[ thread_index_in_threadgroup ]],
                             uint2 groupId                  [[ threadgroup_position_in_grid ]],
                             ushort2 blockDim               [[ threads_per_threadgroup ]],
                             uint2 outputSize               [[ threadgroups_per_grid ]],

                             device uint8_t * pointLightIndices                     [[ buffer(XBufferIndexPointLightIndices) ]],
                             device uint8_t * pointLightIndicesTransparent          [[ buffer(XBufferIndexTransparentPointLightIndices) ]],
                             device uint8_t * spotLightIndices                      [[ buffer(XBufferIndexSpotLightIndices) ]],
                             device uint8_t * spotLightIndicesTransparent           [[ buffer(XBufferIndexTransparentSpotLightIndices) ]],
                             constant XFrameConstants & frameData                [[ buffer(XBufferIndexFrameData) ]],
                             constant XCameraParams & cameraParams               [[ buffer(XBufferIndexCameraParams) ]],
                             constant XPointLightCullingData * pointLightBuffer  [[ buffer(XBufferIndexPointLights) ]],
                             constant XSpotLightCullingData * spotLightBuffer    [[ buffer(XBufferIndexSpotLights) ]],
                             constant uint2 & lightCount                            [[ buffer(XBufferIndexLightCount) ]],
                             constant rasterization_rate_map_data * rrData          [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],

                             constant ushort4 * pointCoarseCulledXY                 [[buffer(XBufferIndexPointLightCoarseCullingData)]],
                             constant ushort4 * spotCoarseCulledXY                  [[buffer(XBufferIndexSpotLightCoarseCullingData)]],

                             threadgroup const atomic_uint *atomicMinMaxZ   [[ threadgroup(XTileThreadgroupIndexDepthBounds) ]],
                             threadgroup atomic_uint *lightCounts           [[ threadgroup(XTileThreadgroupIndexLightCounts) ]]
                             )
{
    uint outputIdx = (groupId.x + groupId.y * outputSize.x) * MAX_LIGHTS_PER_TILE;

    float tileMinZ = as_type<float>(atomic_load_explicit(atomicMinMaxZ + 0, memory_order_relaxed));
    float tileMaxZ = as_type<float>(atomic_load_explicit(atomicMinMaxZ + 1, memory_order_relaxed));

    XTileFrustum frustum = computeTileFrustum(frameData, cameraParams,
                                             gUseRasterizationRate ? rrData : nullptr,
                                             groupId, tileMinZ, tileMaxZ);

    pointLightIndices               += outputIdx;
    pointLightIndicesTransparent    += outputIdx;
    spotLightIndices                += outputIdx;
    spotLightIndicesTransparent     += outputIdx;

    lightCulling(threadId,
                 groupId,
                 (uint2)blockDim,
                 frustum,
                 &lightCounts[0],
                 &lightCounts[1],
                 &lightCounts[2],
                 &lightCounts[3],
                 pointLightIndices,
                 pointLightIndicesTransparent,
                 spotLightIndices,
                 spotLightIndicesTransparent,
                 cameraParams,
                 pointLightBuffer,
                 spotLightBuffer,
                 pointCoarseCulledXY,
                 spotCoarseCulledXY,
                 lightCount,
                 MAX_LIGHTS_PER_TILE);

    threadgroup_barrier( mem_flags::mem_none );

    pointLightIndices[0]            = min((uint8_t)atomic_load_explicit(&lightCounts[0], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
    pointLightIndicesTransparent[0] = min((uint8_t)atomic_load_explicit(&lightCounts[1], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
    spotLightIndices[0]             = min((uint8_t)atomic_load_explicit(&lightCounts[2], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
    spotLightIndicesTransparent[0]  = min((uint8_t)atomic_load_explicit(&lightCounts[3], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
}

kernel void tileLightCullingHierarchical(uint threadId                  [[ thread_index_in_threadgroup ]],
                                         uint2 groupId                  [[ threadgroup_position_in_grid ]],
                                         ushort2 blockDim               [[ threads_per_threadgroup ]],
                                         uint2 outputSize               [[ threadgroups_per_grid ]],

                                         device uint8_t * pointLightIndices                     [[ buffer(XBufferIndexPointLightIndices) ]],
                                         device uint8_t * spotLightIndices                      [[ buffer(XBufferIndexSpotLightIndices) ]],
                                         constant XFrameConstants & frameData                [[ buffer(XBufferIndexFrameData) ]],
                                         constant XCameraParams & cameraParams               [[ buffer(XBufferIndexCameraParams) ]],
                                         constant XPointLightCullingData * pointLightBuffer  [[ buffer(XBufferIndexPointLights) ]],
                                         constant XSpotLightCullingData * spotLightBuffer    [[ buffer(XBufferIndexSpotLights) ]],
                                         constant uint2 & lightCount                            [[ buffer(XBufferIndexLightCount) ]],
                                         constant rasterization_rate_map_data * rrData          [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],
                                         constant ushort4 * pointCoarseCulledXY                 [[ buffer(XBufferIndexPointLightCoarseCullingData) ]],
                                         constant ushort4 * spotCoarseCulledXY                  [[ buffer(XBufferIndexSpotLightCoarseCullingData) ]],

                                         threadgroup const atomic_uint *atomicMinMaxZ               [[ threadgroup(XTileThreadgroupIndexDepthBounds) ]],
                                         threadgroup atomic_uint *lightCounts                       [[ threadgroup(XTileThreadgroupIndexLightCounts) ]],
                                         threadgroup uint8_t     *pointLightIndicesTransparent      [[ threadgroup(XTileThreadgroupIndexTransparentPointLights)]],
                                         threadgroup uint8_t     *spotLightIndicesTransparent       [[ threadgroup(XTileThreadgroupIndexTransparentSpotLights)]])
{
    uint outputIdx = (groupId.x + groupId.y * outputSize.x) * MAX_LIGHTS_PER_TILE;

    float tileMinZ = as_type<float>(atomic_load_explicit(atomicMinMaxZ + 0, memory_order_relaxed));
    float tileMaxZ = as_type<float>(atomic_load_explicit(atomicMinMaxZ + 1, memory_order_relaxed));

    XTileFrustum frustum = computeTileFrustum(frameData, cameraParams,
                                             gUseRasterizationRate ? rrData : nullptr,
                                             groupId, tileMinZ, tileMaxZ);

    pointLightIndices               += outputIdx;
    spotLightIndices                += outputIdx;

    lightCulling(threadId,
                 groupId,
                 (uint2)blockDim,
                 frustum,
                 &lightCounts[0],
                 &lightCounts[1],
                 &lightCounts[2],
                 &lightCounts[3],
                 pointLightIndices,
                 pointLightIndicesTransparent,
                 spotLightIndices,
                 spotLightIndicesTransparent,
                 cameraParams,
                 pointLightBuffer,
                 spotLightBuffer,
                 pointCoarseCulledXY,
                 spotCoarseCulledXY,
                 lightCount,
                 MAX_LIGHTS_PER_TILE);

    threadgroup_barrier( mem_flags::mem_none );

    pointLightIndices[0]            = min((uint8_t)atomic_load_explicit(&lightCounts[0], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
    spotLightIndices[0]             = min((uint8_t)atomic_load_explicit(&lightCounts[2], memory_order_relaxed), (uint8_t)(MAX_LIGHTS_PER_TILE-1));
}

// Tile shader that reads the list of lights from tiled culling light pass
// and culls each light against the cluster.
// Each thread processes one cluster.
kernel void tileLightClustering(uint threadId                 [[ thread_index_in_threadgroup ]],
                                uint2 groupId                 [[ threadgroup_position_in_grid ]],
                                uint2 outputSize              [[ threadgroups_per_grid ]],

                                device uint8_t * pointLightClusterIndices                       [[ buffer(XBufferIndexPointLightIndices) ]],
                                device uint8_t * spotLightClusterIndices                        [[ buffer(XBufferIndexSpotLightIndices) ]],
                                constant XFrameConstants & frameData                         [[ buffer(XBufferIndexFrameData) ]],
                                constant XCameraParams & cameraParams                        [[ buffer(XBufferIndexCameraParams) ]],
                                constant XPointLightCullingData * pointLightCullingBuffer    [[ buffer(XBufferIndexPointLights) ]],
                                constant XSpotLightCullingData * spotLightCullingBuffer      [[ buffer(XBufferIndexSpotLights) ]],
                                constant rasterization_rate_map_data * rrData                   [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],
                                threadgroup const atomic_uint *atomicMinMaxZ                    [[ threadgroup(XTileThreadgroupIndexDepthBounds) ]],
                                threadgroup const atomic_uint *lightCounts                      [[ threadgroup(XTileThreadgroupIndexLightCounts) ]],
                                threadgroup const uint8_t     *pointLightIndicesTransparent     [[ threadgroup(XTileThreadgroupIndexTransparentPointLights)]],
                                threadgroup const uint8_t     *spotLightIndicesTransparent      [[ threadgroup(XTileThreadgroupIndexTransparentSpotLights)]])
{
    uint cluster = threadId;
    uint outputIdx = (groupId.x + groupId.y * outputSize.x + cluster * outputSize.x * outputSize.y) * MAX_LIGHTS_PER_CLUSTER;

#if LOCAL_LIGHT_SCATTERING
    float tileMinZ = scatterSliceToZ(cluster);
    float tileMaxZ = scatterSliceToZ(cluster + 1);
#else
    float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
    float tileMinZ = depthStep * cluster;
    float tileMaxZ = depthStep * (cluster + 1);
#endif

    pointLightClusterIndices += outputIdx;
    spotLightClusterIndices += outputIdx;

    XTileFrustum frustum = computeTileFrustum(frameData, cameraParams,
                                             gUseRasterizationRate ? rrData : nullptr,
                                             groupId, tileMinZ, tileMaxZ);

    uint pointLightCount = atomic_load_explicit(&lightCounts[1], memory_order_relaxed);
    uint spotLightCount = atomic_load_explicit(&lightCounts[3], memory_order_relaxed);

    LightClustering(0,
                    tileMinZ,
                    tileMaxZ,
                    frustum,
                    pointLightCount,
                    spotLightCount,
                    pointLightIndicesTransparent,
                    spotLightIndicesTransparent,
                    pointLightCullingBuffer,
                    spotLightCullingBuffer,
                    pointLightClusterIndices,
                    spotLightClusterIndices);

}

#endif // SUPPORT_LIGHT_CULLING_TILE_SHADERS

// Culls a set of lights against tiles using the projected bounds of the
//  bounding sphere of the light.
template <typename LightCullingData>
void LightCoarseCulling(uint threadId,
                        constant XFrameConstants&   frameData,
                        constant XCameraParams&     cameraParams,
                        constant LightCullingData*     lightSphereBuffer,
                        constant rasterization_rate_map_data* rrData,
                        uint                           lightCount,
                        float                          nearPlane,
                        device ushort4*                culledBounds)
{
    for(uint i = threadId ; i < lightCount ; i += 64)
    {
        float4 lightData = lightSphereBuffer[i].posRadius;
        float3 lightPosView = lightData.xyz;
        float r = abs(lightData.w);

        float2 tileDims = float2(frameData.physicalSize) / float2(gLightCullingTileSize);

        ushort4 result = ushort4(0);
        bool inFrustumMinZ = (lightPosView.z + r) > 0;
        if(inFrustumMinZ)
        {
            XBox2D projectedBounds = getBoundingBox(lightPosView.xyz, r, nearPlane, cameraParams.projectionMatrix);

            float2 boxMin = projectedBounds.min();
            float2 boxMax = projectedBounds.max();

            if(boxMin.x < boxMax.x && boxMin.y < boxMax.y
               && boxMin.x <  1.0f
               && boxMin.y <  1.0f
               && boxMax.x > -1.0f
               && boxMax.y > -1.0f
               )
            {
                boxMin = saturate(boxMin * 0.5f + 0.5f);
                boxMax = saturate(boxMax * 0.5f + 0.5f);

#if SUPPORT_RASTERIZATION_RATE
                if (gUseRasterizationRate)
                {
                    // The screen UV coordinates have to be mapped to physical tiles, as that is where we will do lighting.
                    rasterization_rate_map_decoder decoder(*rrData);
                    boxMin = decoder.map_screen_to_physical_coordinates(boxMin * frameData.screenSize) * frameData.invPhysicalSize;
                    boxMax = decoder.map_screen_to_physical_coordinates(boxMax * frameData.screenSize) * frameData.invPhysicalSize;
                }
#endif

                result.x = boxMin.x * tileDims.x;
                result.y = ceil(boxMax.x * tileDims.x) - result.x;
                result.z = boxMin.y * tileDims.y;
                result.w = ceil(boxMax.y * tileDims.y) - result.z;
            }
        }

        culledBounds[i] = result;
    }
}

// XY culls spot lights based on bounding sphere.
kernel void kernelSpotLightCoarseCulling(uint threadId                                         [[thread_index_in_threadgroup]],
                                         constant XFrameConstants & frameData               [[buffer(XBufferIndexFrameData)]],
                                         constant XCameraParams & cameraParams              [[buffer(XBufferIndexCameraParams)]],
                                         constant float & nearPlane                            [[buffer(XBufferIndexNearPlane)]],
                                         constant XSpotLightCullingData * cullingData       [[buffer(XBufferIndexSpotLights)]],
                                         constant uint & lightCount                            [[buffer(XBufferIndexLightCount)]],
                                         constant rasterization_rate_map_data * rrData         [[buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate)]],
                                         device ushort4 *culledBounds                          [[buffer(XBufferIndexSpotLightCoarseCullingData)]])
{
    LightCoarseCulling(threadId,
                       frameData,
                       cameraParams,
                       cullingData,
                       gUseRasterizationRate ? rrData : nullptr,
                       lightCount,
                       nearPlane,
                       culledBounds);
}

// XY culls points lights based on bounding sphere.
kernel void kernelPointLightCoarseCulling(uint threadId                                        [[thread_index_in_threadgroup]],
                                          constant XFrameConstants & frameData              [[buffer(XBufferIndexFrameData)]],
                                          constant XCameraParams & cameraParams             [[buffer(XBufferIndexCameraParams)]],
                                          constant float & nearPlane                           [[buffer(XBufferIndexNearPlane)]],
                                          constant XPointLightCullingData * cullingData     [[buffer(XBufferIndexPointLights)]],
                                          constant uint & lightCount                           [[buffer(XBufferIndexLightCount)]],
                                          constant rasterization_rate_map_data * rrData        [[buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate)]],
                                          device ushort4 *culledBounds                         [[buffer(XBufferIndexPointLightCoarseCullingData)]])
{
    LightCoarseCulling(threadId,
                       frameData,
                       cameraParams,
                       cullingData,
                       gUseRasterizationRate ? rrData : nullptr,
                       lightCount,
                       nearPlane,
                       culledBounds);
}
