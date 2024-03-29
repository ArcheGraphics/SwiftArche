//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "PxPhysXConfig.h"
#include "PxFiltering.h"
#include "PxActor.h"

namespace vox {
    using namespace physx;

    /**
    \brief 64-bit mask used for collision filtering.

    The collision filtering equation for 2 objects o0 and o1 is:

    <pre> (G0 op0 K0) op2 (G1 op1 K1) == b </pre>

    with

    <ul>
    <li> G0 = PxGroupsMask for object o0. See PxSetGroupsMask </li>
    <li> G1 = PxGroupsMask for object o1. See PxSetGroupsMask </li>
    <li> K0 = filtering constant 0. See PxSetFilterConstants </li>
    <li> K1 = filtering constant 1. See PxSetFilterConstants </li>
    <li> b = filtering boolean. See PxSetFilterBool </li>
    <li> op0, op1, op2 = filtering operations. See PxSetFilterOps </li>
    </ul>

    If the filtering equation is true, collision detection is enabled.

    @see PxSetFilterOps()
    */
    class PxGroupsMask {
    public:
        PX_INLINE PxGroupsMask() : bits0(0), bits1(0), bits2(0), bits3(0) {
        }

        PX_INLINE    ~PxGroupsMask() {
        }

        PxU16 bits0, bits1, bits2, bits3;
    };

    /**
    \brief Collision filtering operations.

    @see PxGroupsMask
    */
    struct PxFilterOp {
        enum Enum {
            PX_FILTEROP_AND,
            PX_FILTEROP_OR,
            PX_FILTEROP_XOR,
            PX_FILTEROP_NAND,
            PX_FILTEROP_NOR,
            PX_FILTEROP_NXOR,
            PX_FILTEROP_SWAP_AND
        };
    };


    /**
    \brief Implementation of a simple filter shader that emulates PhysX 2.8.x filtering

    This shader provides the following logic:
    \li If one of the two filter objects is a trigger, the pair is acccepted and #PxPairFlag::eTRIGGER_DEFAULT will be used for trigger reports
    \li Else, if the filter mask logic (see further below) discards the pair it will be suppressed (#PxFilterFlag::eSUPPRESS)
    \li Else, the pair gets accepted and collision response gets enabled (#PxPairFlag::eCONTACT_DEFAULT)

    Filter mask logic:
    Given the two #PxFilterData structures fd0 and fd1 of two collision objects, the pair passes the filter if the following
    conditions are met:

        1) Collision groups of the pair are enabled
        2) Collision filtering equation is satisfied

    @see PxSimulationFilterShader
    */
    PxFilterFlags simulationFilterShader(
            PxFilterObjectAttributes attributes0,
            PxFilterData filterData0,
            PxFilterObjectAttributes attributes1,
            PxFilterData filterData1,
            PxPairFlags &pairFlags,
            const void *constantBlock,
            PxU32 constantBlockSize);

    /**
        \brief Determines if collision detection is performed between a pair of groups

        \note Collision group is an integer between 0 and 31.

        \param[in] group1 First Group
        \param[in] group2 Second Group

        \return True if the groups could collide

        @see PxSetGroupCollisionFlag
    */
    bool getGroupCollisionFlag(const PxU16 group1, const PxU16 group2);

    /**
        \brief Specifies if collision should be performed by a pair of groups

        \note Collision group is an integer between 0 and 31.

        \param[in] group1 First Group
        \param[in] group2 Second Group
        \param[in] enable True to enable collision between the groups

        @see PxGetGroupCollisionFlag
    */
    void setGroupCollisionFlag(const PxU16 group1, const PxU16 group2, const bool enable);

    /**
        \brief Retrieves the value set with PxSetGroup()

        \note Collision group is an integer between 0 and 31.

        \param[in] actor The actor

        \return The collision group this actor belongs to

        @see PxSetGroup
    */
    PxU16 getGroup(const PxActor &actor);

    /**
        \brief Sets which collision group this actor is part of

        \note Collision group is an integer between 0 and 31.

        \param[in] actor The actor
        \param[in] collisionGroup Collision group this actor belongs to

        @see PxGetGroup
    */
    void setGroup(PxActor &actor, const PxU16 collisionGroup);

    /**
    \brief Retrieves filtering operation. See comments for PxGroupsMask

    \param[out] op0 First filter operator.
    \param[out] op1 Second filter operator.
    \param[out] op2 Third filter operator.

    @see PxSetFilterOps PxSetFilterBool PxSetFilterConstants
    */
    void getFilterOps(PxFilterOp::Enum &op0, PxFilterOp::Enum &op1, PxFilterOp::Enum &op2);

    /**
    \brief Setups filtering operations. See comments for PxGroupsMask

    \param[in] op0 Filter op 0.
    \param[in] op1 Filter op 1.
    \param[in] op2 Filter op 2.

    @see PxSetFilterBool PxSetFilterConstants
    */
    void setFilterOps(const PxFilterOp::Enum &op0, const PxFilterOp::Enum &op1, const PxFilterOp::Enum &op2);

    /**
    \brief Retrieves filtering's boolean value. See comments for PxGroupsMask

    \return flag Boolean value for filter.

    @see PxSetFilterBool PxSetFilterConstants
    */
    bool getFilterBool();

    /**
    \brief Setups filtering's boolean value. See comments for PxGroupsMask

    \param[in] enable Boolean value for filter.

    @see PxSetFilterOps PxSsetFilterConstants
    */
    void setFilterBool(const bool enable);

    /**
    \brief Gets filtering constant K0 and K1. See comments for PxGroupsMask

    \param[out] c0 the filtering constants, as a mask. See #PxGroupsMask.
    \param[out] c1 the filtering constants, as a mask. See #PxGroupsMask.

    @see PxSetFilterOps PxSetFilterBool PxSetFilterConstants
    */
    void getFilterConstants(PxGroupsMask &c0, PxGroupsMask &c1);

    /**
    \brief Setups filtering's K0 and K1 value. See comments for PxGroupsMask

    \param[in] c0 The new group mask. See #PxGroupsMask.
    \param[in] c1 The new group mask. See #PxGroupsMask.

    @see PxSetFilterOps PxSetFilterBool PxGetFilterConstants
    */
    void setFilterConstants(const PxGroupsMask &c0, const PxGroupsMask &c1);

    /**
    \brief Gets 64-bit mask used for collision filtering. See comments for PxGroupsMask

    \param[in] actor The actor

    \return The group mask for the actor.

    @see PxSetGroupsMask()
    */
    PxGroupsMask getGroupsMask(const PxActor &actor);

    /**
    \brief Sets 64-bit mask used for collision filtering. See comments for PxGroupsMask

    \param[in] actor The actor
    \param[in] mask The group mask to set for the actor.

    @see PxGetGroupsMask()
    */
    void setGroupsMask(PxActor &actor, const PxGroupsMask &mask);
}
