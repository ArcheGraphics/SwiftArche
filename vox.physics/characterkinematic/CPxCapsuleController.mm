//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxCapsuleController.h"
#import "CPxController+Internal.h"

@implementation CPxCapsuleController

- (float)getRadius {
    return static_cast<PxCapsuleController *>(super.c_controller)->getRadius();
}

- (bool)setRadius:(float)radius {
    return static_cast<PxCapsuleController *>(super.c_controller)->setRadius(radius);
}

- (float)getHeight {
    return static_cast<PxCapsuleController *>(super.c_controller)->getHeight();
}

- (bool)setHeight:(float)height {
    return static_cast<PxCapsuleController *>(super.c_controller)->setHeight(height);
}

- (enum CPxCapsuleClimbingMode)getClimbingMode {
    return CPxCapsuleClimbingMode(static_cast<PxCapsuleController *>(super.c_controller)->getClimbingMode());
}

- (bool)setClimbingMode:(CPxCapsuleClimbingMode)mode {
    return static_cast<PxCapsuleController *>(super.c_controller)->setClimbingMode(PxCapsuleClimbingMode::Enum(mode));
}

@end
