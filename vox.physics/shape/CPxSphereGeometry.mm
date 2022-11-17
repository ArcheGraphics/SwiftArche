//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxSphereGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxSphereGeometry {
}

// MARK: - Initialization

- (instancetype)initWithRadius:(float)radius {
    self = [super initWithGeometry:new PxSphereGeometry(radius)];
    return self;
}

- (void)setRadius:(float)radius {
    static_cast<PxSphereGeometry *>(super.c_geometry)->radius = radius;
}

- (float)radius {
    return static_cast<PxSphereGeometry *>(super.c_geometry)->radius;
}

@end
