//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxGeometry.h"
#import "CPxGeometry+Internal.h"

@implementation CPxGeometry {
}

// MARK: - Initialization

- (instancetype)initWithGeometry:(PxGeometry *)geometry {
    self = [super init];
    if (self) {
        _c_geometry = geometry;
    }
    return self;
}

@end
