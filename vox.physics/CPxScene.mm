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
#include "CPXHelper.h"
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
            if (filterCallback(getUUID(shape))) {
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
    _scene->setGravity(transform(vec));
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
                   position:(simd_float3)position
                   rotation:(simd_quatf)rotation
                   distance:(float)distance
                        hit:(LocationHit *_Nonnull)hit {
    PxRaycastHit pxHit = PxRaycastHit();
    auto result = PxGeometryQuery::raycast(transform(origin), transform(unitDir),
            [shape getGeometry].any(), transform(position, rotation),
            distance, PxHitFlags(PxHitFlag::eDEFAULT), 1, &pxHit);
    if (result > 0) {
        hit->position = transform(pxHit.position);
        hit->normal = transform(pxHit.normal);
        hit->distance = pxHit.distance;
        hit->index = getUUID(pxHit.shape);
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
            transform(origin), transform(unitDir),
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
            transform(origin), transform(unitDir),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHit, filterData, &filterCall);

    if (result) {
        hit->position = transform(pxHit.position);
        hit->normal = transform(pxHit.normal);
        hit->distance = pxHit.distance;
        hit->index = getUUID(pxHit.shape);
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
            transform(origin), transform(unitDir),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHits.data(), hitCount, blockingHit, filterData, &filterCall);
    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = getUUID(pxHit.shape);
            locHit.distance = pxHit.distance;
            locHit.position = transform(pxHit.position);
            locHit.normal = transform(pxHit.normal);
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Sweep
- (bool)sweepSpecificWith:(simd_float3)unitDir
                 distance:(float)distance
                   shape0:(CPxShape *_Nonnull)shape0
                position0:(simd_float3)position0
                rotation0:(simd_quatf)rotation0
                   shape1:(CPxShape *_Nonnull)shape1
                position1:(simd_float3)position1
                rotation1:(simd_quatf)rotation1
                      hit:(LocationHit *_Nonnull)hit {
    PxSweepHit pxHit = PxSweepHit();
    auto result = PxGeometryQuery::sweep(transform(unitDir), distance,
            [shape0 getGeometry].any(), transform(position0, rotation0),
            [shape1 getGeometry].any(), transform(position1, rotation1), pxHit);
    if (result) {
        hit->position = transform(pxHit.position);
        hit->normal = transform(pxHit.normal);
        hit->distance = pxHit.distance;
        hit->index = getUUID(pxHit.shape);
    }
    return result;
}

- (bool)sweepAnyWith:(CPxShape *_Nonnull)shape
              origin:(simd_float3)origin
            rotation:(simd_quatf)rotation
             unitDir:(simd_float3)unitDir
            distance:(float)distance
      filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSweepHit pxHit = PxSweepHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    return PxSceneQueryExt::sweepAny(*_scene, [shape getGeometry].any(), transform(origin, rotation),
            transform(unitDir),
            distance, PxHitFlags(PxHitFlag::eDEFAULT), pxHit, filterData, &filterCall);
}

- (bool)sweepSingleWith:(CPxShape *_Nonnull)shape
                 origin:(simd_float3)origin
               rotation:(simd_quatf)rotation
                unitDir:(simd_float3)unitDir
               distance:(float)distance
                    hit:(LocationHit *_Nonnull)hit
         filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSweepHit pxHit = PxSweepHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    bool result = PxSceneQueryExt::sweepSingle(*_scene, [shape getGeometry].any(),
            transform(origin, rotation),
            transform(unitDir),
            distance, PxHitFlags(PxHitFlag::eDEFAULT), pxHit, filterData, &filterCall);

    if (result) {
        hit->position = transform(pxHit.position);
        hit->normal = transform(pxHit.normal);
        hit->distance = pxHit.distance;
        hit->index = getUUID(pxHit.shape);
    }

    return result;
}

- (int)sweepMultipleWith:(CPxShape *_Nonnull)shape
                  origin:(simd_float3)origin
                rotation:(simd_quatf)rotation
                 unitDir:(simd_float3)unitDir
                distance:(float)distance
                     hit:(LocationHit *_Nonnull)hit
                hitCount:(uint32_t)hitCount
          filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    std::vector<PxSweepHit> pxHits(hitCount);
    bool blockingHit;
    int result = PxSceneQueryExt::sweepMultiple(*_scene, [shape getGeometry].any(), transform(origin, rotation),
            transform(unitDir),
            distance, PxHitFlags(PxHitFlag::eDEFAULT),
            pxHits.data(), hitCount, blockingHit, filterData, &filterCall);
    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = getUUID(pxHit.shape);
            locHit.distance = pxHit.distance;
            locHit.position = transform(pxHit.position);
            locHit.normal = transform(pxHit.normal);
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Overlap
- (bool)overlapSpecificWith:(CPxShape *_Nonnull)shape0
                  position0:(simd_float3)position0
                  rotation0:(simd_quatf)rotation0
                     shape1:(CPxShape *_Nonnull)shape1
                  position1:(simd_float3)position1
                  rotation1:(simd_quatf)rotation1 {
    return PxGeometryQuery::overlap([shape0 getGeometry].any(), transform(position0, rotation0),
            [shape1 getGeometry].any(), transform(position1, rotation1));
}

- (bool)overlapAnyWith:(CPxShape *_Nonnull)shape
                origin:(simd_float3)origin
              rotation:(simd_quatf)rotation
        filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxOverlapHit pxHit = PxOverlapHit();
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    return PxSceneQueryExt::overlapAny(*_scene, [shape getGeometry].any(), transform(origin, rotation),
            pxHit, filterData, &filterCall);
}

