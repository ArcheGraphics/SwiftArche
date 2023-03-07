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

- (void)setGeometry:(CPxGeometry *)geometry;

- (void)setLocalPose:(simd_float3)position rotation:(simd_quatf)rotation;

- (void)setMaterial:(CPxMaterial *)material;

- (void)setContactOffset:(float)contactOffset;

- (void)setUUID:(uint32_t)uuid;

- (uint32_t)getUUID;

@end
