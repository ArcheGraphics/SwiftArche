//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxRigidDynamic.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxRigidActor+Internal.h"
#include "CPXHelper.h"

@implementation CPxRigidDynamic {
}

// MARK: - Initialization

- (instancetype)initWithDynamicActor:(PxRigidDynamic *)actor {
    self = [super initWithActor:actor];
    return self;
}


//MARK: - Damping
- (void)setAngularDamping:(float)angDamp {
    static_cast<PxRigidDynamic *>(super.c_actor)->setAngularDamping(angDamp);
}

- (float)getAngularDamping {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getAngularDamping();
}

- (void)setLinearDamping:(float)linDamp {
    static_cast<PxRigidDynamic *>(super.c_actor)->setLinearDamping(linDamp);
}

- (float)getLinearDamping {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getLinearDamping();
}

//MARK: - Velocity
- (void)setAngularVelocity:(simd_float3)angVel {
    static_cast<PxRigidDynamic *>(super.c_actor)->setAngularVelocity(transform(angVel));
}

- (simd_float3)getAngularVelocity {
    PxVec3 vel = static_cast<PxRigidDynamic *>(super.c_actor)->getAngularVelocity();
    return transform(vel);
}

- (void)setLinearVelocity:(simd_float3)linVel {
    static_cast<PxRigidDynamic *>(super.c_actor)->setLinearVelocity(transform(linVel));
}

- (simd_float3)getLinearVelocity {
    PxVec3 vel = static_cast<PxRigidDynamic *>(super.c_actor)->getLinearVelocity();
    return transform(vel);
}

- (void)setMaxAngularVelocity:(float)maxAngVel {
    static_cast<PxRigidDynamic *>(super.c_actor)->setMaxAngularVelocity(maxAngVel);
}

- (float)getMaxAngularVelocity {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getMaxAngularVelocity();
}

- (void)setMaxLinearVelocity:(float)maxLinVel {
    static_cast<PxRigidDynamic *>(super.c_actor)->setMaxLinearVelocity(maxLinVel);
}

- (float)getMaxLinearVelocity {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getMaxLinearVelocity();
}

//MARK: - Mass Manipulation
- (void)setMass:(float)mass {
    auto rigidbody = static_cast<PxRigidDynamic *>(super.c_actor);
    rigidbody->setMass(mass);
    PxRigidBodyExt::setMassAndUpdateInertia(*rigidbody, mass);
}

- (float)getMass {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getMass();
}

- (void)setCMassLocalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    static_cast<PxRigidDynamic *>(super.c_actor)->setCMassLocalPose(transform(position, rotation));
}

- (void)getCMassLocalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = static_cast<PxRigidDynamic *>(super.c_actor)->getCMassLocalPose();
    *position = transform(pose.p);
    *rotation = transform(pose.q);
}

- (void)setMassSpaceInertiaTensor:(simd_float3)m {
    static_cast<PxRigidDynamic *>(super.c_actor)->setMassSpaceInertiaTensor(transform(m));
}

- (void)setMassAndUpdateInertia:(float)mass {
    PxRigidBodyExt::setMassAndUpdateInertia(*static_cast<PxRigidDynamic *>(super.c_actor), mass, nullptr, false);
}

//MARK: - Forces
- (void)addForce:(simd_float3)force {
    static_cast<PxRigidDynamic *>(super.c_actor)->addForce(transform(force));
}

- (void)addTorque:(simd_float3)torque {
    static_cast<PxRigidDynamic *>(super.c_actor)->addTorque(transform(torque));
}

- (void)setRigidBodyFlag:(enum CPxRigidBodyFlag)flag value:(bool)value {
    static_cast<PxRigidDynamic *>(super.c_actor)->setRigidBodyFlag(PxRigidBodyFlag::Enum(flag), value);
}

- (void)setMaxDepenetrationVelocity:(float)biasClamp {
    static_cast<PxRigidDynamic *>(super.c_actor)->setMaxDepenetrationVelocity(biasClamp);
}

- (float)getMaxDepenetrationVelocity {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getMaxDepenetrationVelocity();
}

//MARK: - Extension
- (void)addForceAtPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addForceAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(force),
            transform(pos), PxForceMode::Enum(mode));
}

- (void)addForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addForceAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(force),
            transform(pos), PxForceMode::Enum(mode));
}

- (void)addLocalForceAtPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addLocalForceAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(force),
            transform(pos), PxForceMode::Enum(mode));
}

- (void)addLocalForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addLocalForceAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(force),
            transform(pos), PxForceMode::Enum(mode));
}

- (simd_float3)getVelocityAtPos:(simd_float3)pos {
    PxVec3 vel = PxRigidBodyExt::getVelocityAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(pos));
    return transform(vel);
}

- (simd_float3)getLocalVelocityAtLocalPos:(simd_float3)pos {
    PxVec3 vel = PxRigidBodyExt::getLocalVelocityAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), transform(pos));
    return transform(vel);
}

//MARK: - Sleeping
- (bool)isSleeping {
    return static_cast<PxRigidDynamic *>(super.c_actor)->isSleeping();
}

- (void)setSleepThreshold:(float)threshold {
    static_cast<PxRigidDynamic *>(super.c_actor)->setSleepThreshold(threshold);
}

- (float)getSleepThreshold {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getSleepThreshold();
}

- (void)setRigidDynamicLockFlags:(uint32_t)flags {
    static_cast<PxRigidDynamic *>(super.c_actor)->setRigidDynamicLockFlags(PxRigidDynamicLockFlags(flags));
}

- (void)setWakeCounter:(float)wakeCounterValue {
    static_cast<PxRigidDynamic *>(super.c_actor)->setWakeCounter(wakeCounterValue);
}

- (float)getWakeCounter {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getWakeCounter();
}

- (void)wakeUp {
    static_cast<PxRigidDynamic *>(super.c_actor)->wakeUp();
}

- (void)putToSleep {
    static_cast<PxRigidDynamic *>(super.c_actor)->putToSleep();
}

- (void)setSolverIterationCounts:(unsigned int)minPositionIters minVelocityIters:(unsigned int)minVelocityIters {
    static_cast<PxRigidDynamic *>(super.c_actor)->setSolverIterationCounts(minPositionIters, minVelocityIters);
}

- (void)getSolverIterationCounts:(unsigned int *)minPositionIters minVelocityIters:(unsigned int *)minVelocityIters {
    static_cast<PxRigidDynamic *>(super.c_actor)->getSolverIterationCounts(*minPositionIters, *minVelocityIters);
}

//MARK: - Kinematic Actors
- (void)setKinematicTarget:(simd_float3)position rotation:(simd_quatf)rotation {
    static_cast<PxRigidDynamic *>(super.c_actor)->setKinematicTarget(transform(position, rotation));
}

- (bool)getKinematicTarget:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose;
    bool result = static_cast<PxRigidDynamic *>(super.c_actor)->getKinematicTarget(pose);
    if (result) {
        *position = transform(pose.p);
        *rotation = transform(pose.q);
    }
    return result;
}


- (void)setUseGravity:(bool)value {
    super.c_actor->setActorFlag(PxActorFlag::Enum::eDISABLE_GRAVITY, value);
}

- (void)setDensity:(float)value {
    PxRigidBodyExt::updateMassAndInertia(*static_cast<PxRigidDynamic *>(super.c_actor), value);
}

@end
