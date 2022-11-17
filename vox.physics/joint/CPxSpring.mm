//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxSpring.h"
#import "CPxSpring+Internal.h"

using namespace physx;

@implementation CPxSpring {
}

- (instancetype)initWithSpring:(PxSpring)c_spring {
    self = [super init];
    if (self) {
        if (_c_spring != nullptr) {
            delete _c_spring;
            _c_spring = nullptr;
        }
        _c_spring = new PxSpring(c_spring.stiffness, c_spring.damping);
    }
    return self;
}

- (instancetype)initWithD6:(PxD6JointDrive)c_d6 {
    self = [super init];
    if (self) {
        if (_c_spring != nullptr) {
            delete _c_spring;
            _c_spring = nullptr;
        }
        _c_spring = new PxD6JointDrive();
        *_c_spring = c_d6;
    }
    return self;
}

- (instancetype)initWithStiffness:(float)stiffness_ :(float)damping_ {
    self = [super init];
    if (self) {
        if (_c_spring != nullptr) {
            delete _c_spring;
            _c_spring = nullptr;
        }
        _c_spring = new PxSpring(stiffness_, damping_);
    }
    return self;
}

- (float)stiffness {
    return _c_spring->stiffness;
}

- (void)setStiffness:(float)stiffness {
    _c_spring->stiffness = stiffness;
}

- (float)damping {
    return _c_spring->damping;
}

- (void)setDamping:(float)damping {
    _c_spring->damping = damping;
}


@end
