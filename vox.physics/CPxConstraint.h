//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

enum CPxConstraintFlag {
    //!< whether the constraint is broken
    eBROKEN = 1 << 0,
    //!< whether actor1 should get projected to actor0 for this constraint (note: projection of a static/kinematic actor to a dynamic actor will be ignored)
    ePROJECT_TO_ACTOR0 = 1 << 1,
    //!< whether actor0 should get projected to actor1 for this constraint (note: projection of a static/kinematic actor to a dynamic actor will be ignored)
    ePROJECT_TO_ACTOR1 = 1 << 2,
    //!< whether the actors should get projected for this constraint (the direction will be chosen by PhysX)
    ePROJECTION = ePROJECT_TO_ACTOR0 | ePROJECT_TO_ACTOR1,
    //!< whether contacts should be generated between the objects this constraint constrains
    eCOLLISION_ENABLED = 1 << 3,
    //!< whether this constraint should be visualized, if constraint visualization is turned on
    eVISUALIZATION = 1 << 4,
    //!< limits for drive strength are forces rather than impulses
    eDRIVE_LIMITS_ARE_FORCES = 1 << 5,
    //!< perform preprocessing for improved accuracy on D6 Slerp Drive (this flag will be removed in a future release when preprocessing is no longer required)
    eIMPROVED_SLERP = 1 << 7,
    //!< suppress constraint preprocessing, intended for use with rowResponseThreshold. May result in worse solver accuracy for ill-conditioned constraints.
    eDISABLE_PREPROCESSING = 1 << 8,
    //!< enables extended limit ranges for angular limits (e.g. limit values > PxPi or < -PxPi)
    eENABLE_EXTENDED_LIMITS = 1 << 9,
    //!< the constraint type is supported by gpu dynamic
    eGPU_COMPATIBLE = 1 << 10
};

@interface CPxConstraint : NSObject

@end