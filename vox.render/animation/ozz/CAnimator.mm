//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimator.h"
#import "CAnimator+Internal.h"
#import "CAnimationState.h"
#import "CAnimationState+Internal.h"
#include <ozz/animation/runtime/ik_aim_job.h>
#include <ozz/animation/runtime/ik_two_bone_job.h>
#include <ozz/animation/runtime/local_to_model_job.h>
#include <ozz/base/containers/vector.h>
#include <ozz/base/maths/soa_transform.h>
#include <unordered_map>
#include <simd/simd.h>

@implementation CAnimator {
    ozz::animation::Skeleton _skeleton;
    ozz::animation::LocalToModelJob _ltm_job;
    // Buffer of local transforms as sampled from animation_.
    ozz::vector<ozz::math::SoaTransform>* _locals;
    // Buffer of model space matrices.
    ozz::vector<ozz::math::Float4x4> _models;
    CAnimationState* _rootState;
    std::vector<std::function<void()>> _scheduleFunctor;

    struct LegRayInfo {
        simd_float3 start{};
        simd_float3 dir{};

        bool hit{false};
        simd_float3 hit_point{};
        simd_float3 hit_normal{};
    };
    std::vector<LegRayInfo> _rays_info;
    std::vector<simd_float3> _ankles_initial_ws;
    std::vector<simd_float3> _ankles_target_ws;
    simd_float3 pelvis_offset;
}

- (void) update:(float) dt {
    if (_rootState) {
        [_rootState loadSkeleton:&_skeleton];
        [_rootState update:dt];
        _locals = [_rootState locals];
    } else {
        _locals->resize(_skeleton.num_soa_joints());
        // Initialize locals from skeleton rest pose
        for (size_t i = 0; i < _locals->size(); ++i) {
            (*_locals)[i] = _skeleton.joint_rest_poses()[i];
        }
    }
    _ltm_job.input = make_span(*_locals);
    (void)_ltm_job.Run();
}

@end
