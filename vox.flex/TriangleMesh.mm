//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "TriangleMesh.h"
#include <vector>
#import <fstream>
#import <iostream>

#define TINYOBJLOADER_IMPLEMENTATION
#define TINYOBJLOADER_USE_DOUBLE
#include <tiny_obj_loader.h>
#include <bvh/bvh.hpp>
#include <bvh/leaf_collapser.hpp>
#include <bvh/locally_ordered_clustering_builder.hpp>
#include <bvh/triangle.hpp>

namespace {
struct Node {
    float    bbox[6];
    uint32_t childIndex;
    uint32_t childCount; // childCount is always 0 for interior nodes
};
} // namespace

@implementation TriangleMesh {
    std::vector<bvh::Vector<float, 2>> _uvs;
    std::vector<bvh::Vector3<float>> _points;
    std::vector<bvh::Vector3<float>> _normals;
    std::vector<simd_uint3> _pointIndices;
    std::vector<simd_uint3> _normalIndices;
    std::vector<simd_uint3> _uvIndices;
    
    std::vector<Node>   nodes_;
    std::vector<simd_float3> vertices_;
    std::vector<simd_float3> normals_;
    
    std::vector<bvh::BoundingBox<float>> primBBoxes;
    std::vector<bvh::Vector3<float>> primCenters;
    bvh::BoundingBox<float> globalBBox;
    
    id<MTLBuffer> nodeBuffer;
    id<MTLBuffer> verticesBuffer;
    id<MTLBuffer> normalBuffer;
}

- (void)addPoint:(simd_float3)pt {
    _points.emplace_back(bvh::Vector3<float>(pt[0], pt[1], pt[2]));
}

- (void)addNormal:(simd_float3)n {
    _normals.emplace_back(bvh::Vector3<float>(n[0], n[1], n[2]));
}

- (void)addUv:(simd_float2)t {
    _uvs.emplace_back(bvh::Vector<float, 2>(t[0], t[1]));
}

- (void)addPointTriangle:(simd_uint3)newPointIndices {
    _pointIndices.emplace_back(newPointIndices);
}

- (void)addNormalTriangle:(simd_uint3)newNormalIndices {
    _normalIndices.emplace_back(newNormalIndices);
}

- (void)addUvTriangle:(simd_uint3)newUvIndices {
    _uvIndices.emplace_back(newUvIndices);
}

-(id<MTLBuffer>) nodeBuffer {
    return nodeBuffer;
}

-(id<MTLBuffer>) verticesBuffer {
    return verticesBuffer;
}

-(id<MTLBuffer>) normalBuffer {
    return normalBuffer;
}

- (uint32_t)triangleCount {
    return static_cast<uint32_t>(_pointIndices.size());
}

- (bool)load:(NSString *)filename {
    std::ifstream file([filename cStringUsingEncoding:NSUTF8StringEncoding]);
    if (file) {
        tinyobj::attrib_t attrib;
        std::vector<tinyobj::shape_t> shapes;
        std::vector<tinyobj::material_t> materials;
        std::string err;
        std::string warn;

        const bool ret = tinyobj::LoadObj(&attrib, &shapes, &materials, &warn, &err, &file);

        // `err` may contain warning message.
        if (!err.empty()) {
            std::cerr << err;
            return false;
        }

        // Failed to load obj.
        if (!ret) {
            return false;
        }

        // Read vertices
        for (size_t idx = 0; idx < attrib.vertices.size() / 3; ++idx) {
            // Access to vertex
            tinyobj::real_t vx = attrib.vertices[3 * idx + 0];
            tinyobj::real_t vy = attrib.vertices[3 * idx + 1];
            tinyobj::real_t vz = attrib.vertices[3 * idx + 2];
            [self addPoint:simd_make_float3(vx, vy, vz)];
        }

        // Read normals
        for (size_t idx = 0; idx < attrib.normals.size() / 3; ++idx) {
            // Access to normal
            tinyobj::real_t vx = attrib.normals[3 * idx + 0];
            tinyobj::real_t vy = attrib.normals[3 * idx + 1];
            tinyobj::real_t vz = attrib.normals[3 * idx + 2];
            [self addNormal:simd_make_float3(vx, vy, vz)];
        }

        // Read UVs
        for (size_t idx = 0; idx < attrib.texcoords.size() / 2; ++idx) {
            // Access to UV
            tinyobj::real_t tu = attrib.texcoords[2 * idx + 0];
            tinyobj::real_t tv = attrib.texcoords[2 * idx + 1];
            [self addUv:simd_make_float2(tu, tv)];
        }

        // Read faces
        for (auto &shape: shapes) {
            size_t idx = 0;

            for (size_t f = 0; f < shape.mesh.num_face_vertices.size(); ++f) {
                const size_t fv = shape.mesh.num_face_vertices[f];

                if (fv == 3) {
                    if (!attrib.vertices.empty()) {
                        [self addPointTriangle:simd_make_uint3(
                                shape.mesh.indices[idx].vertex_index,
                                shape.mesh.indices[idx + 1].vertex_index,
                                shape.mesh.indices[idx + 2].vertex_index)];
                    }

                    if (!attrib.normals.empty()) {
                        [self addNormalTriangle:simd_make_uint3(
                                shape.mesh.indices[idx].normal_index,
                                shape.mesh.indices[idx + 1].normal_index,
                                shape.mesh.indices[idx + 2].normal_index)];
                    }

                    if (!attrib.texcoords.empty()) {
                        [self addUvTriangle:simd_make_uint3(
                                shape.mesh.indices[idx].texcoord_index,
                                shape.mesh.indices[idx + 1].texcoord_index,
                                shape.mesh.indices[idx + 2].texcoord_index)];
                    }
                }

                idx += fv;
            }
        }
        file.close();

        return true;
    } else {
        return false;
    }
}

