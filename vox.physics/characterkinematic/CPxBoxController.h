//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "CPxController.h"

@interface CPxBoxController : CPxController

- (float)getHalfHeight;

- (float)getHalfSideExtent;

- (float)getHalfForwardExtent;

- (bool)setHalfHeight:(float)halfHeight;

- (bool)setHalfSideExtent:(float)halfSideExtent;

- (bool)setHalfForwardExtent:(float)halfForwardExtent;

@end