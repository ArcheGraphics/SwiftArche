//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimationState.h"
#import "CAnimationState+Internal.h"
#include <ozz/animation/runtime/skeleton.h>

@implementation CAnimationState {
    ozz::animation::Skeleton *_skeleton;

    // Per-joint weights used to define the partial animation mask. Allows to
    // select which joints are considered during blending, and their individual
    // weight_setting.
    ozz::vector<ozz::math::SimdFloat4> _joint_masks;

    ozz::vector<CAnimationState *> _states;
}

- (ozz::vector<ozz::math::SimdFloat4>)jointMasks {
    return _joint_masks;
}

- (void)addChild:(CAnimationState *_Nonnull)state {
    auto iter = std::find(_states.begin(), _states.end(), state);
    if (iter == _states.end()) {
        _states.push_back(state);
    }
}

- (void)removeChild:(CAnimationState *_Nonnull)state {
    auto iter = std::find(_states.begin(), _states.end(), state);
    if (iter != _states.end()) {
        _states.erase(iter);
    }
}

@end
