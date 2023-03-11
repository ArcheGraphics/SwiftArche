//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimationState.h"
#import "CAnimationState+Internal.h"
#include <ozz/animation/runtime/skeleton.h>
#include <ozz/animation/runtime/skeleton_utils.h>

@implementation CAnimationState {
    ozz::animation::Skeleton *_skeleton;

    // Per-joint weights used to define the partial animation mask. Allows to
    // select which joints are considered during blending, and their individual
    // weight_setting.
    ozz::vector<ozz::math::SimdFloat4> _joint_masks;
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

- (void)setJointMasks:(float)mask :(NSString *_Nullable)root {
    ozz::math::SimdFloat4 simdMask = ozz::math::simd_float4::Load1(mask);
    if (root == nil) {
        for (int i = 0; i < _skeleton->num_soa_joints(); ++i) {
            _joint_masks[i] = simdMask;
        }
    } else {
        const auto set_joint = [self, simdMask](int _joint, int) {
            ozz::math::SimdFloat4 &soa_weight = _joint_masks[_joint / 4];
            soa_weight = ozz::math::SetI(soa_weight, simdMask, _joint % 4);
        };

        const int joint = ozz::animation::FindJoint(*_skeleton, [root cStringUsingEncoding:NSUTF8StringEncoding]);
        if (joint >= 0) {
            ozz::animation::IterateJointsDF(*_skeleton, set_joint, joint);
        }
    }
}

- (void)update:(float)dt {
}

// MARK: - Internal
- (ozz::vector<ozz::math::SimdFloat4>)jointMasks {
    return _joint_masks;
}

- (void)loadSkeleton:(ozz::animation::Skeleton *)skeleton {
    _skeleton = skeleton;
}

- (ozz::vector<ozz::math::SoaTransform> *)locals {
    return nullptr;
}

@end
