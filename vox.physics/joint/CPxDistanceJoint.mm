//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxDistanceJoint.h"
#import "CPxJoint+Internal.h"

@implementation CPxDistanceJoint

- (float)getDistance {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getDistance();
}

- (void)setMinDistance:(float)distance {
    static_cast<PxDistanceJoint *>(super.c_joint)->setMinDistance(distance);
}

- (float)getMinDistance {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getMinDistance();
}

- (void)setMaxDistance:(float)distance {
    static_cast<PxDistanceJoint *>(super.c_joint)->setMaxDistance(distance);
}

- (float)getMaxDistance {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getMaxDistance();
}

- (void)setTolerance:(float)tolerance {
    static_cast<PxDistanceJoint *>(super.c_joint)->setTolerance(tolerance);
}

- (float)getTolerance {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getTolerance();
}

- (void)setStiffness:(float)stiffness {
    static_cast<PxDistanceJoint *>(super.c_joint)->setStiffness(stiffness);
}

- (float)getStiffness {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getStiffness();
}

- (void)setDamping:(float)damping {
    static_cast<PxDistanceJoint *>(super.c_joint)->setDamping(damping);
}

- (float)getDamping {
    return static_cast<PxDistanceJoint *>(super.c_joint)->getDamping();
}

- (void)setDistanceJointFlag:(CPxDistanceJointFlag)flag :(bool)value {
    static_cast<PxDistanceJoint *>(super.c_joint)->setDistanceJointFlag(PxDistanceJointFlag::Enum(flag), value);
}

@end
