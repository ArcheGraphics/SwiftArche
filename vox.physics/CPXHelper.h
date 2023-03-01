//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "PxPhysicsAPI.h"
#import <simd/simd.h>

using namespace physx;

inline PxVec3 transform(simd_float3 position) {
    return PxVec3(position.x, position.y, position.z);
}

inline PxQuat transform(simd_quatf rotation) {
    return PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w);
}

inline PxTransform transform(simd_float3 position, simd_quatf rotation) {
    return PxTransform(transform(position), transform(rotation));
}