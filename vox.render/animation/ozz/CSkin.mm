//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CSkin.h"
#include "Skin.h"
#import "CAnimator+Internal.h"
#include <ozz/base/io/archive.h>

@implementation CSkin {
    std::vector<ozz::Skin> skins_pool_;
}

-(void)destroy {
    skins_pool_.~vector();
}

-(void)loadSkin:(NSString*_Nonnull)filename {
    ozz::io::File file([filename cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (!file.opened()) {
//        LOGE("Failed to open mesh file {}.", filename)
    }
    ozz::io::IArchive archive(&file);

    while (archive.TestTag<ozz::Skin>()) {
        ozz::Skin skin;
        archive >> skin;
        skins_pool_.push_back(skin);
    }
}

-(uint32_t)skinCount {
    return static_cast<uint32_t>(skins_pool_.size());
}

-(uint32_t)vertexCountAt:(uint32_t)index {
    uint32_t vertex_count = 0;
    for (const auto& part : skins_pool_[index].parts) {
        vertex_count += part.vertex_count();
    }
    return vertex_count;
}

-(uint32_t)indicesCountAt:(uint32_t)index {
    return uint32_t(std::ceil(float(skins_pool_[index].triangle_indices.size()) / 4.0)) * 4;
}

-(uint32_t)skinningMatricesCountAt:(uint32_t)index {
    // Computes the number of skinning matrices required to skin all meshes.
    // A mesh is skinned by only a subset of joints, so the number of skinning
    // matrices might be less that the number of skeleton joints.
    // Mesh::joint_remaps is used to know how to order skinning matrices. So
    // the number of matrices required is the size of joint_remaps.
    return static_cast<uint32_t>(skins_pool_[index].joint_remaps.size());
}

-(void)getMeshDataAt:(uint32_t)index
                    :(float*)positions
                    :(float*)normals
                    :(float*)tangents
                    :(float*)uvs
                    :(float*)joint_indices
                    :(float*)joint_weights
                    :(float*)colors
                    :(uint16_t*)indices {
    int vertex_count = 0;
    for (const auto& part : skins_pool_[index].parts) {
        int part_vertex_count = part.vertex_count();
        int part_influences_count = part.influences_count();
        int weight_influences_count = part_influences_count - 1;
        std::copy(part.positions.begin(), part.positions.end(),
                  positions + vertex_count * ozz::Skin::Part::kPositionsCpnts);
        std::copy(part.normals.begin(), part.normals.end(), normals + vertex_count * ozz::Skin::Part::kNormalsCpnts);
        std::copy(part.tangents.begin(), part.tangents.end(),
                  tangents + vertex_count * ozz::Skin::Part::kTangentsCpnts);
        std::copy(part.uvs.begin(), part.uvs.end(), uvs + vertex_count * ozz::Skin::Part::kUVsCpnts);

        for (int i = 0; i < part_vertex_count; ++i) {
            uint16_t index[4];
            for (int j = 0; j < 4; ++j) {
                if (j < part_influences_count) {
                    index[j] = part.joint_indices[i * part_influences_count + j];
                } else {
                    index[j] = 0;
                }
            }
            joint_indices[vertex_count * 4 + i * 4] = index[0];
            joint_indices[vertex_count * 4 + i * 4 + 1] = index[1];
            joint_indices[vertex_count * 4 + i * 4 + 2] = index[2];
            joint_indices[vertex_count * 4 + i * 4 + 3] = index[3];
        }

        for (int i = 0; i < part_vertex_count; ++i) {
            if (weight_influences_count == 0) {
                joint_weights[vertex_count * 4 + i * 4] = 1.f;
            } else if (weight_influences_count == 1) {
                joint_weights[vertex_count * 4 + i * 4] = part.joint_weights[i * weight_influences_count];
                joint_weights[vertex_count * 4 + i * 4 + 1] = 1.f - part.joint_weights[i * weight_influences_count];
            } else if (weight_influences_count == 2) {
                joint_weights[vertex_count * 4 + i * 4] = part.joint_weights[i * weight_influences_count];
                joint_weights[vertex_count * 4 + i * 4 + 1] = part.joint_weights[i * weight_influences_count + 1];
                joint_weights[vertex_count * 4 + i * 4 + 2] =
                        1.f - joint_weights[vertex_count * 4 + i * 4] - joint_weights[vertex_count * 4 + i * 4 + 1];
            } else if (weight_influences_count == 3) {
                joint_weights[vertex_count * 4 + i * 4] = part.joint_weights[i * weight_influences_count];
                joint_weights[vertex_count * 4 + i * 4 + 1] = part.joint_weights[i * weight_influences_count + 1];
                joint_weights[vertex_count * 4 + i * 4 + 2] = part.joint_weights[i * weight_influences_count + 2];
                joint_weights[vertex_count * 4 + i * 4 + 3] = 1.f - joint_weights[vertex_count * 4 + i * 4] -
                                                              joint_weights[vertex_count * 4 + i * 4 + 1] -
                                                              joint_weights[vertex_count * 4 + i * 4 + 2];
            } else if (weight_influences_count == -1) {
                joint_weights[vertex_count * 4 + i * 4] = 0.f;
                joint_weights[vertex_count * 4 + i * 4 + 1] = 0.f;
                joint_weights[vertex_count * 4 + i * 4 + 2] = 0.f;
                joint_weights[vertex_count * 4 + i * 4 + 3] = 0.f;
            } else {
                for (int j = 0; j < 4; ++j) {
                    joint_weights[vertex_count * 4 + i * 4 + j] = part.joint_weights[i * weight_influences_count + j];
                }
            }
        }

        for (int i = 0; i < part_vertex_count * ozz::Skin::Part::kColorsCpnts; ++i) {
            if (i >= part.colors.size()) {
                colors[vertex_count * ozz::Skin::Part::kColorsCpnts + i] = 1.0;
            } else {
                colors[vertex_count * ozz::Skin::Part::kColorsCpnts + i] = static_cast<float>(part.colors[i]) / 255.f;
            }
        }

        vertex_count += part_vertex_count;
    }
    std::copy(skins_pool_[index].triangle_indices.begin(), skins_pool_[index].triangle_indices.end(), indices);
}

-(void)getSkinningMatricesAt:(uint32_t)index
                            :(CAnimator* _Nonnull) animator
                            :(simd_float4x4*_Nonnull)matrix {
    // Builds skinning matrices, based on the output of the animation stage.
    // The mesh might not use (aka be skinned by) all skeleton joints. We
    // use the joint remapping table (available from the mesh object) to
    // reorder model-space matrices and build skinning ones.
    for (size_t i = 0; i < skins_pool_[index].joint_remaps.size(); ++i) {
        auto result = [animator models][skins_pool_[index].joint_remaps[i]] * skins_pool_[index].inverse_bind_poses[i];
        matrix[i].columns[0] = result.cols[0];
        matrix[i].columns[1] = result.cols[1];
        matrix[i].columns[2] = result.cols[2];
        matrix[i].columns[3] = result.cols[3];
    }
}

@end
