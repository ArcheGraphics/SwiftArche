//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../CAnimationState.h"

@interface CAnimationClip : CAnimationState

/// Playback speed, can be negative in order to play the animation backward.
@property(nonatomic) float playback_speed;

/// Animation play mode state: play/pause.
@property(nonatomic) bool play;

/// Animation loop mode.
@property(nonatomic) bool loop;

- (instancetype)initWithFilename:(NSString *)filename;

- (bool)loadAnimation:(NSString *)filename;

- (void)update:(float)dt;

/// Sets animation current time.
- (void)setTimeRatio:(float)time;

/// Gets animation current time.
- (float)timeRatio;

/// Gets animation time ratio of last update. Useful when the range between
/// previous and current frame needs to pe processed.
- (float)previousTimeRatio;

/// Resets all parameters to their default value.
- (void)reset;

@end
