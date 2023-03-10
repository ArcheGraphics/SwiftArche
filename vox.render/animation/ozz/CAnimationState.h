//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

@interface CAnimationState : NSObject

- (void)addChild:(CAnimationState *_Nonnull)state;

- (void)removeChild:(CAnimationState *_Nonnull)state;

@end
