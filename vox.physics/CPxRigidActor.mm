//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxRigidActor.h"
#import "CPxRigidActor+Internal.h"
#import "CPxShape+Internal.h"
#include "CPXHelper.h"

@implementation CPxRigidActor {
}

// MARK: - Initialization

- (instancetype)initWithActor:(PxRigidActor *)actor {
    self = [super init];
    if (self) {
        _c_actor = actor;
    }
    return self;
}

- (void)dealloc {
    _c_actor->release();
}

- (bool)attachShapeWithShape:(CPxShape *)shape {
    return _c_actor->attachShape(*shape.c_shape);
}

- (void)detachShapeWithShape:(CPxShape *)shape {
    _c_actor->detachShape(*shape.c_shape);
}

- (void)setGlobalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    _c_actor->setGlobalPose(transform(position, rotation));
}

- (void)getGlobalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = _c_actor->getGlobalPose();
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}

- (uint16_t)getGroup {
    return PxGetGroup(*_c_actor);
}

- (void)setGroup:(const uint16_t)collisionGroup {
    PxSetGroup(*_c_actor, collisionGroup);
}

@end
