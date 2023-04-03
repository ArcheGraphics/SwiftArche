//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "mesh_types.h"

// Checks if this box contains the specified point.
bool contains(MetalBoundingBox3 aabb, simd_float3 pos) {
    return simd::all(pos > aabb.min) && simd::all(pos < aabb.max);
}

// Center of this box.
simd_float3 center(MetalBoundingBox3 aabb) {
    return (aabb.min + aabb.max) * 0.5f;
}

// Converts a 3-bit index into a corner.
simd_float3 getCorner(MetalBoundingBox3 aabb, uint index) {
    return (simd::float3)
    {
        (index & 0b100) ? aabb.min.x : aabb.max.x,
        (index & 0b010) ? aabb.min.y : aabb.max.y,
        (index & 0b001) ? aabb.min.z : aabb.max.z
    };
}

// Encapsulates another bounding box into this.
void encapsulate(thread MetalBoundingBox3& aabb, MetalBoundingBox3 inBox) {
    aabb.min = simd::min(inBox.min, aabb.min);
    aabb.max = simd::max(inBox.max, aabb.max);
}

// Encapsulates a point into this bounding box.
void encapsulate(thread MetalBoundingBox3& aabb, simd::float3 inPoint) {
    aabb.min = simd::min(inPoint, aabb.min);
    aabb.max = simd::max(inPoint, aabb.max);
}

// Constructs an empty bounding box.
MetalBoundingBox3 sEmpty() {
    MetalBoundingBox3 aabb;
    aabb.min = (simd::float3) {FLT_MAX, FLT_MAX, FLT_MAX};
    aabb.max = (simd::float3) {-FLT_MAX, -FLT_MAX, -FLT_MAX};
    return aabb;
}

// MARK: - Sphere
float distanceToPlane(MetalSphere sphere, simd::float4 planeEq) {
    float centerDist = simd::dot(planeEq, simd::float4{sphere.data.x, sphere.data.y, sphere.data.z, 1});
    return centerDist > 0 ? simd::max(0.0f, centerDist - sphere.data.w) : simd::min(0.0f, centerDist + sphere.data.w);
}
