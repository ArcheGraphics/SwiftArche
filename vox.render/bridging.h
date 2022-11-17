//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "../vox.shader/macro_name.h"
#include "../vox.shader/type_common.h"

#include "../vox.physics/CPxPhysics.h"
#include "../vox.physics/CPxMaterial.h"
#include "../vox.physics/CPxRigidActor.h"
#include "../vox.physics/CPxRigidStatic.h"
#include "../vox.physics/CPxRigidDynamic.h"
#include "../vox.physics/CPxScene.h"
#include "../vox.physics/shape/CPxBoxGeometry.h"
#include "../vox.physics/shape/CPxSphereGeometry.h"
#include "../vox.physics/shape/CPxCapsuleGeometry.h"
#include "../vox.physics/shape/CPxPlaneGeometry.h"
#include "../vox.physics/joint/CJointBridge.h"
#include "../vox.physics/characterkinematic/CCharacterBridge.h"
