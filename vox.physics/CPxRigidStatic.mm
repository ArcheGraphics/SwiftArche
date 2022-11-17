//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxRigidStatic.h"
#import "CPxRigidStatic+Internal.h"
#import "CPxRigidActor+Internal.h"

@implementation CPxRigidStatic {
}

// MARK: - Initialization

- (instancetype)initWithStaticActor:(PxRigidStatic *)actor {
    self = [super initWithActor:actor];
    return self;
}

@end
