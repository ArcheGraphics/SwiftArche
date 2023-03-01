//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxController.h"
#import "CPxController+Internal.h"
#import "../CPxRigidDynamic+Internal.h"
#include "CPXHelper.h"

@implementation CPxController

- (instancetype)initWithController:(PxController *)controller {
    self = [super init];
    if (self) {
        _c_controller = controller;
    }
    return self;
}

- (void)dealloc {
    _c_controller->release();
}

- (enum CPxControllerShapeType)getType {
    return CPxControllerShapeType(_c_controller->getType());
}

- (uint8_t)move:(simd_float3)disp :(float)minDist :(float)elapsedTime {
    return _c_controller->move(transform(disp), minDist, elapsedTime, PxControllerFilters());
}

- (bool)isSetControllerCollisionFlag:(uint8_t)flags :(enum CPxControllerCollisionFlag)flag {
    return PxControllerCollisionFlags(flags).isSet(PxControllerCollisionFlag::Enum(flag));
}

- (bool)setPosition:(simd_float3)position {
    return _c_controller->setPosition(transformExtended(position));
}

- (simd_float3)getPosition {
    return transform(_c_controller->getPosition());
}

- (void)setFootPosition:(simd_float3)position {
    _c_controller->setFootPosition(transformExtended(position));
}

- (simd_float3)getFootPosition {
    return transform(_c_controller->getFootPosition());
}

- (CPxRigidDynamic *_Nonnull)getActor {
    return [[CPxRigidDynamic alloc] initWithDynamicActor:_c_controller->getActor()];
}

- (void)setStepOffset:(float)offset {
    _c_controller->setStepOffset(offset);
}

- (float)getStepOffset {
    return _c_controller->getStepOffset();
}

- (void)setNonWalkableMode:(enum CPxControllerNonWalkableMode)flag {
    _c_controller->setNonWalkableMode(PxControllerNonWalkableMode::Enum(flag));
}

- (enum CPxControllerNonWalkableMode)getNonWalkableMode {
    return CPxControllerNonWalkableMode(_c_controller->getNonWalkableMode());
}

- (float)getContactOffset {
    return _c_controller->getContactOffset();
}

- (void)setContactOffset:(float)offset {
    _c_controller->setContactOffset(offset);
}

- (simd_float3)getUpDirection {
    return transform(_c_controller->getUpDirection());
}

- (void)setUpDirection:(simd_float3)up {
    _c_controller->setUpDirection(transform(up));
}

- (float)getSlopeLimit {
    return _c_controller->getSlopeLimit();
}

- (void)setSlopeLimit:(float)slopeLimit {
    _c_controller->setSlopeLimit(slopeLimit);
}

- (void)invalidateCache {
    _c_controller->invalidateCache();
}

- (void)resize:(float)height {
    _c_controller->resize(height);
}

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3 {
    PxRigidDynamic *actor = _c_controller->getActor();
    PxShape *shape;
    actor->getShapes(&shape, 1);
    shape->setQueryFilterData(PxFilterData(w0, w1, w2, w3));
}

@end
