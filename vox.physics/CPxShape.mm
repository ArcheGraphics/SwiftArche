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

@implementation CPxShape {
}

- (instancetype)initWithShape:(PxShape *)shape {
    self = [super init];
    if (self) {
        _c_shape = shape;
    }
    return self;
}

- (void)dealloc {
    _c_shape->release();
}

- (void)setFlags:(uint8_t)inFlags {
    _c_shape->setFlags(PxShapeFlags(inFlags));
}

- (void)setQueryFilterData:(uint32_t)w0 w1:(uint32_t)w1 w2:(uint32_t)w2 w3:(uint32_t)w3 {
    _c_shape->setQueryFilterData(PxFilterData(w0, w1, w2, w3));
}

- (void)setGeometry:(CPxGeometry *)geometry {
    _c_shape->setGeometry(*geometry.c_geometry);
}

- (void)setLocalPose:(simd_float3)position rotation:(simd_quatf)rotation {
    _c_shape->setLocalPose(PxTransform(PxVec3(position.x, position.y, position.z),
            PxQuat(rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w)));
}

- (void)setMaterial:(CPxMaterial *)material {
    std::vector<PxMaterial *> materials(1, nullptr);
    materials[0] = material.c_material;
    _c_shape->setMaterials(materials.data(), static_cast<PxU16>(materials.size()));
}

- (void)setContactOffset:(float)contactOffset {
    _c_shape->setContactOffset(contactOffset);
}

- (int)getQueryFilterData:(int)index {
    switch (index) {
        case 0:
            return _c_shape->getQueryFilterData().word0;
            break;

        case 1:
            return _c_shape->getQueryFilterData().word1;
            break;

        case 2:
            return _c_shape->getQueryFilterData().word2;
            break;

        case 3:
            return _c_shape->getQueryFilterData().word3;
            break;
    }
    return -1;
}

@end
