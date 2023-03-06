//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxCapsuleControllerDesc.h"
#import "CPxCapsuleControllerDesc+Internal.h"
#import "CPxController.h"
#import "CPxController+Internal.h"
#import "CPxObstacle+Internal.h"
#import "../CPxShape+Internal.h"
#import "../CPxRigidActor+Internal.h"
#import "../CPxMaterial+Internal.h"
#include "CPXHelper.h"
#include <functional>

@implementation CPxCapsuleControllerDesc

- (enum CPxControllerShapeType)getType {
    return CPxControllerShapeType_eCAPSULE;
}

- (void)setToDefault {
    _c_desc.setToDefault();
}

- (float)radius {
    return _c_desc.radius;
}

- (void)setRadius:(float)radius {
    _c_desc.radius = radius;
}

- (float)height {
    return _c_desc.height;
}

- (void)setHeight:(float)height {
    _c_desc.height = height;
}

- (enum CPxCapsuleClimbingMode)climbingMode {
    return CPxCapsuleClimbingMode(_c_desc.climbingMode);
}

- (void)setClimbingMode:(enum CPxCapsuleClimbingMode)climbingMode {
    _c_desc.climbingMode = PxCapsuleClimbingMode::Enum(climbingMode);
}

//MARK: - ControllerDesc
- (simd_float3)position {
    return transform(_c_desc.position);
}

- (void)setPosition:(simd_float3)position {
    _c_desc.position = transformExtended(position);
}

- (simd_float3)upDirection {
    return transform(_c_desc.upDirection);
}

- (void)setUpDirection:(simd_float3)upDirection {
    _c_desc.upDirection = transform(upDirection);
}

- (float)slopeLimit {
    return _c_desc.slopeLimit;
}

- (void)setSlopeLimit:(float)slopeLimit {
    _c_desc.slopeLimit = slopeLimit;
}

- (float)invisibleWallHeight {
    return _c_desc.invisibleWallHeight;
}

- (void)setInvisibleWallHeight:(float)invisibleWallHeight {
    _c_desc.invisibleWallHeight = invisibleWallHeight;
}

- (float)maxJumpHeight {
    return _c_desc.maxJumpHeight;
}

- (void)setMaxJumpHeight:(float)maxJumpHeight {
    _c_desc.maxJumpHeight = maxJumpHeight;
}

- (float)contactOffset {
    return _c_desc.contactOffset;
}

- (void)setContactOffset:(float)contactOffset {
    _c_desc.contactOffset = contactOffset;
}

- (float)stepOffset {
    return _c_desc.stepOffset;
}

- (void)setStepOffset:(float)stepOffset {
    _c_desc.stepOffset = stepOffset;
}

- (float)density {
    return _c_desc.density;
}

- (void)setDensity:(float)density {
    _c_desc.density = density;
}

- (float)scaleCoeff {
    return _c_desc.scaleCoeff;
}

- (void)setScaleCoeff:(float)scaleCoeff {
    _c_desc.scaleCoeff = scaleCoeff;
}

- (float)volumeGrowth {
    return _c_desc.volumeGrowth;
}

- (void)setVolumeGrowth:(float)volumeGrowth {
    _c_desc.volumeGrowth = volumeGrowth;
}

- (enum CPxControllerNonWalkableMode)nonWalkableMode {
    return CPxControllerNonWalkableMode(_c_desc.nonWalkableMode);
}

- (void)setNonWalkableMode:(enum CPxControllerNonWalkableMode)nonWalkableMode {
    _c_desc.nonWalkableMode = PxControllerNonWalkableMode::Enum(nonWalkableMode);
}

- (CPxMaterial *)material {
    return [[CPxMaterial alloc] initWithMaterial:_c_desc.material];
}

- (void)setMaterial:(CPxMaterial *)material {
    _c_desc.material = material.c_material;
}

- (bool)registerDeletionListener {
    return _c_desc.registerDeletionListener;
}

- (void)setRegisterDeletionListener:(bool)registerDeletionListener {
    _c_desc.registerDeletionListener = registerDeletionListener;
}

// MARK: - ControllerBehaviorCallback
- (void)setControllerBehaviorCallback:(uint8_t (^ _Nullable)(uint32_t obj))getShapeBehaviorFlags {
    class PxControllerBehaviorCallbackWrapper : public PxControllerBehaviorCallback {
    public:
        std::function<uint8_t(uint32_t obj)> getShapeBehaviorFlags;

        PxControllerBehaviorCallbackWrapper(std::function<uint8_t(uint32_t obj)> getShapeBehaviorFlags) :
            getShapeBehaviorFlags(getShapeBehaviorFlags){
        }

        PxControllerBehaviorFlags getBehaviorFlags(const PxShape &shape, const PxActor &actor) override {
            return PxControllerBehaviorFlags(getShapeBehaviorFlags(shape.getQueryFilterData().word3));
        }

        PxControllerBehaviorFlags getBehaviorFlags(const PxController &controller) override {
            return PxControllerBehaviorFlags(0);
        }

        PxControllerBehaviorFlags getBehaviorFlags(const PxObstacle &obstacle) override {
            return PxControllerBehaviorFlags(0);
        }
    };

    _c_desc.behaviorCallback = new PxControllerBehaviorCallbackWrapper(getShapeBehaviorFlags);
}

// MARK: - UserControllerHitReport
- (void)setUserControllerHitReport:(void (^ _Nullable)(uint32_t obj, simd_float3 moveDir, float moveLength,
                                                       simd_float3 normal, simd_float3 point))onShapeHitCallback {
    class PxUserControllerHitReportWrapper : public PxUserControllerHitReport {
    public:
        using OnShapeHitCallback = std::function<void(uint32_t obj, simd_float3 moveDir, float moveLength,
                                                      simd_float3 normal, simd_float3 point)>;
        OnShapeHitCallback onShapeHitCallback;

        PxUserControllerHitReportWrapper(OnShapeHitCallback onShapeHitCallback) :
        onShapeHitCallback(onShapeHitCallback){
        }
        
        void onShapeHit(const PxControllerShapeHit& hit) override {
            onShapeHitCallback(hit.shape->getQueryFilterData().word3,
                               transform(hit.dir), hit.length, transform(hit.worldNormal), transform(hit.worldPos));
        }

        void onControllerHit(const PxControllersHit& hit) override {
        }

        void onObstacleHit(const PxControllerObstacleHit& hit) override {
        }
    };
    _c_desc.reportCallback = new PxUserControllerHitReportWrapper(onShapeHitCallback);
}

@end
