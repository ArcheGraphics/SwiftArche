//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "CPxGeometry.h"
#import "CPxMaterial.h"

@interface CPxShape : NSObject

- (void)setFlags:(uint8_t)inFlags;

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3;

- (void)setGeometry:(CPxGeometry *)geometry;

- (void)setLocalPose:(simd_float3)position rotation:(simd_quatf)rotation;

- (void)setMaterial:(CPxMaterial *)material;

- (int)getQueryFilterData:(int)index;

- (void)setContactOffset:(float)contactOffset;

@end