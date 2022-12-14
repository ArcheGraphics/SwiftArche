//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "../vox.shader/type_common.h"
#import <simd/simd.h>

struct SDFData {
    vector_float3 FrustumA; int   MaxTraceSteps;
    vector_float3 FrustumB; float AbsThreshold;
    vector_float3 FrustumC;
    vector_float3 FrustumD;

    vector_float3 Eye;

    vector_float3 SDFLower;
    vector_float3 SDFUpper;
    vector_float3 SDFExtent;
};
