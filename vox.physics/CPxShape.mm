//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CPxShape.h"
#import "CPxShape+Internal.h"
#import "CPxGeometry+Internal.h"
#import "CPxMaterial+Internal.h"
#include <vector>
#include "CPXHelper.h"

@implementation CPxShape {
    uint32_t index;
}

- (instancetype)initWithShape:(PxShape *)shape {
    self = [super init];
    if (self) {
        _c_shape = shape;
        _c_shape->userData = &index;
    }
    return self;
}

- (void)dealloc {
    _c_shape->release();
}

- (void)setFlags:(uint8_t)inFlags {
    _c_shape->setFlags(PxShapeFlags(inFlags));
}

- (void)setGeometry:(CPxGeometry *)geometry {
    _c_shape->setGeometry(*geometry.c_geometry);
}

- (void)setLocalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    _c_shape->setLocalPose(transform(position, rotation));
}

- (void)setMaterial:(CPxMaterial *)material {
    std::vector<PxMaterial *> materials(1, nullptr);
    materials[0] = material.c_material;
    _c_shape->setMaterials(materials.data(), static_cast<PxU16>(materials.size()));
}

- (void)setContactOffset:(float)contactOffset {
    _c_shape->setContactOffset(contactOffset);
}

- (void)setUUID:(uint32_t)uuid {
    index = uuid;
}

- (uint32_t)getUUID {
    return index;
}

- (PxGeometryHolder)getGeometry {
    return _c_shape->getGeometry();
}

- (PxTransform)getLocalPose {
    return _c_shape->getLocalPose();
}

@end
