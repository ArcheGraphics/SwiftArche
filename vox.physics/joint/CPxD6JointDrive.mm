//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxD6JointDrive.h"
#import "CPxSpring+Internal.h"

@implementation CPxD6JointDrive

- (id)init {
    self = [super init];
    if (self) {
        if (super.c_spring != nullptr) {
            delete super.c_spring;
            super.c_spring = nullptr;
        }
        super.c_spring = new PxD6JointDrive();
    }
    return self;
}

- (instancetype)initWithLimitStiffness:(float)driveStiffness :(float)driveDamping :(float)driveForceLimit {
    self = [super init];
    if (self) {
        if (super.c_spring != nullptr) {
            delete super.c_spring;
            super.c_spring = nullptr;
        }
        super.c_spring = new PxD6JointDrive(driveStiffness, driveDamping, driveForceLimit);
    }
    return self;
}

- (float)forceLimit {
    return static_cast<PxD6JointDrive *>(super.c_spring)->forceLimit;
}

- (void)setForceLimit:(float)forceLimit {
    static_cast<PxD6JointDrive *>(super.c_spring)->forceLimit = forceLimit;
}

- (uint32_t)flags {
    return static_cast<PxD6JointDrive *>(super.c_spring)->flags;
}

- (void)setFlags:(uint32_t)flags {
    static_cast<PxD6JointDrive *>(super.c_spring)->flags = PxD6JointDriveFlags(flags);
}

@end
