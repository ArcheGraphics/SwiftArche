//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "MTLFontAtlasProvider.h"
#include <math.h>
#include <stdbool.h>

float* createSignedDistanceFieldForGrayscaleImage(const uint8_t *imageData, size_t width, size_t height) {
    if (imageData == NULL || width == 0 || height == 0)
        return NULL;

    typedef struct { unsigned short x, y; } intpoint_t;

    float* distanceMap = malloc(width * height * sizeof(float)); // distance to nearest boundary point map
    intpoint_t *boundaryPointMap = malloc(width * height * sizeof(intpoint_t)); // nearest boundary point map

    // Some helpers for manipulating the above arrays
#define image(_x, _y) (imageData[(_y) * width + (_x)] > 0x7f)
#define distance(_x, _y) distanceMap[(_y) * width + (_x)]
#define nearestpt(_x, _y) boundaryPointMap[(_y) * width + (_x)]

    const float maxDist = hypot(width, height);
    const float distUnit = 1;
    const float distDiag = sqrt(2);

    // Initialization phase: set all distances to "infinity"; zero out nearest boundary point map
    for (long y = 0; y < height; ++y)
    {
        for (long x = 0; x < width; ++x)
        {
            distance(x, y) = maxDist;
            nearestpt(x, y) = (intpoint_t){ 0, 0 };
        }
    }

    // Immediate interior/exterior phase: mark all points along the boundary as such
    for (long y = 1; y < height - 1; ++y)
    {
        for (long x = 1; x < width - 1; ++x)
        {
            bool inside = image(x, y);
            if (image(x - 1, y) != inside ||
                image(x + 1, y) != inside ||
                image(x, y - 1) != inside ||
                image(x, y + 1) != inside)
            {
                distance(x, y) = 0;
                nearestpt(x, y) = (intpoint_t){ x, y };
            }
        }
    }

    // Forward dead-reckoning pass
    for (long y = 1; y < height - 2; ++y)
    {
        for (long x = 1; x < width - 2; ++x)
        {
            if (distanceMap[(y - 1) * width + (x - 1)] + distDiag < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x - 1, y - 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x, y - 1) + distUnit < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x, y - 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x + 1, y - 1) + distDiag < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x + 1, y - 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x - 1, y) + distUnit < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x - 1, y);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
        }
    }

    // Backward dead-reckoning pass
    for (long y = height - 2; y >= 1; --y)
    {
        for (long x = width - 2; x >= 1; --x)
        {
            if (distance(x + 1, y) + distUnit < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x + 1, y);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x - 1, y + 1) + distDiag < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x - 1, y + 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x, y + 1) + distUnit < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x, y + 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
            if (distance(x + 1, y + 1) + distDiag < distance(x, y))
            {
                nearestpt(x, y) = nearestpt(x + 1, y + 1);
                distance(x, y) = hypot(x - nearestpt(x, y).x, y - nearestpt(x, y).y);
            }
        }
    }

    // Interior distance negation pass; distances outside the figure are considered negative
    for (long y = 0; y < height; ++y)
    {
        for (long x = 0; x < width; ++x)
        {
            if (!image(x, y))
                distance(x, y) = -distance(x, y);
        }
    }

    free(boundaryPointMap);
    return distanceMap;

#undef image
#undef distance
#undef nearestpt
}
