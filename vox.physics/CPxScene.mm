//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxScene.h"
#import "CPxScene+Internal.h"
#import "CPxShape+Internal.h"
#import "CPxRigidActor+Internal.h"
#import "characterkinematic/CPxControllerManager+Internal.h"
#include <functional>
#include <vector>

using namespace physx;

namespace {
    class CustomFilter : public PxQueryFilterCallback {
    public:
        std::function<bool(uint32_t obj1)> filterCallback;

        CustomFilter(std::function<bool(uint32_t obj1)> filterCallback) : filterCallback(filterCallback) {
        }

        PxQueryHitType::Enum preFilter(const PxFilterData &filterData, const PxShape *shape,
                const PxRigidActor *actor, PxHitFlags &queryFlags) override {
            auto index = shape->getQueryFilterData().word0;
            if (filterCallback(index)) {
                return PxQueryHitType::Enum::eBLOCK;
            } else {
                return PxQueryHitType::Enum::eNONE;
            }
        }

        PxQueryHitType::Enum postFilter(const PxFilterData &filterData, const PxQueryHit &hit) override {
            return PxQueryHitType::Enum::eBLOCK;
        }
    };
} // namespace

@implementation CPxScene {
    PxScene *_scene;
}

- (instancetype)initWithScene:(PxScene *)scene {
    self = [super init];
    if (self) {
        _scene = scene;
    }
    return self;
}

- (void)setGravity:(simd_float3)vec {
    _scene->setGravity(PxVec3(vec.x, vec.y, vec.z));
}

- (void)simulate:(float)elapsedTime {
    _scene->simulate(elapsedTime);
}

- (bool)fetchResults:(bool)block {
    return _scene->fetchResults(block);
}

- (void)addActorWith:(CPxRigidActor *)actor {
    _scene->addActor(*actor.c_actor);
}

- (void)removeActorWith:(CPxRigidActor *)actor {
    _scene->removeActor(*actor.c_actor);
}

- (CPxControllerManager *)createControllerManager {
    return [[CPxControllerManager alloc] initWithManager:PxCreateControllerManager(*_scene)];
}

//MARK: - Raycast
- (bool)raycastSpecificWith:(simd_float3)origin
                    unitDir:(simd_float3)unitDir
                      shape:(CPxShape *_Nonnull)shape
                   distance:(float)distance
                        hit:(LocationHit *_Nonnull)hit {
    PxRaycastHit pxHit = PxRaycastHit();
    auto result = PxGeometryQuery::raycast(PxVec3(origin.x, origin.y, origin.z),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            [shape getGeometry].any(), [shape getLocalPose],
            distance, PxHitFlags(PxHitFlag::eDEFAULT), 1, &pxHit);
    if (result > 0) {
        hit->position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
        hit->normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
        hit->distance = pxHit.distance;
        hit->index = pxHit.shape->getQueryFilterData().word0;
    }
    return result > 0;
}

- (bool)raycastAnyWith:(simd_float3)origin
               unitDir:(simd_float3)unitDir
              distance:(float)distance
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryHit pxHit = PxSceneQueryHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    return PxSceneQueryExt::raycastAny(*_scene,
            PxVec3(origin.x, origin.y, origin.z),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, pxHit, filterData, &filterCall);
}

- (bool)raycastSingleWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
                      hit:(LocationHit *_Nonnull)hit
           filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxRaycastHit pxHit = PxRaycastHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    bool result = PxSceneQueryExt::raycastSingle(*_scene,
            PxVec3(origin.x, origin.y, origin.z),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHit, filterData, &filterCall);

    if (result) {
        hit->position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
        hit->normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
        hit->distance = pxHit.distance;
        hit->index = pxHit.shape->getQueryFilterData().word0;
    }

    return result;
}

- (int)raycastMultipleWith:(simd_float3)origin
                   unitDir:(simd_float3)unitDir
                  distance:(float)distance
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    std::vector<PxRaycastHit> pxHits(hitCount);
    bool blockingHit;
    int result = PxSceneQueryExt::raycastMultiple(*_scene,
            PxVec3(origin.x, origin.y, origin.z),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHits.data(), hitCount, blockingHit, filterData, &filterCall);
    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = pxHit.shape->getQueryFilterData().word0;
            locHit.distance = pxHit.distance;
            locHit.position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
            locHit.normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Sweep
- (bool)sweepSpecificWith:(simd_float3)unitDir
                 distance:(float)distance
                   shape0:(CPxShape *_Nonnull)shape0
                   shape1:(CPxShape *_Nonnull)shape1
                      hit:(LocationHit *_Nonnull)hit {
    PxSweepHit pxHit = PxSweepHit();
    auto result = PxGeometryQuery::sweep(PxVec3(unitDir.x, unitDir.y, unitDir.z), distance,
            [shape0 getGeometry].any(), [shape0 getLocalPose],
            [shape1 getGeometry].any(), [shape1 getLocalPose], pxHit);
    if (result) {
        hit->position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
        hit->normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
        hit->distance = pxHit.distance;
        hit->index = pxHit.shape->getQueryFilterData().word0;
    }
    return result;
}

