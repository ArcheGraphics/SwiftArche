//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxObstacle.h"
#import "CPxObstacle+Internal.h"
#include "CPXHelper.h"

@implementation CPxObstacle

- (CPxGeometryType)getType {
    return CPxGeometryType::eINVALID;
}

@end

@implementation CPxBoxObstacle

- (instancetype)initWithObstacle:(PxBoxObstacle)obstacle {
    self = [super init];
    if (self) {
        _c_obstacle = obstacle;
    }
    return self;
}

- (CPxGeometryType)getType {
    return CPxGeometryType::eBOX;
}

- (simd_float3)mPos {
    return transform(_c_obstacle.mPos);
}

- (void)setMPos:(simd_float3)mPos {
    _c_obstacle.mPos = transformExtended(mPos);
}

- (simd_quatf)mRot {
    return transform(_c_obstacle.mRot);
}

- (void)setMRot:(simd_quatf)mRot {
    _c_obstacle.mRot = transform(mRot);
}

- (simd_float3)mHalfExtents {
    return transform(_c_obstacle.mHalfExtents);
}

- (void)setMHalfExtents:(simd_float3)mHalfExtents {
    _c_obstacle.mHalfExtents = transform(mHalfExtents);
}

@end

@implementation CPxCapsuleObstacle

- (instancetype)initWithObstacle:(PxCapsuleObstacle)obstacle {
    self = [super init];
    if (self) {
        _c_obstacle = obstacle;
    }
    return self;
}

- (CPxGeometryType)getType {
    return CPxGeometryType::eCAPSULE;
}

- (simd_float3)mPos {
    return transform(_c_obstacle.mPos);
}

- (void)setMPos:(simd_float3)mPos {
    _c_obstacle.mPos = transformExtended(mPos);
}

- (simd_quatf)mRot {
    return transform(_c_obstacle.mRot);
}

- (void)setMRot:(simd_quatf)mRot {
    _c_obstacle.mRot = transform(mRot);
}

- (float)mRadius {
    return _c_obstacle.mRadius;
}

- (void)setMRadius:(float)mRadius {
    _c_obstacle.mRadius = mRadius;
}

- (float)mHalfHeight {
    return _c_obstacle.mHalfHeight;
}

- (void)setMHalfHeight:(float)mHalfHeight {
    _c_obstacle.mHalfHeight = mHalfHeight;
}

@end

@implementation CPxObstacleContext

- (instancetype)initWithContext:(PxObstacleContext *)context {
    self = [super init];
    if (self) {
        _c_context = context;
    }
    return self;
}

- (uint32_t)addObstacle:(CPxObstacle *)obstacle {
    if ([obstacle getType] == CPxGeometryType::eBOX) {
        return _c_context->addObstacle(static_cast<CPxBoxObstacle *>(obstacle).c_obstacle);
    } else if ([obstacle getType] == CPxGeometryType::eCAPSULE) {
        return _c_context->addObstacle(static_cast<CPxCapsuleObstacle *>(obstacle).c_obstacle);
    } else {
        assert(false);
    }
    return 0;
}

- (bool)removeObstacle:(uint32_t)handle {
    return _c_context->removeObstacle(handle);
}

- (bool)updateObstacle:(uint32_t)handle :(CPxObstacle *)obstacle {
    if ([obstacle getType] == CPxGeometryType::eBOX) {
        return _c_context->updateObstacle(handle, static_cast<CPxBoxObstacle *>(obstacle).c_obstacle);
    } else if ([obstacle getType] == CPxGeometryType::eCAPSULE) {
        return _c_context->updateObstacle(handle, static_cast<CPxCapsuleObstacle *>(obstacle).c_obstacle);
    } else {
        assert(false);
    }
    return false;
}

- (uint32_t)getNbObstacles {
    return _c_context->getNbObstacles();
}

- (CPxObstacle *)getObstacle:(uint32_t)i {
    const PxObstacle *obstacle = _c_context->getObstacle(i);
    if (obstacle->getType() == PxGeometryType::Enum(CPxGeometryType::eBOX)) {
        CPxBoxObstacle *result = [[CPxBoxObstacle alloc] init];
        result.c_obstacle = *static_cast<const PxBoxObstacle *>(obstacle);
        return result;
    } else if (obstacle->getType() == PxGeometryType::Enum(CPxGeometryType::eCAPSULE)) {
        CPxCapsuleObstacle *result = [[CPxCapsuleObstacle alloc] init];
        result.c_obstacle = *static_cast<const PxCapsuleObstacle *>(obstacle);
        return result;
    } else {
        assert(false);
    }
    return nullptr;
}

- (CPxObstacle *)getObstacleByHandle:(uint32_t)handle {
    const PxObstacle *obstacle = _c_context->getObstacleByHandle(handle);
    if (obstacle->getType() == PxGeometryType::Enum(CPxGeometryType::eBOX)) {
        CPxBoxObstacle *result = [[CPxBoxObstacle alloc] init];
        result.c_obstacle = *static_cast<const PxBoxObstacle *>(obstacle);
        return result;
    } else if (obstacle->getType() == PxGeometryType::Enum(CPxGeometryType::eCAPSULE)) {
        CPxCapsuleObstacle *result = [[CPxCapsuleObstacle alloc] init];
        result.c_obstacle = *static_cast<const PxCapsuleObstacle *>(obstacle);
        return result;
    } else {
        assert(false);
    }
    return nullptr;
}

@end
