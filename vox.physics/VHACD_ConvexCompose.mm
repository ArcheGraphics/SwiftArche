//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "VHACD_ConvexCompose.h"

#define ENABLE_VHACD_IMPLEMENTATION 1
#define VHACD_DISABLE_THREADING 0

#include <VHACD.h>
#include <vector>
#include <string>

namespace {
    class Logging : public VHACD::IVHACD::IUserCallback,
                    public VHACD::IVHACD::IUserLogger {
    public:
        Logging(void) {
        }

        ~Logging(void) {
            flushMessages();
        }

        // Be aware that if you are running V-HACD asynchronously (in a background thread) this callback will come from
        // a different thread. So if your print/logging code isn't thread safe, take that into account.
        virtual void Update(const double overallProgress,
                const double stageProgress,
                const char *const stage, const char *operation) final {
            char scratch[512];
            snprintf(scratch, sizeof(scratch), "[%-40s] : %0.0f%% : %0.0f%% : %s", stage, overallProgress, stageProgress, operation);

            if (strcmp(stage, mCurrentStage.c_str()) == 0) {
                for (uint32_t i = 0; i < mLastLen; i++) {
                    printf("%c", 8);
                }
            } else {
                printf("\n");
                mCurrentStage = std::string(stage);
            }
            mLastLen = (uint32_t) strlen(scratch);
            printf("%s", scratch);
        }

        // This is an optional user callback which is only called when running V-HACD asynchronously.
        // This is a callback performed to notify the user that the
        // convex decomposition background process is completed. This call back will occur from
        // a different thread so the user should take that into account.
        virtual void NotifyVHACDComplete(void) {
            Log("VHACD::Complete");
        }

        virtual void Log(const char *const msg) final {
            mLogMessages.push_back(std::string(msg));
        }

        void flushMessages(void) {
            if (!mLogMessages.empty()) {
                printf("\n");
                for (auto &i: mLogMessages) {
                    printf("%s\n", i.c_str());
                }
                mLogMessages.clear();
            }
        }

        uint32_t mLastLen{0};
        std::string mCurrentStage;
        std::vector<std::string> mLogMessages;
    };
} // namespace

@implementation VHACD_ConvexCompose {
    Logging logging;
    VHACD::IVHACD::Parameters p;
    VHACD::IVHACD *solver;
    VHACD::IVHACD::ConvexHull ch;
}

// MARK: - Initialization

- (instancetype)init {
    solver = nullptr;
    p.m_callback = &logging;
    p.m_logger = &logging;
    return self;
}

- (uint32_t)maxConvexHulls {
    return p.m_maxConvexHulls;
}

- (void)setMaxConvexHulls:(uint32_t)maxConvexHulls {
    p.m_maxConvexHulls = maxConvexHulls;
}

- (uint32_t)resolution {
    return p.m_resolution;
}

- (void)setResolution:(uint32_t)resolution {
    p.m_resolution = resolution;
}

- (double)minimumVolumePercentErrorAllowed {
    return p.m_minimumVolumePercentErrorAllowed;
}

- (void)setMinimumVolumePercentErrorAllowed:(double)minimumVolumePercentErrorAllowed {
    p.m_minimumVolumePercentErrorAllowed = minimumVolumePercentErrorAllowed;
}

- (uint32_t)maxRecursionDepth {
    return p.m_maxRecursionDepth;
}

- (void)setMaxRecursionDepth:(uint32_t)maxRecursionDepth {
    p.m_maxRecursionDepth = maxRecursionDepth;
}

- (bool)shrinkWrap {
    return p.m_shrinkWrap;
}

- (void)setShrinkWrap:(bool)shrinkWrap {
    p.m_shrinkWrap = shrinkWrap;
}

- (VHACD_FillMode)fillMode {
    switch (p.m_fillMode) {
        case VHACD::FillMode::FLOOD_FILL:
            return FLOOD_FILL;
            break;
        case VHACD::FillMode::SURFACE_ONLY:
            return SURFACE_ONLY;
            break;
        case VHACD::FillMode::RAYCAST_FILL:
            return RAYCAST_FILL;
            break;
        default:
            break;
    }
}

- (void)setFillMode:(VHACD_FillMode)fillMode {
    switch (fillMode) {
        case FLOOD_FILL:
            p.m_fillMode = VHACD::FillMode::FLOOD_FILL;
            break;
        case SURFACE_ONLY:
            p.m_fillMode = VHACD::FillMode::SURFACE_ONLY;
            break;
        case RAYCAST_FILL:
            p.m_fillMode = VHACD::FillMode::RAYCAST_FILL;
            break;
        default:
            break;
    }
}

- (uint32_t)maxNumVerticesPerCH {
    return p.m_maxNumVerticesPerCH;
}

- (void)setMaxNumVerticesPerCH:(uint32_t)maxNumVerticesPerCH {
    p.m_maxNumVerticesPerCH = maxNumVerticesPerCH;
}

- (bool)asyncACD {
    return p.m_asyncACD;
}

- (void)setAsyncACD:(bool)asyncACD {
    p.m_asyncACD = asyncACD;
}

- (uint32_t)minEdgeLength {
    return p.m_minEdgeLength;
}

- (void)setMinEdgeLength:(uint32_t)minEdgeLength {
    p.m_minEdgeLength = minEdgeLength;
}

- (bool)findBestPlane {
    return p.m_findBestPlane;
}

- (void)setFindBestPlane:(bool)findBestPlane {
    p.m_findBestPlane = findBestPlane;
}

// MARK: - Compute
- (void)computeWithPoints:(float *_Nonnull)points
              pointsCount:(uint32_t)pointsCount
                  indices:(uint32_t *_Nullable)indices
             indicesCount:(uint32_t)indicesCount {
    if (solver) {
        solver->Release();
    }
    solver = p.m_asyncACD ? VHACD::CreateVHACD_ASYNC() : VHACD::CreateVHACD();
    solver->Compute(points, pointsCount, indices, indicesCount / 3, p);
    while (!solver->IsReady()) {
        std::this_thread::sleep_for(std::chrono::nanoseconds(10000)); // s
    }
    logging.flushMessages();
}

- (uint32_t)hullCount {
    if (solver) {
        return solver->GetNConvexHulls();
    } else {
        return -1;
    }
}

- (uint32_t)pointCountAtIndex:(uint32_t)index {
    if (solver) {
        solver->GetConvexHull(index, ch);
        return static_cast<uint32_t>(ch.m_points.size());
    } else {
        return -1;
    }
}

- (uint32_t)triangleCountAtIndex:(uint32_t)index {
    if (solver) {
        solver->GetConvexHull(index, ch);
        return static_cast<uint32_t>(ch.m_triangles.size());
    } else {
        return -1;
    }
}

- (void)getHullInfoAtIndex:(uint32_t)index
                    points:(simd_float3 *_Nonnull)points
                   indices:(simd_uint3 *_Nullable)indices
                    center:(simd_float3 *_Nonnull)center {
    if (solver) {
        solver->GetConvexHull(index, ch);
        for (int i = 0; i < ch.m_points.size(); i++) {
            auto point = ch.m_points[i];
            points[i] = simd_make_float3(point.mX, point.mY, point.mZ);
        }
        for (int i = 0; i < ch.m_triangles.size(); i++) {
            auto triangle = ch.m_triangles[i];
            indices[i] = simd_make_uint3(triangle.mI0, triangle.mI1, triangle.mI2);
        }
        center[0] = simd_make_float3(ch.m_center.GetX(), ch.m_center.GetY(), ch.m_center.GetZ());
    }
}

@end
