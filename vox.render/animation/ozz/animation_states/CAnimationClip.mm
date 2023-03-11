//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimationClip.h"
#import "CAnimationClip+Internal.h"
#include <ozz/animation/runtime/sampling_job.h>
#include <ozz/base/io/archive.h>
#include <simd/simd.h>

@implementation CAnimationClip {
    ozz::animation::SamplingJob _sampling_job;

    // Runtime animation.
    ozz::animation::Animation _animation;

    // Sampling context.
    ozz::animation::SamplingJob::Context _context;

    // Buffer of local transforms as sampled from main animation_.
    ozz::vector<ozz::math::SoaTransform> _locals;

    // Current animation time ratio, in the unit interval [0,1], where 0 is the
    // beginning of the animation, 1 is the end.
    float _time_ratio;

    // Time ratio of the previous update.
    float _previous_time_ratio;
}

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        if ([filename length] != 0) {
            [self loadAnimation:filename];
        }
        _sampling_job.animation = &_animation;
        _sampling_job.context = &_context;
    }
    return self;
}

- (bool)loadAnimation:(NSString *)filename {
//    LOGI("Loading animation archive: {}", filename)
    ozz::io::File file([filename cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (!file.opened()) {
//        LOGE("Failed to open animation file {}", filename)
        return false;
    }
    ozz::io::IArchive archive(&file);
    if (!archive.TestTag<ozz::animation::Animation>()) {
//        LOGE("Failed to load animation instance from file {}.", filename)
        return false;
    }

    // Once the tag is validated, reading cannot fail.
    archive >> _animation;

    return true;
}

- (ozz::animation::Animation &)animation {
    return _animation;
}

- (void)loadSkeleton:(ozz::animation::Skeleton *_Nonnull)skeleton {
    [super loadSkeleton:skeleton];

    _context.Resize(skeleton->num_joints());
    _locals.resize(skeleton->num_soa_joints());
    _sampling_job.output = make_span(_locals);

    auto jointMaskCount = [super jointMasks].size();
    [super jointMasks].resize(skeleton->num_soa_joints());
    if (skeleton->num_soa_joints() != jointMaskCount) {
        [super setJointMasks:1.0 :nil];
    }
}

- (const ozz::vector<ozz::math::SoaTransform> *_Nonnull)locals {
    return &_locals;
}

- (void)update:(float)dt {
    float new_time = _time_ratio;

    if (_play) {
        new_time = _time_ratio + dt * _playback_speed / _animation.duration();
    }

    // Must be called even if time doesn't change, in order to update previous
    // frame time ratio. Uses set_time_ratio function in order to update
    // previous_time_ a wrap time value in the unit interval (depending on loop
    // mode).
    [self setTimeRatio:new_time];
    _sampling_job.ratio = [self timeRatio];
    if (_sampling_job.animation) {
        (void) _sampling_job.Run();
    }
}

- (void)setTimeRatio:(float)_ratio {
    _previous_time_ratio = _time_ratio;
    if (_loop) {
        // Wraps in the unit interval [0:1], even for negative values (the reason
        // for using floorf).
        _time_ratio = _ratio - floorf(_ratio);
    } else {
        // Clamps in the unit interval [0:1].
        _time_ratio = simd_clamp(0.f, _ratio, 1.f);
    }
}

- (float)timeRatio {
    return _time_ratio;
}

- (float)previousTimeRatio {
    return _previous_time_ratio;
}

- (void)reset {
    _previous_time_ratio = _time_ratio = 0.f;
    _playback_speed = 1.f;
    _play = true;
}


@end
