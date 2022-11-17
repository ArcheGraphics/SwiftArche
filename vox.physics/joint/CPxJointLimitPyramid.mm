//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxJointLimitPyramid.h"
#import "CPxJointLimitPyramid+Internal.h"

@implementation CPxJointLimitPyramid

- (instancetype)initWithLimit:(PxJointLimitPyramid)c_limit {
    self = [super init];
    if (self) {
        if (_c_limit == nullptr) {
            _c_limit = new PxJointLimitPyramid(0, 0, 0, 0);
        }

        *_c_limit = c_limit;
    }
    return self;
}

- (instancetype)initWithHardLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(float)contactDist {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLimitPyramid(yLimitAngleMin, yLimitAngleMax, zLimitAngleMin, zLimitAngleMax, contactDist);
    }
    return self;
}

- (instancetype)initWithSoftLimit:(float)yLimitAngleMin :(float)yLimitAngleMax :(float)zLimitAngleMin :(float)zLimitAngleMax :(CPxSpring *)spring {
    self = [super init];
    if (self) {
        _c_limit = new PxJointLimitPyramid(yLimitAngleMin, yLimitAngleMax, zLimitAngleMin, zLimitAngleMax, PxSpring(spring.stiffness, spring.damping));
    }
    return self;
}

@end
