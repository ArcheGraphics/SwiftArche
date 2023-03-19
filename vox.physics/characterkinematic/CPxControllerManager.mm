//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxControllerManager.h"
#import "CPxControllerManager+Internal.h"
#import "CPxObstacle+Internal.h"
#import "CPxController+Internal.h"
#import "CPxBoxController.h"
#import "CPxCapsuleController.h"
#import "CPxBoxControllerDesc.h"
#import "CPxBoxControllerDesc+Internal.h"
#import "CPxCapsuleControllerDesc.h"
#import "CPxCapsuleControllerDesc+Internal.h"
#include "CPXHelper.h"

using namespace physx;

@implementation CPxControllerManager

- (instancetype)initWithManager:(PxControllerManager *)manager {
    self = [super init];
    if (self) {
        _c_manager = manager;
    }
    return self;
}

- (void)destroy {
    _c_manager->release();
    _c_manager = nullptr;
}

- (uint32_t)getNbControllers {
    return _c_manager->getNbControllers();
}

- (CPxController *)getController:(uint32_t)index {
    return [[CPxController alloc] initWithController:_c_manager->getController(index)];
}

- (CPxController *)createController:(CPxControllerDesc *)desc {
    if ([desc getType] == CPxControllerShapeType_eBOX) {
        return [[CPxBoxController alloc] initWithController:_c_manager->createController(static_cast<CPxBoxControllerDesc *>(desc).c_desc)];
    } else if ([desc getType] == CPxControllerShapeType_eCAPSULE) {
        return [[CPxCapsuleController alloc] initWithController:_c_manager->createController(static_cast<CPxCapsuleControllerDesc *>(desc).c_desc)];
    } else {
        assert(false);
    }
    return nullptr;
}

- (void)purgeControllers {
    _c_manager->purgeControllers();
}

- (uint32_t)getNbObstacleContexts {
    return _c_manager->getNbObstacleContexts();
}

- (CPxObstacleContext *)getObstacleContext:(uint32_t)index {
    return [[CPxObstacleContext alloc] initWithContext:_c_manager->getObstacleContext(index)];
}

- (CPxObstacleContext *)createObstacleContext {
    return [[CPxObstacleContext alloc] initWithContext:_c_manager->createObstacleContext()];
}

- (void)computeInteractions:(float)elapsedTime {
    _c_manager->computeInteractions(elapsedTime);
}

- (void)setTessellation:(bool)flag :(float)maxEdgeLength {
    _c_manager->setTessellation(flag, maxEdgeLength);
}

- (void)setOverlapRecoveryModule:(bool)flag {
    _c_manager->setOverlapRecoveryModule(flag);
}

- (void)setPreciseSweeps:(bool)flag {
    _c_manager->setPreciseSweeps(flag);
}

- (void)setPreventVerticalSlidingAgainstCeiling:(bool)flag {
    _c_manager->setPreventVerticalSlidingAgainstCeiling(flag);
}

- (void)shiftOrigin:(simd_float3)shift {
    _c_manager->shiftOrigin(transform(shift));
}

@end
