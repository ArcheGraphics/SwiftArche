//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxPlaneGeometry.h"
#import "CPxGeometry+Internal.h"
#import "PxPhysicsAPI.h"

using namespace physx;

@implementation CPxPlaneGeometry {
}

// MARK: - Initialization

- (instancetype)init {
    self = [super initWithGeometry:new PxPlaneGeometry];
    return self;
}

@end
