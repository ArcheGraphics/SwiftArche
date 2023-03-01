//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxBoxGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"
#include "CPXHelper.h"

using namespace physx;

@implementation CPxBoxGeometry {
}

// MARK: - Initialization

- (instancetype)initWithHx:(float)hx hy:(float)hy hz:(float)hz {
    self = [super initWithGeometry:new PxBoxGeometry(hx, hy, hz)];
    return self;
}

- (void)setHalfExtents:(simd_float3)halfExtents {
    static_cast<PxBoxGeometry *>(super.c_geometry)->halfExtents = transform(halfExtents);
}

- (simd_float3)halfExtents {
    PxVec3 e = static_cast<PxBoxGeometry *>(super.c_geometry)->halfExtents;
    return simd_make_float3(e.x, e.y, e.z);
}

@end
