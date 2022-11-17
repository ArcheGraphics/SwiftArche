//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

enum CPxControllerShapeType {
    /// A box controller.
    CPxControllerShapeType_eBOX,

    /// A capsule controller
    CPxControllerShapeType_eCAPSULE,

    CPxControllerShapeType_eFORCE_DWORD = 0x7fffffff
};

enum CPxControllerNonWalkableMode {
    //!< Stops character from climbing up non-walkable slopes, but doesn't move it otherwise
    ePREVENT_CLIMBING,
    //!< Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes
    ePREVENT_CLIMBING_AND_FORCE_SLIDING
};

@interface CPxControllerDesc : NSObject

- (enum CPxControllerShapeType)getType;

@end