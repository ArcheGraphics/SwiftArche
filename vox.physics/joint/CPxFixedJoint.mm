//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxFixedJoint.h"
#import "CPxJoint+Internal.h"

@implementation CPxFixedJoint

- (void)setProjectionLinearTolerance:(float)tolerance {
    static_cast<PxFixedJoint *>(super.c_joint)->setProjectionLinearTolerance(tolerance);
}

- (float)getProjectionLinearTolerance {
    return static_cast<PxFixedJoint *>(super.c_joint)->getProjectionLinearTolerance();
}

- (void)setProjectionAngularTolerance:(float)tolerance {
    static_cast<PxFixedJoint *>(super.c_joint)->setProjectionAngularTolerance(tolerance);
}

- (float)getProjectionAngularTolerance {
    return static_cast<PxFixedJoint *>(super.c_joint)->getProjectionAngularTolerance();
}

@end
