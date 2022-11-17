//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>

enum CPxGeometryType {
    eSPHERE,
    ePLANE,
    eCAPSULE,
    eBOX,
    eCONVEXMESH,
    eTRIANGLEMESH,
    eHEIGHTFIELD,
    eGEOMETRY_COUNT,    //!< internal use only!
    eINVALID = -1        //!< internal use only!
};

@interface CPxObstacle : NSObject

- (enum CPxGeometryType)getType;

@end

@interface CPxBoxObstacle : CPxObstacle

@property(nonatomic, assign) simd_float3 mPos;
@property(nonatomic, assign) simd_quatf mRot;

@property(nonatomic, assign) simd_float3 mHalfExtents;

@end

@interface CPxCapsuleObstacle : CPxObstacle

@property(nonatomic, assign) simd_float3 mPos;
@property(nonatomic, assign) simd_quatf mRot;

@property(nonatomic, assign) float mHalfHeight;
@property(nonatomic, assign) float mRadius;

@end

@interface CPxObstacleContext : NSObject

- (uint32_t)addObstacle:(CPxObstacle *)obstacle;

- (bool)removeObstacle:(uint32_t)handle;

- (bool)updateObstacle:(uint32_t)handle :(CPxObstacle *)obstacle;

- (uint32_t)getNbObstacles;

- (CPxObstacle *)getObstacle:(uint32_t)i;

- (CPxObstacle *)getObstacleByHandle:(uint32_t)handle;

@end