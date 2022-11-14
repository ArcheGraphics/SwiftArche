//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;

float4x4 getJointMatrix(sampler smp, texture2d<float> joint_tex,
                        float index, int u_jointCount);

