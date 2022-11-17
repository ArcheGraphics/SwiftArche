//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.
#import "CPxBoxController.h"
#import "CPxController+Internal.h"

@implementation CPxBoxController

- (float)getHalfHeight {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfHeight();
}

- (float)getHalfSideExtent {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfSideExtent();
}

- (float)getHalfForwardExtent {
    return static_cast<PxBoxController *>(super.c_controller)->getHalfForwardExtent();
}

- (bool)setHalfHeight:(float)halfHeight {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfHeight(halfHeight);
}

- (bool)setHalfSideExtent:(float)halfSideExtent {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfSideExtent(halfSideExtent);
}

- (bool)setHalfForwardExtent:(float)halfForwardExtent {
    return static_cast<PxBoxController *>(super.c_controller)->setHalfForwardExtent(halfForwardExtent);
}

@end
