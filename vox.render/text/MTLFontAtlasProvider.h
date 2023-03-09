//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <stdlib.h>

/// Compute signed-distance field for an 8-bpp grayscale image (values greater than 127 are considered "on")
/// For details of this algorithm, see "The 'dead reckoning' signed distance transform" [Grevera 2004]
float* createSignedDistanceFieldForGrayscaleImage(const uint8_t *imageData, size_t width, size_t height);