- (void)prepare:(bool)resize {
    size_t triangleCount = _uvIndices.size();
    globalBBox = bvh::BoundingBox<float>((bvh::Vector3<float>(std::numeric_limits<float>::max())),
                                         (bvh::Vector3<float>(std::numeric_limits<float>::min())));
    primBBoxes = std::vector<bvh::BoundingBox<float>>(triangleCount);
    primCenters = std::vector<bvh::Vector3<float>>(triangleCount);
    for(size_t i = 0; i < triangleCount; ++i) {
        auto v1 = _points[_pointIndices[i][0]];
        auto v2 = _points[_pointIndices[i][1]];
        auto v3 = _points[_pointIndices[i][2]];

        bvh::BoundingBox<float> primBBox((bvh::Vector3<float>(std::numeric_limits<float>::max())),
                                           (bvh::Vector3<float>(std::numeric_limits<float>::min())));
        primBBox.extend(v1);
        primBBox.extend(v2);
        primBBox.extend(v3);
        primBBoxes[i] = primBBox;
        primCenters[i] = 1.0f / 3 * (v1 + v2 + v3);

        globalBBox.extend(primBBox);
    }
    
    if (resize) {
        bvh::Vector3<float> extent = globalBBox.max - globalBBox.min;
        const float maxExtent = std::max(extent[2], std::max(extent[0], extent[1]));
        const bvh::Vector3<float> offset = -0.5f * extent;
        const float scale = 2 / maxExtent;
        for(auto& vertex: _points) {
            vertex = scale * (vertex + offset);
        }
        
        for(auto& center: primCenters) {
            center = scale * (center + offset);
        }
        
        for(auto& bbox: primBBoxes) {
            bbox.max = scale * (bbox.max + offset);
            bbox.min = scale * (bbox.min + offset);
        }
        
        globalBBox.max = scale * (globalBBox.max + offset);
        globalBBox.min = scale * (globalBBox.min + offset);
    }
}

- (void)buildBVH:(id<MTLDevice>)device :(bool)resize {
    [self prepare:resize];
    size_t triangleCount = _uvIndices.size();
    
    bvh::Bvh<float> tree;
    bvh::LocallyOrderedClusteringBuilder<bvh::Bvh<float>, uint32_t> builder(tree);
    builder.build(globalBBox, primBBoxes.data(), primCenters.data(), triangleCount);
    bvh::LeafCollapser<bvh::Bvh<float>> leafCollapser(tree);
    leafCollapser.collapse();
    
    // convert
    vertices_.clear();
    normals_.clear();
    nodes_.resize(tree.node_count);
    for(size_t ni = 0; ni < tree.node_count; ++ni) {
        auto &node = tree.nodes[ni];
        nodes_[ni].bbox[0] = node.bounds[0];
        nodes_[ni].bbox[1] = node.bounds[2];
        nodes_[ni].bbox[2] = node.bounds[4];
        nodes_[ni].bbox[3] = node.bounds[1];
        nodes_[ni].bbox[4] = node.bounds[3];
        nodes_[ni].bbox[5] = node.bounds[5];

        if(node.is_leaf()) {
            const size_t primBeg = vertices_.size() / 3;
            const size_t iEnd = node.first_child_or_primitive + node.primitive_count;
            for(size_t i = node.first_child_or_primitive; i < iEnd; ++i) {
                const size_t pi = tree.primitive_indices[i];
                auto v = _points[_pointIndices[pi][0]];
                vertices_.push_back(simd_make_float3(v[0], v[1], v[2]));
                v = _points[_pointIndices[pi][1]];
                vertices_.push_back(simd_make_float3(v[0], v[1], v[2]));
                v = _points[_pointIndices[pi][2]];
                vertices_.push_back(simd_make_float3(v[0], v[1], v[2]));

                v = _normals[_normalIndices[pi][0]];
                normals_.push_back(simd_make_float3(v[0], v[1], v[2]));
                v = _normals[_normalIndices[pi][1]];
                normals_.push_back(simd_make_float3(v[0], v[1], v[2]));
                v = _normals[_normalIndices[pi][2]];
                normals_.push_back(simd_make_float3(v[0], v[1], v[2]));
            }
            const size_t primEnd = vertices_.size() / 3;

            assert(primEnd != primBeg);
            nodes_[ni].childIndex = static_cast<uint32_t>(primBeg);
            nodes_[ni].childCount = static_cast<uint32_t>(primEnd - primBeg);
        } else {
            nodes_[ni].childIndex = node.first_child_or_primitive;
            nodes_[ni].childCount = 0;
        }
    }
    
    nodeBuffer = [device newBufferWithBytes:nodes_.data() length:nodes_.size() * sizeof(Node)
                                    options:MTLResourceStorageModeManaged];
    verticesBuffer = [device newBufferWithBytes:vertices_.data() length:vertices_.size() * sizeof(simd_float3)
                                        options:MTLResourceStorageModeManaged];
    normalBuffer = [device newBufferWithBytes:normals_.data() length:normals_.size() * sizeof(simd_float3)
                                      options:MTLResourceStorageModeManaged];
}

@end
