//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

@protocol MTLTexture;
@protocol MTLDevice;

@class NSString;
@class NSError;

/// As a source of HDR input, renderer leverages radiance (.hdr) files. This helper method provides a radiance file
/// loaded into an MTLTexture given a source file name and MTLDevice
id<MTLTexture> texture_from_radiance_file(NSString * fileName, id<MTLDevice> device, NSError ** error);

#ifdef __cplusplus
}
#endif
