//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxRigidActor.h"
#import "CPxRigidActor+Internal.h"
#import "CPxShape+Internal.h"

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

- (bool)attachShapeWithShape:(CPxShape *)shape {
    return _c_actor->attachShape(*shape.c_shape);
}

- (void)detachShapeWithShape:(CPxShape *)shape {
    _c_actor->detachShape(*shape.c_shape);
}

- (void)setGlobalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    _c_actor->setGlobalPose(PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y,
                    rotation.vector.z, rotation.vector.w)));
}

- (void)getGlobalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = _c_actor->getGlobalPose();
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}


@end
