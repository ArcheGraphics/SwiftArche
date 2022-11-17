//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxRigidDynamic.h"
#import "CPxRigidDynamic+Internal.h"
#import "CPxRigidActor+Internal.h"

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
    static_cast<PxRigidDynamic *>(super.c_actor)->setAngularVelocity(PxVec3(angVel.x, angVel.y, angVel.z));
}

- (simd_float3)getAngularVelocity {
    PxVec3 vel = static_cast<PxRigidDynamic *>(super.c_actor)->getAngularVelocity();
    return simd_make_float3(vel.x, vel.y, vel.z);
}

- (void)setLinearVelocity:(simd_float3)linVel {
    static_cast<PxRigidDynamic *>(super.c_actor)->setLinearVelocity(PxVec3(linVel.x, linVel.y, linVel.z));
}

- (simd_float3)getLinearVelocity {
    PxVec3 vel = static_cast<PxRigidDynamic *>(super.c_actor)->getLinearVelocity();
    return simd_make_float3(vel.x, vel.y, vel.z);
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
    static_cast<PxRigidDynamic *>(super.c_actor)->setMass(mass);
}

- (float)getMass {
    return static_cast<PxRigidDynamic *>(super.c_actor)->getMass();
}

- (void)setCMassLocalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    static_cast<PxRigidDynamic *>(super.c_actor)->setCMassLocalPose(
            PxTransform(PxVec3(position.x, position.y, position.z),
                    PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w)));
}

- (void)getCMassLocalPose:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose = static_cast<PxRigidDynamic *>(super.c_actor)->getCMassLocalPose();
    *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
    *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
}

- (void)setMassSpaceInertiaTensor:(simd_float3)m {
    static_cast<PxRigidDynamic *>(super.c_actor)->setMassSpaceInertiaTensor(PxVec3(m.x, m.y, m.z));
}

- (void)setMassAndUpdateInertia:(float)mass {
    PxRigidBodyExt::setMassAndUpdateInertia(*static_cast<PxRigidDynamic *>(super.c_actor), mass, nullptr, false);
}

//MARK: - Forces
- (void)addForce:(simd_float3)force {
    static_cast<PxRigidDynamic *>(super.c_actor)->addForce(PxVec3(force.x, force.y, force.z));
}

- (void)addTorque:(simd_float3)torque {
    static_cast<PxRigidDynamic *>(super.c_actor)->addTorque(PxVec3(torque.x, torque.y, torque.z));
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
    PxRigidBodyExt::addForceAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(force.x, force.y, force.z),
            PxVec3(pos.x, pos.y, pos.z), PxForceMode::Enum(mode));
}

- (void)addForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addForceAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(force.x, force.y, force.z),
            PxVec3(pos.x, pos.y, pos.z), PxForceMode::Enum(mode));
}

- (void)addLocalForceAtPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addLocalForceAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(force.x, force.y, force.z),
            PxVec3(pos.x, pos.y, pos.z), PxForceMode::Enum(mode));
}

- (void)addLocalForceAtLocalPosWith:(simd_float3)force pos:(simd_float3)pos mode:(enum CPxForceMode)mode {
    PxRigidBodyExt::addLocalForceAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(force.x, force.y, force.z),
            PxVec3(pos.x, pos.y, pos.z), PxForceMode::Enum(mode));
}

- (simd_float3)getVelocityAtPos:(simd_float3)pos {
    PxVec3 vel = PxRigidBodyExt::getVelocityAtPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(pos.x, pos.y, pos.z));
    return simd_make_float3(vel.x, vel.y, vel.z);
}

- (simd_float3)getLocalVelocityAtLocalPos:(simd_float3)pos {
    PxVec3 vel = PxRigidBodyExt::getLocalVelocityAtLocalPos(*static_cast<PxRigidDynamic *>(super.c_actor), PxVec3(pos.x, pos.y, pos.z));
    return simd_make_float3(vel.x, vel.y, vel.z);
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

- (void)setRigidDynamicLockFlag:(enum CPxRigidDynamicLockFlag)flag value:(bool)value {
    static_cast<PxRigidDynamic *>(super.c_actor)->setRigidDynamicLockFlag(PxRigidDynamicLockFlag::Enum(flag), value);
}

- (void)setRigidDynamicLockFlags:(int)flags {
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
    static_cast<PxRigidDynamic *>(super.c_actor)->setKinematicTarget(
            PxTransform(PxVec3(position.x, position.y, position.z),
                    PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w)));
}

- (bool)getKinematicTarget:(simd_float3 *)position rotation:(simd_quatf *)rotation {
    PxTransform pose;
    bool result = static_cast<PxRigidDynamic *>(super.c_actor)->getKinematicTarget(pose);
    if (result) {
        *position = simd_make_float3(pose.p.x, pose.p.y, pose.p.z);
        *rotation = simd_quaternion(pose.q.x, pose.q.y, pose.q.z, pose.q.w);
    }
    return result;
}


@end
