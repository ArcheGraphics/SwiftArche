//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

@interface CAnimationState : NSObject

@property(nonatomic) float weight;

@property(nonatomic) uint8 blendMode;

- (void)addChild:(CAnimationState *_Nonnull)state;

- (void)removeChild:(CAnimationState *_Nonnull)state;

- (void)setJointMasks:(float)mask :(NSString *_Nullable)root;

- (void)update:(float)dt;

@end
