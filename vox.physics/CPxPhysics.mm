//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxPhysics.h"
#import "CPxPhysics+Internal.h"
#import "CPxMaterial+Internal.h"
#import "CPxGeometry+Internal.h"
#import "CPxShape+Internal.h"
#import "CPxRigidActor+Internal.h"
#import "CPxRigidStatic+Internal.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxScene+Internal.h"
#import "joint/CPxJoint+Internal.h"
#import "PxPhysicsAPI.h"
#import "extensions/PxExtensionsAPI.h"
#include "CPXHelper.h"
#include <functional>
#include <vector>

using namespace physx;

@implementation CPxPhysics {
    PxPhysics *_physics;

    PxDefaultAllocator gAllocator;
    PxDefaultErrorCallback gErrorCallback;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializePhysics];
    }
    return self;
}

- (void)initializePhysics {
    physx::PxFoundation *gFoundation = PxCreateFoundation(PX_PHYSICS_VERSION, gAllocator, gErrorCallback);

    _physics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, PxTolerancesScale(), false, nullptr);
    _c_cooking = PxCreateCooking(PX_PHYSICS_VERSION, *gFoundation, PxCookingParams(PxTolerancesScale()));
}

- (PxPhysicsInsertionCallback &)getPhysicsInsertionCallback {
    return _physics->getPhysicsInsertionCallback();
}

- (bool)initExtensions {
    return PxInitExtensions(*_physics, nullptr);
}

- (CPxMaterial *)createMaterialWithStaticFriction:(float)staticFriction
                                  dynamicFriction:(float)dynamicFriction
                                      restitution:(float)restitution {
    return [[CPxMaterial alloc] initWithMaterial:_physics->createMaterial(staticFriction, dynamicFriction, restitution)];
}

- (CPxShape *)createShapeWithGeometry:(CPxGeometry *)geometry
                             material:(CPxMaterial *)material
                          isExclusive:(bool)isExclusive
                           shapeFlags:(uint8_t)shapeFlags {
    return [[CPxShape alloc] initWithShape:_physics->createShape(*geometry.c_geometry, *material.c_material,
            isExclusive, PxShapeFlags(shapeFlags))];
}

- (CPxRigidStatic *)createRigidStaticWithPosition:(simd_float3)position
                                         rotation:(simd_quatf)rotation {
    return [[CPxRigidStatic alloc] initWithStaticActor:_physics->createRigidStatic(transform(position, rotation))];
}

- (CPxRigidDynamic *)createRigidDynamicWithPosition:(simd_float3)position rotation:(simd_quatf)rotation {
    return [[CPxRigidDynamic alloc] initWithDynamicActor:_physics->createRigidDynamic(transform(position, rotation))];
}

