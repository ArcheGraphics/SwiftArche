//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "../CPxMaterial.h"
#import "../CPxShape.h"
#import "../CPxRigidActor.h"
#import "CPxObstacle.h"
#import "CPxControllerDesc.h"

@class CPxController;

@interface CPxBoxControllerDesc : CPxControllerDesc

- (enum CPxControllerShapeType)getType;

- (void)setToDefault;

@property(nonatomic, assign) float halfHeight;
@property(nonatomic, assign) float halfSideExtent;
@property(nonatomic, assign) float halfForwardExtent;

@property(nonatomic, assign) simd_float3 position;
@property(nonatomic, assign) simd_float3 upDirection;
@property(nonatomic, assign) float slopeLimit;
@property(nonatomic, assign) float invisibleWallHeight;
@property(nonatomic, assign) float maxJumpHeight;
@property(nonatomic, assign) float contactOffset;
@property(nonatomic, assign) float stepOffset;
@property(nonatomic, assign) float density;
@property(nonatomic, assign) float scaleCoeff;
@property(nonatomic, assign) float volumeGrowth;
@property(nonatomic, assign) enum CPxControllerNonWalkableMode nonWalkableMode;
@property(nonatomic, assign) CPxMaterial *_Nullable material;
@property(nonatomic, assign) bool registerDeletionListener;

- (void)setControllerBehaviorCallback
        :(uint8_t (^ _Nullable)(CPxShape *_Nonnull shape, CPxRigidActor *_Nonnull actor))getShapeBehaviorFlags
        :(uint8_t (^ _Nullable)(CPxController *_Nonnull controller))getControllerBehaviorFlags
        :(uint8_t (^ _Nullable)(CPxObstacle *_Nonnull obstacle))getObstacleBehaviorFlags;

@end