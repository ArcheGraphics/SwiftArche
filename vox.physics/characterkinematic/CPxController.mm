//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxController.h"
#import "CPxController+Internal.h"
#import "../CPxRigidDynamic+Internal.h"

@implementation CPxController

- (instancetype)initWithController:(PxController *)controller {
    self = [super init];
    if (self) {
        _c_controller = controller;
    }
    return self;
}

- (enum CPxControllerShapeType)getType {
    return CPxControllerShapeType(_c_controller->getType());
}

- (uint8_t)move:(simd_float3)disp :(float)minDist :(float)elapsedTime {
    return _c_controller->move(PxVec3(disp.x, disp.y, disp.z), minDist, elapsedTime, PxControllerFilters());
}

- (bool)isSetControllerCollisionFlag:(uint8_t)flags :(enum CPxControllerCollisionFlag)flag {
    return PxControllerCollisionFlags(flags).isSet(PxControllerCollisionFlag::Enum(flag));
}

- (bool)setPosition:(simd_float3)position {
    return _c_controller->setPosition(PxExtendedVec3(position.x, position.y, position.z));
}

- (simd_float3)getPosition {
    PxExtendedVec3 pos = _c_controller->getPosition();
    return simd_make_float3(pos.x, pos.y, pos.z);
}

- (void)setFootPosition:(simd_float3)position {
    _c_controller->setFootPosition(PxExtendedVec3(position.x, position.y, position.z));
}

- (simd_float3)getFootPosition {
    PxExtendedVec3 pos = _c_controller->getFootPosition();
    return simd_make_float3(pos.x, pos.y, pos.z);
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
    PxVec3 pos = _c_controller->getUpDirection();
    return simd_make_float3(pos.x, pos.y, pos.z);
}

- (void)setUpDirection:(simd_float3)up {
    _c_controller->setUpDirection(PxVec3(up.x, up.y, up.z));
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
