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

namespace {
    void computePlane(const simd_float3& center, const simd_float3& A, const simd_float3& B, const simd_float3& C, float* n) {
        float vx = (B[0] - C[0]);
        float vy = (B[1] - C[1]);
        float vz = (B[2] - C[2]);

        float wx = (A[0] - B[0]);
        float wy = (A[1] - B[1]);
        float wz = (A[2] - B[2]);

        float vw_x = vy * wz - vz * wy;
        float vw_y = vz * wx - vx * wz;
        float vw_z = vx * wy - vy * wx;

        float mag = (float)sqrt((vw_x * vw_x) + (vw_y * vw_y) + (vw_z * vw_z));

        if (mag < 0.000001f) {
            mag = 0;
        } else {
            mag = 1.0f / mag;
        }

        float x = vw_x * mag;
        float y = vw_y * mag;
        float z = vw_z * mag;

        n[0] = x;
        n[1] = y;
        n[2] = z;
        n[3] = 0.0f - ((x * A[0]) + (y * A[1]) + (z * A[2]));
        
        if (x * (center[0] - A[0]) + y * (center[1] - A[1]) + z * (center[2] - A[2]) > 0) {
            n[0] *= -1;
            n[1] *= -1;
            n[2] *= -1;
            n[3] *= -1;
        }
    }
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
            [self createConvexMesh:physics points:points pointsCount:pointsCount];
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
                  points:(simd_float3 *_Nonnull)points
             pointsCount:(uint32_t)pointsCount
                triangles:(simd_uint3 *_Nullable)triangles
            triangleCount:(uint32_t)triangleCount
                  center: (simd_float3) center {
    self->isConvex = true;
    self->isUint16 = false;
    physics.c_cooking->setParams(*params);
    
    auto meshGeometry = new PxConvexMeshGeometry();
    super.c_geometry = meshGeometry;
    meshGeometry->scale = scale;

    PxConvexMeshDesc desc;
    desc.points.count = pointsCount;
    desc.points.stride = sizeof(simd_float3);
    desc.points.data = points;
    
    std::vector<uint32_t> indices;
    indices.reserve(triangleCount * 3);
    std::vector<PxHullPolygon> hulls;
    hulls.reserve(triangleCount);
    for (int i = 0; i < triangleCount; i++) {
        simd_float3 p1 = points[triangles[i].x];
        simd_float3 p2 = points[triangles[i].y];
        simd_float3 p3 = points[triangles[i].z];

        PxHullPolygon hull;
        computePlane(center, p1, p2, p3, hull.mPlane);
        hull.mNbVerts = 3;
        hull.mIndexBase = i * 3;
        hulls.emplace_back(hull);

        indices.push_back(triangles[i].x);
        indices.push_back(triangles[i].y);
        indices.push_back(triangles[i].z);
    }
    desc.polygons.count = triangleCount;
    desc.polygons.stride = sizeof(PxHullPolygon);
    desc.polygons.data = hulls.data();

    desc.indices.count = static_cast<uint32_t>(indices.size());
    desc.indices.stride = sizeof(uint32_t);
    desc.indices.data = indices.data();
    
    desc.flags = PxConvexFlag::eDISABLE_MESH_VALIDATION;
    
    meshGeometry->convexMesh = physics.c_cooking->createConvexMesh(desc, [physics getPhysicsInsertionCallback]);
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

// MARK: - Cooking Data
- (uint32_t)positionCount {
    if (super.c_geometry) {
        if (isConvex) {
            return static_cast<PxConvexMeshGeometry *>(super.c_geometry)->convexMesh->getNbVertices();
        } else {
            return static_cast<PxTriangleMeshGeometry *>(super.c_geometry)->triangleMesh->getNbVertices();
        }
    }
    return 0;
}

- (void)getPosition:(simd_float3 *_Nonnull)points {
    if (super.c_geometry) {
        if (isConvex) {
            auto mesh = static_cast<PxConvexMeshGeometry *>(super.c_geometry)->convexMesh;
            auto vertices = mesh->getVertices();
            auto count = mesh->getNbVertices();
            for (int i = 0; i < count; i++) {
                points[i] = simd_make_float3(vertices[i].x, vertices[i].y, vertices[i].z);
            }
        } else {
            auto mesh = static_cast<PxTriangleMeshGeometry *>(super.c_geometry)->triangleMesh;
            auto vertices = mesh->getVertices();
            auto count = mesh->getNbVertices();
            for (int i = 0; i < count; i++) {
                points[i] = simd_make_float3(vertices[i].x, vertices[i].y, vertices[i].z);
            }
        }
    }
}

- (uint32_t)indicesCount {
    if (super.c_geometry) {
        if (isConvex) {
            auto mesh = static_cast<PxConvexMeshGeometry *>(super.c_geometry)->convexMesh;
            auto count = mesh->getNbPolygons();
            uint32_t total = 0;
            for (int i = 0; i < count; i++) {
                PxHullPolygon data;
                mesh->getPolygonData(i, data);
                total += 2 * data.mNbVerts;
            }
            return total;
        } else {
            auto mesh = static_cast<PxTriangleMeshGeometry *>(super.c_geometry)->triangleMesh;
            auto count = mesh->getNbTriangles();
            return count * 6;
        }
    }
    return 0;
}

- (void)getWireframeIndices:(uint32_t *_Nonnull)indices {
    if (super.c_geometry) {
        uint32_t index = 0;
        if (isConvex) {
            auto mesh = static_cast<PxConvexMeshGeometry *>(super.c_geometry)->convexMesh;
            auto count = mesh->getNbPolygons();
            auto indexBuffer = mesh->getIndexBuffer();
            for (int i = 0; i < count; i++) {
                PxHullPolygon data;
                mesh->getPolygonData(i, data);
                for (int j = 0; j < data.mNbVerts; j++) {
                    indices[index++] = indexBuffer[data.mIndexBase + j];
                    if (j != data.mNbVerts - 1) {
                        indices[index++] = indexBuffer[data.mIndexBase + j + 1];
                    } else {
                        indices[index++] = indexBuffer[data.mIndexBase];
                    }
                }
            }
        } else {
            auto mesh = static_cast<PxTriangleMeshGeometry *>(super.c_geometry)->triangleMesh;
            auto count = mesh->getNbTriangles();
            auto isUint16 = mesh->getTriangleMeshFlags().isSet(PxTriangleMeshFlag::Enum::e16_BIT_INDICES);
            if (isUint16) {
                auto indexBuffer = static_cast<const uint16_t*>(mesh->getTriangles());
                for (int i = 0; i < count; i++) {
                    uint16_t v0 = indexBuffer[i * 3];
                    uint16_t v1 = indexBuffer[i * 3 + 1];
                    uint16_t v2 = indexBuffer[i * 3 + 2];
                    indices[index++] = v0;
                    indices[index++] = v1;
                    indices[index++] = v1;
                    indices[index++] = v2;
                    indices[index++] = v2;
                    indices[index++] = v0;
                }
            } else {
                auto indexBuffer = static_cast<const uint32_t*>(mesh->getTriangles());
                for (int i = 0; i < count; i++) {
                    uint16_t v0 = indexBuffer[i * 3];
                    uint16_t v1 = indexBuffer[i * 3 + 1];
                    uint16_t v2 = indexBuffer[i * 3 + 2];
                    indices[index++] = v0;
                    indices[index++] = v1;
                    indices[index++] = v1;
                    indices[index++] = v2;
                    indices[index++] = v2;
                    indices[index++] = v0;
                }
            }
        }
    }
}

@end
