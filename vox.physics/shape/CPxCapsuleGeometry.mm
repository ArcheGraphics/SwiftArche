//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxCapsuleGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxCapsuleGeometry {
}

// MARK: - Initialization

- (instancetype)initWithRadius:(float)radius halfHeight:(float)halfHeight {
    self = [super initWithGeometry:new PxCapsuleGeometry(radius, halfHeight)];
    return self;
}

- (void)setRadius:(float)radius {
    static_cast<PxCapsuleGeometry *>(super.c_geometry)->radius = radius;
}

- (float)radius {
    return static_cast<PxCapsuleGeometry *>(super.c_geometry)->radius;
}

- (void)setHalfHeight:(float)halfHeight {
    static_cast<PxCapsuleGeometry *>(super.c_geometry)->halfHeight = halfHeight;
}

- (float)halfHeight {
    return static_cast<PxCapsuleGeometry *>(super.c_geometry)->halfHeight;
}

@end
