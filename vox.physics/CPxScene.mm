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

@end