- (int)overlapMultipleWith:(CPxShape *_Nonnull)shape
                    origin:(simd_float3)origin
                  rotation:(simd_quatf)rotation
                       hit:(LocationHit *_Nonnull)hit
                  hitCount:(uint32_t)hitCount
            filterCallback:(bool (^ _Nullable)(uint32_t obj1))filterCallback {
    PxSceneQueryFilterData filterData = PxSceneQueryFilterData();
    filterData.flags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC | PxQueryFlag::ePREFILTER);
    CustomFilter filterCall(filterCallback);

    std::vector<PxOverlapHit> pxHits(hitCount);
    int result = PxSceneQueryExt::overlapMultiple(*_scene, [shape getGeometry].any(), transform(origin, rotation),
            pxHits.data(), hitCount, filterData, &filterCall);

    if (result > 0) {
        for (int i = 0; i < result; i++) {
            auto &pxHit = pxHits[i];
            LocationHit locHit;
            locHit.index = getUUID(pxHit.shape);
            hit[i] = locHit;
        }
    }
    return result;
}

//MARK: - Other Query
- (bool)computePenetration:(simd_float3 *_Nonnull)direction
                     depth:(float *_Nonnull)depth
                    shape0:(CPxShape *_Nonnull)shape0
                 position0:(simd_float3)position0
                 rotation0:(simd_quatf)rotation0
                    shape1:(CPxShape *_Nonnull)shape1
                 position1:(simd_float3)position1
                 rotation1:(simd_quatf)rotation1 {
    PxVec3 dir;
    auto result = PxGeometryQuery::computePenetration(dir, *depth, [shape0 getGeometry].any(), transform(position0, rotation0),
            [shape1 getGeometry].any(), transform(position1, rotation1));
    *direction = transform(dir);
    return result;
}

- (float)closestPoint:(simd_float3)point
                shape:(CPxShape *_Nonnull)shape
             position:(simd_float3)position
             rotation:(simd_quatf)rotation
              closest:(simd_float3 *_Nonnull)closest {
    PxVec3 pt;
    auto result = PxGeometryQuery::pointDistance(transform(point),
            [shape getGeometry].any(), transform(position, rotation),
            &pt);
    if (result > 0) {
        *closest = transform(pt);
    }
    return result;
}

// MARK: - Collider Filter
- (bool)getGroupCollisionFlag:(const uint16_t)group1
                       group2:(const uint16_t)group2 {
    return PxGetGroupCollisionFlag(group1, group2);
}

- (void)setGroupCollisionFlag:(const uint16_t)group1
                       group2:(const uint16_t)group2
                       enable:(const bool)enable {
    PxSetGroupCollisionFlag(group1, group2, enable);
}

// MARK: - Visualize
- (float)visualScale {
    return _scene->getVisualizationParameter(PxVisualizationParameter::Enum::eSCALE);
}

- (void)setVisualScale:(float)visualScale {
    _scene->setVisualizationParameter(PxVisualizationParameter::Enum::eSCALE, visualScale);
}

- (void)setVisualType:(uint32_t)type
                value:(bool)value {
    _scene->setVisualizationParameter(PxVisualizationParameter::Enum(type), value);
}

- (void)draw:(void (^ _Nullable)(simd_float3 p0, uint32_t color))addPoint
            :(void (^ _Nullable)(uint32_t count))checkResizePoint
            :(void (^ _Nullable)(simd_float3 p0, simd_float3 p1,
                                 uint32_t color0, uint32_t color1))addLine
            :(void (^ _Nullable)(uint32_t count))checkResizeLine
            :(void (^ _Nullable)(simd_float3 p0, simd_float3 p1, simd_float3 p2,
                                 uint32_t color0, uint32_t color1, uint32_t color2))addTriangle
            :(void (^ _Nullable)(uint32_t count))checkResizeTriangle
            :(void (^ _Nullable)(simd_float3 p0, uint32_t color, float size, NSString* string))addText
            :(void (^ _Nullable)(uint32_t count))checkResizeText {
    const PxRenderBuffer& debugRenderable = _scene->getRenderBuffer();
    // Points
    const PxU32 numPoints = debugRenderable.getNbPoints();
    if(numPoints) {
        const PxDebugPoint* PX_RESTRICT points = debugRenderable.getPoints();
        checkResizePoint(numPoints);
        for(PxU32 i=0; i<numPoints; i++) {
            const PxDebugPoint& point = points[i];
            addPoint(transform(point.pos), point.color);
        }
    }

    // Lines
    const PxU32 numLines = debugRenderable.getNbLines();
    if(numLines) {
        const PxDebugLine* PX_RESTRICT lines = debugRenderable.getLines();
        checkResizeLine(numLines * 2);
        for(PxU32 i=0; i<numLines; i++) {
            const PxDebugLine& line = lines[i];
            addLine(transform(line.pos0), transform(line.pos1), line.color0, line.color1);
        }
    }

    // Triangles
    const PxU32 numTriangles = debugRenderable.getNbTriangles();
    if(numTriangles) {
        const PxDebugTriangle* PX_RESTRICT triangles = debugRenderable.getTriangles();
        checkResizeTriangle(numTriangles * 3);
        for(PxU32 i=0; i<numTriangles; i++) {
            const PxDebugTriangle& triangle = triangles[i];
            addTriangle(transform(triangle.pos0), transform(triangle.pos1), transform(triangle.pos2),
                        triangle.color0, triangle.color1, triangle.color2);
        }
    }
    
    // Text
    const PxU32 numTexts = debugRenderable.getNbTexts();
    if (numTexts) {
        const PxDebugText* PX_RESTRICT texts = debugRenderable.getTexts();
        checkResizeText(numTexts);
        for(PxU32 i=0; i<numTexts; i++) {
            const PxDebugText& text = texts[i];
            addText(transform(text.position), text.color, text.size, [[NSString alloc]initWithUTF8String:text.string]);
        }
    }
}


@end
