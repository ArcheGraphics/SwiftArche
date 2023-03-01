//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "PxPhysicsAPI.h"
#import <simd/simd.h>

using namespace physx;

inline PxTransform transform(simd_float3 position, simd_quatf rotation) {
    return PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w));
}
