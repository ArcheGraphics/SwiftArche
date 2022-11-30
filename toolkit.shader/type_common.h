//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../vox.shader/type_common.h"

struct GridData {
    float u_far;
    float u_near;
    float u_primaryScale;
    float u_secondaryScale;
    
    float u_gridIntensity;
    float u_axisIntensity;
    float u_flipProgress;
};
