//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

// Helper struct to store view space bounds.
struct XAxisBounds {
    float3 upper;
    float3 lower;
};

// Calculates the min/max bound for an axis in view space based on the specified radius.
static XAxisBounds getBoundsForAxis(float3 axis, float3 center, float radius, float nearZ) {
    // Intersects or behind near plane.
    bool needsClipping = (center.z - radius) < nearZ;

    // Convert to AZ space - A = axis perpendicular to Z = depth
    const float2 az = float2{dot(axis, center), center.z};
    float tSquared = dot(az, az) - (radius * radius);
    float cosTheta = 0, sinTheta = 0;

    if (tSquared > 0) {
        float t = sqrt(tSquared);
        float cLength = length(az);
        cosTheta = t / cLength;
        sinTheta = radius / cLength;
    }

    float sqrtPart = 0;
    if (needsClipping) {
        float dz = nearZ - az.y;
        sqrtPart = sqrt((radius * radius) - (dz * dz));
    }

    float2 bounds_az[2];
    for (int i = 0; i < 2; ++i) {
        if (tSquared > 0) {
            float2x2 rotateTheta{(float2) {cosTheta, -sinTheta},
                    (float2) {sinTheta, cosTheta}};
            bounds_az[i] = cosTheta * (rotateTheta * az);
        }

        if (needsClipping && (tSquared <= 0 || bounds_az[i].y < nearZ)) {
            bounds_az[i].x = az.x + sqrtPart;
            bounds_az[i].y = nearZ;
        }
        sinTheta *= -1; // negate theta for B
        sqrtPart *= -1; // negate sqrtPart for B
    }

    XAxisBounds b;
    b.upper = bounds_az[0].x * axis;
    b.upper.z = bounds_az[0].y;
    b.lower = bounds_az[1].x * axis;
    b.lower.z = bounds_az[1].y;
    return b;
}

// Helper struct to store results.
struct XBox2D {
    float2 x;
    float2 y;

    XBox2D(float minX, float minY, float maxX, float maxY)
            : x{minX, maxX}, y{minY, maxY} {
    }

    float2 min() {
        return float2{x.x, y.x};
    }

    float2 max() {
        return float2{x.y, y.y};
    }
};

// Helper function to project bounds points to clip space.
static float3 project(float3 f, float4x4 projMatrix) {
    float4 p = projMatrix * float4{f.x, f.y, f.z, 1.0};
    return p.xyz / p.w;
}

// Calculates the XY bounding box for a bounding sphere projected into screen space.
static XBox2D getBoundingBox(float3 center,
        float radius,
        float nearZ,
        float4x4 projMatrix) {
    XAxisBounds x = getBoundsForAxis(float3{1, 0, 0}, center, radius, nearZ);
    XAxisBounds y = getBoundsForAxis(float3{0, 1, 0}, center, radius, nearZ);

    // Simplified projection:
    //  Y is negated from the original code to match space of culling.
    float maxX = project(x.upper, projMatrix).x;
    float minX = project(x.lower, projMatrix).x;
    float minY = -project(y.upper, projMatrix).y;
    float maxY = -project(y.lower, projMatrix).y;
    return XBox2D(minX, minY, maxX, maxY);
}