- (CPxScene *)createSceneWith:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count))onContactEnter
                onContactExit:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count))onContactExit
                onContactStay:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count))onContactStay
               onTriggerEnter:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2))onTriggerEnter
                onTriggerExit:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2))onTriggerExit
                 onJointBreak:(void (^ _Nullable)(uint32_t obj1, uint32_t obj2, NSString *name))onJointBreak {
    class PxSimulationEventCallbackWrapper : public PxSimulationEventCallback {
    public:
        std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactEnter;
        std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactExit;
        std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactStay;
        std::vector<ContactInfo> userBuffer;

        std::function<void(uint32_t obj1, uint32_t obj2)> onTriggerEnter;
        std::function<void(uint32_t obj1, uint32_t obj2)> onTriggerExit;

        std::function<void(uint32_t obj1, uint32_t obj2, NSString *name)> onJointBreak;

        PxSimulationEventCallbackWrapper(std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactEnter,
                std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactExit,
                std::function<void(uint32_t obj1, uint32_t obj2, void *ptr, uint32_t count)> onContactStay,
                std::function<void(uint32_t obj1, uint32_t obj2)> onTriggerEnter,
                std::function<void(uint32_t obj1, uint32_t obj2)> onTriggerExit,
                std::function<void(uint32_t obj1, uint32_t obj2, NSString *name)> onJointBreak) :
                onContactEnter(onContactEnter), onContactExit(onContactExit), onContactStay(onContactStay),
                onTriggerEnter(onTriggerEnter), onTriggerExit(onTriggerExit), onJointBreak(onJointBreak) {
        }

        PX_INLINE PxU32 extractContacts(std::vector<ContactInfo> &userBuffer, const PxContactPair &pair) const {
            PxU32 nbContacts = 0;

            if (pair.contactCount && userBuffer.size()) {
                PxContactStreamIterator iter(pair.contactPatches, pair.contactPoints,
                        pair.getInternalFaceIndices(), pair.patchCount, pair.contactCount);

                const PxReal *impulses = pair.contactImpulses;
                const PxU32 hasImpulses = (pair.flags & PxContactPairFlag::eINTERNAL_HAS_IMPULSES);

                while (iter.hasNextPatch()) {
                    iter.nextPatch();
                    while (iter.hasNextContact()) {
                        iter.nextContact();
                        ContactInfo &dst = userBuffer[nbContacts];
                        auto point = iter.getContactPoint();
                        dst.position = transform(point);
                        dst.separation = iter.getSeparation();
                        auto normal = iter.getContactNormal();
                        dst.normal = transform(normal);

                        if (hasImpulses) {
                            const PxReal impulse = impulses[nbContacts];
                            dst.impulse = dst.normal * impulse;
                        } else
                            dst.impulse = simd_float3();
                        ++nbContacts;
                        if (nbContacts == userBuffer.size())
                            return nbContacts;
                    }
                }
            }

            return nbContacts;
        }

        void onConstraintBreak(PxConstraintInfo *constraints, PxU32 count) override {
            PxRigidActor *actor0{nullptr};
            PxRigidActor *actor1{nullptr};
            std::vector<PxShape *> shapes(1);
            for (PxU32 i = 0; i < count; i++) {
                PxJoint *joint = reinterpret_cast<PxJoint *>(constraints[i].externalReference);
                joint->getActors(actor0, actor1);
                uint32_t index0 = -1;
                if (actor0 != nullptr) {
                    actor0->getShapes(shapes.data(), 1);
                    index0 = shapes[0]->getQueryFilterData().word3;
                }
                uint32_t index1 = -1;
                if (actor1 != nullptr) {
                    actor1->getShapes(shapes.data(), 1);
                    index1 = shapes[0]->getQueryFilterData().word3;
                }
                onJointBreak(index0, index1, [[NSString alloc] initWithUTF8String:joint->getName()]);
            }
        }

        void onWake(PxActor **, PxU32) override {
        }

        void onSleep(PxActor **, PxU32) override {
        }

        void onContact(const PxContactPairHeader &, const PxContactPair *pairs, PxU32 nbPairs) override {
            for (PxU32 i = 0; i < nbPairs; i++) {
                const PxContactPair &cp = pairs[i];
                userBuffer.resize(cp.contactCount);
                extractContacts(userBuffer, cp);

                if (cp.events & (PxPairFlag::eNOTIFY_TOUCH_FOUND | PxPairFlag::eNOTIFY_TOUCH_CCD)) {
                    onContactEnter(cp.shapes[0]->getQueryFilterData().word3, cp.shapes[1]->getQueryFilterData().word3,
                            userBuffer.data(), static_cast<uint32_t>(userBuffer.size()));
                } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                    if (!cp.flags.isSet(PxContactPairFlag::Enum::eREMOVED_SHAPE_0) &&
                            !cp.flags.isSet(PxContactPairFlag::Enum::eREMOVED_SHAPE_1)) {
                        onContactExit(cp.shapes[0]->getQueryFilterData().word3, cp.shapes[1]->getQueryFilterData().word3,
                                userBuffer.data(), static_cast<uint32_t>(userBuffer.size()));
                    }
                } else if (cp.events & PxPairFlag::eNOTIFY_TOUCH_PERSISTS) {
                    onContactStay(cp.shapes[0]->getQueryFilterData().word3, cp.shapes[1]->getQueryFilterData().word3,
                            userBuffer.data(), static_cast<uint32_t>(userBuffer.size()));
                }
            }
        }

        void onTrigger(PxTriggerPair *pairs, PxU32 count) override {
            for (PxU32 i = 0; i < count; i++) {
                const PxTriggerPair &tp = pairs[i];

                if (tp.status & PxPairFlag::eNOTIFY_TOUCH_FOUND) {
                    onTriggerEnter(tp.triggerShape->getQueryFilterData().word3, tp.otherShape->getQueryFilterData().word3);
                } else if (tp.status & PxPairFlag::eNOTIFY_TOUCH_LOST) {
                    if (!tp.flags.isSet(PxTriggerPairFlag::Enum::eREMOVED_SHAPE_OTHER) &&
                            !tp.flags.isSet(PxTriggerPairFlag::Enum::eREMOVED_SHAPE_TRIGGER)) {
                        onTriggerExit(tp.triggerShape->getQueryFilterData().word3, tp.otherShape->getQueryFilterData().word3);
                    }
                }
            }
        }

        void onAdvance(const PxRigidBody *const *, const PxTransform *, const PxU32) override {
        }
    };

    PxSimulationEventCallbackWrapper *simulationEventCallback =
            new PxSimulationEventCallbackWrapper(onContactEnter, onContactExit, onContactStay,
                    onTriggerEnter, onTriggerExit, onJointBreak);

    PxSceneDesc sceneDesc(_physics->getTolerancesScale());
    sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
    sceneDesc.cpuDispatcher = PxDefaultCpuDispatcherCreate(1);
    sceneDesc.filterShader = PxDefaultSimulationFilterShader;
    sceneDesc.simulationEventCallback = simulationEventCallback;
    sceneDesc.kineKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.staticKineFilteringMode = PxPairFilteringMode::eKEEP;
    sceneDesc.flags |= PxSceneFlag::eENABLE_CCD;

    return [[CPxScene alloc] initWithScene:_physics->createScene(sceneDesc)];
}

//MARK: - Joint
- (CPxFixedJoint *_Nonnull)createFixedJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxFixedJoint alloc] initWithJoint:
            PxFixedJointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

- (CPxRevoluteJoint *_Nonnull)createRevoluteJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxRevoluteJoint alloc] initWithJoint:
            PxRevoluteJointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

- (CPxSphericalJoint *_Nonnull)createSphericalJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxSphericalJoint alloc] initWithJoint:
            PxSphericalJointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

- (CPxDistanceJoint *_Nonnull)createDistanceJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxDistanceJoint alloc] initWithJoint:
            PxDistanceJointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

- (CPxPrismaticJoint *_Nonnull)createPrismaticJoint:(CPxRigidActor *_Nullable)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *_Nullable)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxPrismaticJoint alloc] initWithJoint:
            PxPrismaticJointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

- (CPxD6Joint *)createD6Joint:(CPxRigidActor *)actor0 :(simd_float3)position0 :(simd_quatf)rotation0
        :(CPxRigidActor *)actor1 :(simd_float3)position1 :(simd_quatf)rotation1 {
    return [[CPxD6Joint alloc] initWithJoint:
            PxD6JointCreate(*_physics, actor0.c_actor, transform(position0, rotation0),
                    actor1.c_actor, transform(position1, rotation1))];
}

@end
