//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxScene.h"
#import "CPxScene+Internal.h"
#import "CPxRigidActor+Internal.h"
#import "characterkinematic/CPxControllerManager+Internal.h"

using namespace physx;

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

- (bool)raycastSingleWith:(simd_float3)origin
                  unitDir:(simd_float3)unitDir
                 distance:(float)distance
              outPosition:(simd_float3 *)outPosition
                outNormal:(simd_float3 *)outNormal
              outDistance:(float *)outDistance
                 outIndex:(uint32_t *)outIndex {
    PxRaycastHit hit = PxRaycastHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC);

    bool result = PxSceneQueryExt::raycastSingle(*_scene,
            PxVec3(origin.x, origin.y, origin.z),
            PxVec3(unitDir.x, unitDir.y, unitDir.z),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            hit, filterData);

    if (result) {
        *outPosition = simd_make_float3(hit.position.x, hit.position.y, hit.position.z);
        *outNormal = simd_make_float3(hit.normal.x, hit.normal.y, hit.normal.z);
        *outDistance = hit.distance;
        *outIndex = hit.shape->getQueryFilterData().word0;
    }

    return result;
}

- (CPxControllerManager *)createControllerManager {
    return [[CPxControllerManager alloc] initWithManager:PxCreateControllerManager(*_scene)];
}

@end
