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
    void *points;
    uint32_t pointsCount;
    void *indices;
    uint32_t indicesCount;
    bool isUint16;

    PxMeshScale scale;
    PxCookingParams *params;
}

// MARK: - Initialization
- (instancetype _Nonnull )initWith:(CPxPhysics *_Nonnull)physics {
    isConvex = false;
    points = nullptr;
    indices = nullptr;
    isUint16 = false;

    scale = PxMeshScale();
    params = new PxCookingParams(PxTolerancesScale());

    auto meshGeometry = new PxTriangleMeshGeometry();
    PxTriangleMeshDesc desc;
    desc.points.count = 3;
    desc.points.stride = sizeof(PxVec3);
    std::vector<PxVec3> pts(3);
    pts[0] = PxVec3(0,0,0);
    pts[1] = PxVec3(1,0,0);
    pts[2] = PxVec3(0,1,0);
    desc.points.data = pts.data();
    meshGeometry->triangleMesh = physics.c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
    self = [super initWithGeometry:meshGeometry];
    return self;
}

- (void)dealloc {
    delete params;
}

- (void)setCookParameter:(CPxPhysics *_Nonnull)physics
                   value:(uint8_t)value {
    params->meshPreprocessParams = PxMeshPreprocessingFlags(value);
    [self createMesh:physics points:points pointsCount:pointsCount
             indices:indices indicesCount:indicesCount isUint16:isUint16 isConvex:isConvex];
}

- (void)createMesh:(CPxPhysics *_Nonnull)physics
            points:(void *_Nonnull)points
       pointsCount:(uint32_t)pointsCount
           indices:(void *_Nullable)indices
      indicesCount:(uint32_t)indicesCount
          isUint16:(bool)isUint16
          isConvex:(bool)isConvex {
    self->isConvex = isConvex;
    self->isUint16 = isUint16;
    self->indices = indices;
    self->indicesCount = indicesCount;
    self->points = points;
    self->pointsCount = pointsCount;
    physics.c_cooking->setParams(*params);

    if (isConvex) {
        if (indices == nullptr) {
            [self createConvexMesh:physics points:points pointsCount:pointsCount];
        } else {
            [self createConvexMesh:physics points:points pointsCount:pointsCount
                           indices:indices indicesCount:indicesCount isUint16:isUint16];
        }
    } else {
        if (indices == nullptr) {
            [self createTriangleMesh:physics points:points pointsCount:pointsCount];
        } else {
            [self createTriangleMesh:physics points:points pointsCount:pointsCount
                           indices:indices indicesCount:indicesCount isUint16:isUint16];
        }
    }
}

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(void *_Nonnull)points
             pointsCount:(uint32_t)pointsCount {
    auto meshGeometry = new PxConvexMeshGeometry();
    super.c_geometry = meshGeometry;
    meshGeometry->scale = scale;

    PxConvexMeshDesc desc;
    desc.points.count = pointsCount;
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = points;
    desc.flags = PxConvexFlag::eCOMPUTE_CONVEX;
    meshGeometry->convexMesh = physics.c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
}

- (void)createConvexMesh:(CPxPhysics *_Nonnull)physics
                  points:(void *_Nonnull)points
             pointsCount:(uint32_t)pointsCount
                 indices:(void *_Nullable)indices
            indicesCount:(uint32_t)indicesCount
                isUint16:(bool)isUint16 {
    auto meshGeometry = new PxConvexMeshGeometry();
    super.c_geometry = meshGeometry;
    meshGeometry->scale = scale;

    PxConvexMeshDesc desc;
    desc.points.count = pointsCount;
    desc.points.stride = sizeof(PxVec3);
    desc.points.data = points;

    desc.indices.count = indicesCount;
    desc.indices.data = indices;
    if (isUint16) {
        desc.indices.stride = sizeof(uint16);
        desc.flags = PxConvexFlag::e16_BIT_INDICES;
        meshGeometry->convexMesh = physics.c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
    } else {
        desc.indices.stride = sizeof(uint32_t);
        desc.flags = PxConvexFlag::eCOMPUTE_CONVEX;
        meshGeometry->convexMesh = physics.c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
    }
}

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(void *_Nonnull)points
               pointsCount:(uint32_t)pointsCount {
    auto meshGeometry = new PxTriangleMeshGeometry();
    super.c_geometry = meshGeometry;
    meshGeometry->scale = scale;

    PxTriangleMeshDesc desc;
    desc.points.count = pointsCount;
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = points;
    meshGeometry->triangleMesh = physics.c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
}

- (void)createTriangleMesh:(CPxPhysics *_Nonnull)physics
                    points:(void *_Nonnull)points
               pointsCount:(uint32_t)pointsCount
                   indices:(void *_Nullable)indices
              indicesCount:(uint32_t)indicesCount
                  isUint16:(bool)isUint16 {
    auto meshGeometry = new PxTriangleMeshGeometry();
    super.c_geometry = meshGeometry;
    meshGeometry->scale = scale;

    PxTriangleMeshDesc desc;
    desc.points.count = pointsCount;
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = points;

    desc.triangles.count = indicesCount / 3;
    desc.triangles.data = indices;
    if (isUint16) {
        desc.triangles.stride = sizeof(uint16) * 3;
        desc.flags = PxMeshFlag::e16_BIT_INDICES;
        meshGeometry->triangleMesh = physics.c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
    } else {
        desc.triangles.stride = sizeof(uint32_t) * 3;
        meshGeometry->triangleMesh = physics.c_cooking->createTriangleMesh(desc, [physics getPhysicsInsertionCallback]);
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
