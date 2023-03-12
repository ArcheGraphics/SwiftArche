//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "CAnimator.h"

@interface CSkinGroup : NSObject

-(void)loadSkin:(NSString*_Nonnull)filename;

-(uint32_t)skinCount;

// MARK: - vertex count
-(uint32_t)vertexCountAt:(uint32_t)index;

-(void)getMeshDataAt:(uint32_t)index
                    :(float*_Nonnull)positions
                    :(float*_Nonnull)normals
                    :(float*_Nonnull)tangents
                    :(float*_Nonnull)uvs
                    :(float*_Nonnull)joint_indices
                    :(float*_Nonnull)joint_weights
                    :(float*_Nonnull)colors
                    :(uint16_t*_Nonnull)indices;

// MARK: - skinning Matrices
-(uint32_t)skinningMatricesCountAt:(uint32_t)index;

-(void)getSkinningMatricesAt:(uint32_t)index
                            :(CAnimator* _Nonnull) animator
                            :(simd_float4x4*_Nonnull)matrix;


@end