- (bool)sweepAnyWith:(CPxShape *_Nonnull)shape
              origin:(simd_float3)origin
             unitDir:(simd_float3)unitDir
            distance:(float)distance
      filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSweepHit pxHit = PxSweepHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    auto pose = [shape getLocalPose];
    return PxSceneQueryExt::sweepAny(*_scene, [shape getGeometry].any(),
            PxTransform(PxVec3(origin.x, origin.y, origin.z), pose.q),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT), pxHit, filterData, &filterCall);
}

- (bool)sweepSingleWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
                unitDir:(simd_float3)unitDir
               distance:(float)distance
                    hit:(LocationHit *_Nonnull)hit
         filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSweepHit pxHit = PxSweepHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    auto pose = [shape getLocalPose];
    bool result = PxSceneQueryExt::sweepSingle(*_scene, [shape getGeometry].any(),
            PxTransform(PxVec3(origin.x, origin.y, origin.z), pose.q),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT), pxHit, filterData, &filterCall);

    if (result) {
        hit->position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
        hit->normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
        hit->distance = pxHit.distance;
        hit->index = pxHit.shape->getQueryFilterData().word0;
    }

    return result;
}

- (int)sweepMultipleWith:(CPxShape *_Nonnull)shape
                  origin:(simd_float3)origin
                 unitDir:(simd_float3)unitDir
                distance:(float)distance
                     hit:(LocationHit *_Nonnull)hit
                hitCount:(uint32_t)hitCount
          filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    auto pose = [shape getLocalPose];
    std::vector<PxSweepHit> pxHits(hitCount);
    bool blockingHit;
    int result = PxSceneQueryExt::sweepMultiple(*_scene, [shape getGeometry].any(),
            PxTransform(PxVec3(origin.x, origin.y, origin.z), pose.q),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHits.data(), hitCount, blockingHit, filterData, &filterCall);
    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = pxHit.shape->getQueryFilterData().word0;
            locHit.distance = pxHit.distance;
            locHit.position = simd_make_float3(pxHit.position.x, pxHit.position.y, pxHit.position.z);
            locHit.normal = simd_make_float3(pxHit.normal.x, pxHit.normal.y, pxHit.normal.z);
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Overlap
- (bool)overlapSpecificWith:(CPxShape *_Nonnull)shape0
                     shape1:(CPxShape *_Nonnull)shape1 {
    return PxGeometryQuery::overlap([shape0 getGeometry].any(), [shape0 getLocalPose],
            [shape1 getGeometry].any(), [shape1 getLocalPose]);
}

- (bool)overlapAnyWith:(CPxShape *_Nonnull)shape
                origin:(simd_float3)origin
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxOverlapHit pxHit = PxOverlapHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    auto pose = [shape getLocalPose];
    return PxSceneQueryExt::overlapAny(*_scene, [shape getGeometry].any(),
            PxTransform(PxVec3(origin.x, origin.y, origin.z), pose.q),
            pxHit, filterData, &filterCall);
}

- (int)overlapMultipleWith:(CPxShape *_Nonnull)shape
                    origin:(simd_float3)origin
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    auto pose = [shape getLocalPose];
    std::vector<PxOverlapHit> pxHits(hitCount);
    int result = PxSceneQueryExt::overlapMultiple(*_scene, [shape getGeometry].any(),
            PxTransform(PxVec3(origin.x, origin.y, origin.z), pose.q),
            pxHits.data(), hitCount, filterData, &filterCall);

    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = pxHit.shape->getQueryFilterData().word0;
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Other Query
- (bool)computePenetration:(simd_float3 *_Nonnull)direction
                     depth:(float *_Nonnull)depth
                    shape0:(CPxShape *_Nonnull)shape0
                    shape1:(CPxShape *_Nonnull)shape1 {
    PxVec3 dir;
    auto result = PxGeometryQuery::computePenetration(dir, *depth, [shape0 getGeometry].any(), [shape1 getLocalPose],
            [shape1 getGeometry].any(), [shape1 getLocalPose]);
    *direction = simd_make_float3(dir.x, dir.y, dir.z);
    return result;
}

- (float)closestPoint:(simd_float3)point
                shape:(CPxShape *_Nonnull)shape
               cloest:(simd_float3 *_Nonnull)cloest {
    PxVec3 pt;
    auto result = PxGeometryQuery::pointDistance(PxVec3(point.x, point.y, point.z),
            [shape getGeometry].any(), [shape getLocalPose],
            &pt);
    if (result > 0) {
        *cloest = simd_make_float3(pt.x, pt.y, pt.z);
    }
    return result;
}

@end
