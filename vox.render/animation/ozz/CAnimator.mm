//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CAnimator.h"
#import "CAnimator+Internal.h"
#import "CAnimationState+Internal.h"
#include <ozz/animation/runtime/ik_aim_job.h>
#include <ozz/animation/runtime/ik_two_bone_job.h>
#include <ozz/animation/runtime/local_to_model_job.h>
#include <ozz/animation/runtime/skeleton_utils.h>
#include <ozz/base/io/archive.h>
#include <unordered_map>
#include <string>

@implementation CAnimator {
    ozz::animation::Skeleton _skeleton;
    ozz::animation::LocalToModelJob _ltm_job;
    // Buffer of local transforms as sampled from animation_.
    ozz::vector<ozz::math::SoaTransform> _locals;
    // Buffer of model space matrices.
    ozz::vector<ozz::math::Float4x4> _models;
    CAnimationState *_rootState;
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

- (void)destroy {
    _models.~vector();
    _locals.~vector();
    _skeleton.~Skeleton();
    _ltm_job.~LocalToModelJob();
    if (_rootState) {
        [_rootState destroy];
    }
}

+ (int)kMaxJoints {
    return ozz::animation::Skeleton::kMaxJoints;
}

- (void)update:(float)dt {
    if (_rootState) {
        [_rootState loadSkeleton:&_skeleton];
        [_rootState update:dt];
        _locals = *[_rootState locals];
    } else {
        _locals.resize(_skeleton.num_soa_joints());
        // Initialize locals from skeleton rest pose
        for (size_t i = 0; i < _locals.size(); ++i) {
            _locals[i] = _skeleton.joint_rest_poses()[i];
        }
    }
    _ltm_job.input = make_span(_locals);
    (void) _ltm_job.Run();
}

- (void)setRootState:(CAnimationState *_Nullable)state {
    _rootState = state;
}

- (bool)loadSkeleton:(NSString *_Nonnull)filename {
//    LOGI("Loading skeleton archive {}", filename)
    ozz::io::File file([filename cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (!file.opened()) {
//        LOGE("Failed to open skeleton file {}", filename)
        return false;
    }
    ozz::io::IArchive archive(&file);
    if (!archive.TestTag<ozz::animation::Skeleton>()) {
//        LOGE("Failed to load skeleton instance from file {}.", filename)
        return false;
    }

    // Once the tag is validated, reading cannot fail.
    archive >> _skeleton;

    _models.resize(_skeleton.num_joints());
    _ltm_job.output = make_span(_models);
    _ltm_job.skeleton = &_skeleton;
    return true;
}

- (bool)localToModelFromExcluded {
    return _ltm_job.from_excluded;
}

- (void)setLocalToModelFromExcluded:(bool)localToModelFromExcluded {
    _ltm_job.from_excluded = localToModelFromExcluded;
}

- (int)localToModelFrom {
    return _ltm_job.from;
}

- (void)setLocalToModelFrom:(int)localToModelFrom {
    _ltm_job.from = localToModelFrom;
}

- (int)localToModelTo {
    return _ltm_job.to;
}

- (void)setLocalToModelTo:(int)localToModelTo {
    _ltm_job.to = localToModelTo;
}

- (void)computeSkeletonBounds:(simd_float3 *_Nonnull)min
        :(simd_float3 *_Nonnull)max {
    const int num_joints = _skeleton.num_joints();
    if (!num_joints) {
        return;
    }

    // Allocate matrix array, out of memory is handled by the LocalToModelJob.
    ozz::vector<ozz::math::Float4x4> models(num_joints);

    // Compute model space rest pose.
    ozz::animation::LocalToModelJob job;
    job.input = _skeleton.joint_rest_poses();
    job.output = make_span(models);
    job.skeleton = &_skeleton;
    if (job.Run()) {
        // Forwards to posture function.
        _computePostureBounds(job.output, min, max);
    }
}

void _computePostureBounds(ozz::span<const ozz::math::Float4x4> _matrices,
        simd_float3 *boundMin, simd_float3 *boundMax) {
    // Set a default box.
    *boundMin = simd_make_float3(0, 0, 0);
    *boundMax = simd_make_float3(0, 0, 0);

    if (_matrices.empty()) {
        return;
    }

    // Loops through matrices and stores min/max.
    // Matrices array cannot be empty, it was checked at the beginning of the
    // function.
    const ozz::math::Float4x4 *current = _matrices.begin();
    ozz::math::SimdFloat4 min = current->cols[3];
    ozz::math::SimdFloat4 max = current->cols[3];
    ++current;
    while (current < _matrices.end()) {
        min = ozz::math::Min(min, current->cols[3]);
        max = ozz::math::Max(max, current->cols[3]);
        ++current;
    }

    // Stores in math::Box structure.
    ozz::math::Store3PtrU(min, (float *) boundMin);
    ozz::math::Store3PtrU(max, (float *) boundMax);
}

- (uint32_t)findJontIndex:(NSString *_Nonnull)name {
    auto iter = std::find(_skeleton.joint_names().begin(), _skeleton.joint_names().end(),
            std::string([name cStringUsingEncoding:NSUTF8StringEncoding]));
    if (iter != _skeleton.joint_names().end()) {
        return static_cast<uint32_t>(iter - _skeleton.joint_names().begin());
    }
    return std::numeric_limits<uint32_t>::max();
}

- (simd_float4x4)modelsAt:(uint32_t)index {
    simd_float4x4 localMatrix;
    memcpy(&localMatrix, &_models[index].cols[0], sizeof(simd_float4x4));
    return localMatrix;
}

- (int)fillPostureUniforms:(float *_Nonnull)_uniforms {
    assert(ozz::IsAligned(_uniforms, alignof(ozz::math::SimdFloat4)));

    // Prepares computation constants.
    const int num_joints = _skeleton.num_joints();
    const ozz::span<const int16_t> &parents = _skeleton.joint_parents();

    int instances = 0;
    for (int i = 0; i < num_joints && instances < ozz::animation::Skeleton::kMaxJoints * 2; ++i) {
        // Root isn't rendered.
        const int16_t parent_id = parents[i];
        if (parent_id == ozz::animation::Skeleton::kNoParent) {
            continue;
        }

        // Selects joint matrices.
        const ozz::math::Float4x4 &parent = _models[parent_id];
        const ozz::math::Float4x4 &current = _models[i];

        // Copy parent joint's raw matrix, to render a bone between the parent
        // and current matrix.
        float *uniform = _uniforms + instances * 16;
        std::memcpy(uniform, parent.cols, 16 * sizeof(float));

        // Set bone direction (bone_dir). The shader expects to find it at index
        // [3,7,11] of the matrix.
        // Index 15 is used to store whether a bone should be rendered,
        // otherwise it's a leaf.
        float bone_dir[4];
        ozz::math::StorePtrU(current.cols[3] - parent.cols[3], bone_dir);
        uniform[3] = bone_dir[0];
        uniform[7] = bone_dir[1];
        uniform[11] = bone_dir[2];
        uniform[15] = 1.f;  // Enables bone rendering.

        // Next instance.
        ++instances;
        uniform += 16;

        // Only the joint is rendered for leaves, the bone model isn't.
        if (IsLeaf(_skeleton, i)) {
            // Copy current joint's raw matrix.
            std::memcpy(uniform, current.cols, 16 * sizeof(float));

            // Re-use bone_dir to fix the size of the leaf (same as previous bone).
            // The shader expects to find it at index [3,7,11] of the matrix.
            uniform[3] = bone_dir[0];
            uniform[7] = bone_dir[1];
            uniform[11] = bone_dir[2];
            uniform[15] = 0.f;  // Disables bone rendering.
            ++instances;
        }
    }

    return instances;
}

-(const ozz::vector<ozz::math::Float4x4>&) models {
    return _models;
}

// MARK: - IK

@end
