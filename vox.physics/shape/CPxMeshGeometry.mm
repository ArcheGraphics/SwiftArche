//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxMeshGeometry.h"
#import "CPxGeometry+Internal.h"
#import "CPxPhysics+Internal.h"
#import "PxPhysicsAPI.h"
#include <vector>

using namespace physx;

@implementation CPxMeshGeometry {
    bool isConvex;
    PxMeshScale scale;
    PxCooking *c_cooking;
}

// MARK: - Initialization

- (instancetype)initWithPhysics:(CPxPhysics *_Nonnull)physics {
    isConvex = true;
    scale = PxMeshScale();
    c_cooking = PxCreateCooking(PX_PHYSICS_VERSION, [physics getFoundation], PxCookingParams(PxTolerancesScale()));

    self = [super initWithGeometry:NULL];
    return self;
}

- (void)setCookParameter:(CPxPhysics *_Nonnull)physics
                   value:(uint8_t)value {
    PxCookingParams params = PxCookingParams(PxTolerancesScale());
    params.meshPreprocessParams = PxMeshPreprocessingFlags(value);
    c_cooking->setParams(params);
}

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(NSArray *_Nonnull)points {
    auto meshGeometry = new PxConvexMeshGeometry();
    super.c_geometry = meshGeometry;
    isConvex = true;
    meshGeometry->scale = scale;

    PxConvexMeshDesc desc;
    desc.points.count = static_cast<uint32_t>([points count]);
    std::vector<PxVec3> pts(desc.points.count);
    for (int i = 0; i < desc.points.count; i++) {
        [[points objectAtIndex:i] getValue:&pts[i]];
    }

    desc.points.stride = sizeof(simd_float3);
    desc.points.data = pts.data();
    desc.flags = PxConvexFlag::eCOMPUTE_CONVEX;
    meshGeometry->convexMesh = c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
}

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(NSArray *_Nonnull)points
                 indices:(NSArray *_Nonnull)indices
                isUint16:(bool)isUint16 {
    auto meshGeometry = new PxConvexMeshGeometry();
    super.c_geometry = meshGeometry;
    isConvex = true;
    meshGeometry->scale = scale;

    PxConvexMeshDesc desc;
    desc.points.count = static_cast<uint32_t>([points count]);
    std::vector<PxVec3> pts(desc.points.count);
    for (int i = 0; i < desc.points.count; i++) {
        [[points objectAtIndex:i] getValue:&pts[i]];
    }
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = pts.data();

    desc.indices.count = static_cast<uint32_t>([indices count]);
    if (isUint16) {
        std::vector<uint16_t> idx(desc.indices.count);
        for (int i = 0; i < desc.indices.count; i++) {
            [[indices objectAtIndex:i] getValue:&idx[i]];
        }
        desc.indices.stride = sizeof(uint16);
        desc.indices.data = idx.data();
        desc.flags = PxConvexFlag::e16_BIT_INDICES;
        meshGeometry->convexMesh = c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
    } else {
        std::vector<uint32_t> idx(desc.indices.count);
        for (int i = 0; i < desc.indices.count; i++) {
            [[indices objectAtIndex:i] getValue:&idx[i]];
        }
        desc.indices.stride = sizeof(uint32_t);
        desc.indices.data = idx.data();
        meshGeometry->convexMesh = c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
    }
}

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(NSArray *_Nonnull)points {
    auto meshGeometry = new PxTriangleMeshGeometry();
    super.c_geometry = meshGeometry;
    isConvex = false;
    meshGeometry->scale = scale;

    PxTriangleMeshDesc desc;
    desc.points.count = static_cast<uint32_t>([points count]);
    std::vector<PxVec3> pts(desc.points.count);
    for (int i = 0; i < desc.points.count; i++) {
        [[points objectAtIndex:i] getValue:&pts[i]];
    }
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = pts.data();
    meshGeometry->triangleMesh = c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
}

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(NSArray *_Nonnull)points
                   indices:(NSArray *_Nonnull)indices
                  isUint16:(bool)isUint16 {
    auto meshGeometry = new PxTriangleMeshGeometry();
    super.c_geometry = meshGeometry;
    isConvex = false;
    meshGeometry->scale = scale;

    PxTriangleMeshDesc desc;
    desc.points.count = static_cast<uint32_t>([points count]);
    std::vector<PxVec3> pts(desc.points.count);
    for (int i = 0; i < desc.points.count; i++) {
        [[points objectAtIndex:i] getValue:&pts[i]];
    }
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = pts.data();

    desc.triangles.count = static_cast<uint32_t>([indices count]);
    if (isUint16) {
        std::vector<uint16_t> idx(desc.triangles.count);
        for (int i = 0; i < desc.triangles.count; i++) {
            [[indices objectAtIndex:i] getValue:&idx[i]];
        }
        desc.triangles.stride = sizeof(uint16) * 3;
        desc.triangles.data = idx.data();
        desc.flags = PxMeshFlag::e16_BIT_INDICES;
        meshGeometry->triangleMesh = c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
    } else {
        std::vector<uint32_t> idx(desc.triangles.count);
        for (int i = 0; i < desc.triangles.count; i++) {
            [[indices objectAtIndex:i] getValue:&idx[i]];
        }
        desc.triangles.stride = sizeof(uint32_t) * 3;
        desc.triangles.data = idx.data();
        meshGeometry->triangleMesh = c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
    }
}

- (void)setScaleWith:(float)hx hy:(float)hy hz:(float)hz {
    scale = PxMeshScale(PxVec3(hx, hy, hz));
    if (super.c_geometry) {
        if (isConvex) {
            static_cast<PxConvexMeshGeometry *>(super.c_geometry)->scale = scale;
        } else {
            static_cast<PxTriangleMeshGeometry *>(super.c_geometry)->scale = scale;
        }
    }
}

@end
