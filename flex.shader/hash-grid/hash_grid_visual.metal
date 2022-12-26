//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "hash_grid.h"
#include "../type_common.h"

struct Callback {
    device uint* u_neighbors;
    int idx = 0;

    void operator()(uint idx, float3 origin, uint index, float3 p) {
        u_neighbors[idx++] = index;
    }
};

kernel void visualHashGrid(device uint* u_startIndexTable [[buffer(0)]],
                           device uint* u_endIndexTable [[buffer(1)]],
                           device float2* u_sortedIndices [[buffer(2)]],
                           constant HashGridData& u_hashGridData [[buffer(3)]],
                           device float3* u_points [[buffer(4)]],
                           device float3* u_origins [[buffer(5)]],
                           device uint* u_neighbors [[buffer(6)]],
                           uint3 tpig [[ thread_position_in_grid ]]) {
    Callback callback;
    callback.u_neighbors = u_neighbors;
    PointHashGridSearcher::ForEachNearbyPointFunc<Callback> searcher(10.0, u_hashGridData.gridSpacing,
                                                                     uint3(u_hashGridData.resolutionX, u_hashGridData.resolutionY, u_hashGridData.resolutionZ),
                                                                     u_startIndexTable, u_endIndexTable, u_sortedIndices, u_points, u_origins, callback);
    searcher(0);
}
