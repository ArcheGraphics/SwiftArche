//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimatorBlending.h"
#import "CAnimatorBlending+Internal.h"
#include <ozz/animation/runtime/blending_job.h>

@implementation CAnimatorBlending {
    ozz::animation::BlendingJob _blend_job;

    ozz::vector<ozz::animation::BlendingJob::Layer> _additive_layers;
    ozz::vector<ozz::animation::BlendingJob::Layer> _layers;
    // Buffer of local transforms which stores the blending result.
    ozz::vector<ozz::math::SoaTransform> _blended_locals;
}

- (void)update:(float)dt {
    _layers.clear();
    _additive_layers.clear();

    for (auto &state: super.states) {
        [state update:dt];

        ozz::animation::BlendingJob::Layer layer{};
        layer.transform = make_span(*[state locals]);
        layer.joint_weights = make_span([state jointMasks]);
        layer.weight = [state weight];
        if ([state blendMode] == 0) {
            _layers.push_back(layer);
        } else {
            _additive_layers.push_back(layer);
        }
    }
    if (!_layers.empty() || !_additive_layers.empty()) {
        _blend_job.layers = make_span(_layers);
        _blend_job.additive_layers = make_span(_additive_layers);
        (void) _blend_job.Run();
    }
}

- (void)loadSkeleton:(ozz::animation::Skeleton *)skeleton {
    [super loadSkeleton:skeleton];

    for (auto &state: super.states) {
        [state loadSkeleton:skeleton];
    }

    _blended_locals.resize(skeleton->num_soa_joints());
    _blend_job.output = make_span(_blended_locals);
    _blend_job.rest_pose = skeleton->joint_rest_poses();
}

- (ozz::vector<ozz::math::SoaTransform> *)locals {
    return &_blended_locals;
}

- (float)threshold {
    return _blend_job.threshold;
}

- (void)setThreshold:(float)threshold {
    _blend_job.threshold = threshold;
}

- (void)destroy {
    _blend_job.~BlendingJob();
    _additive_layers.~vector();
    _layers.~vector();
    _blended_locals.~vector();
    
    [super destroy];
}

@end
