//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import Metal

enum FrustumCorner: Int {
    case FarBottomLeft = 0
    case FarTopLeft = 1
    case FarTopRight = 2
    case FarBottomRight = 3
    case nearBottomLeft = 4
    case nearTopLeft = 5
    case nearTopRight = 6
    case nearBottomRight = 7
    case unknown = 8
}

class ShadowUtils {
    private static var _shadowMapCoordMatrix: Matrix = Matrix(
            m11: 0.5, m12: 0.0, m13: 0.0, m14: 0.0,
            m21: 0.0, m22: 0.5, m23: 0.0, m24: 0.0,
            m31: 0.0, m32: 0.0, m33: 0.5, m34: 0.0,
            m41: 0.5, m42: 0.5, m43: 0.5, m44: 1.0
    )
    private static var _frustumCorners: [Vector3] = [Vector3](repeating: Vector3(), count: 8)
    private static var _adjustNearPlane: Plane = Plane(Vector3())
    private static var _adjustFarPlane: Plane = Plane(Vector3())
    private static var _backPlaneFaces: [FrustumFace] = [FrustumFace](repeating: .Near, count: 5)

    /** near, far, left, right, bottom, top  */
    private static var _frustumPlaneNeighbors: [[FrustumFace]] = [
        [FrustumFace.Left, FrustumFace.Right, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Left, FrustumFace.Right, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Left, FrustumFace.Right],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Left, FrustumFace.Right]
    ]

    /** near, far, left, right, bottom, top  */
    private static var _frustumTwoPlaneCorners: [[[FrustumCorner]]] = [
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.nearBottomLeft, FrustumCorner.nearTopLeft],
            [FrustumCorner.nearTopRight, FrustumCorner.nearBottomRight],
            [FrustumCorner.nearBottomRight, FrustumCorner.nearBottomLeft],
            [FrustumCorner.nearTopLeft, FrustumCorner.nearTopRight]
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.FarTopLeft, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarBottomRight, FrustumCorner.FarTopRight],
            [FrustumCorner.FarBottomLeft, FrustumCorner.FarBottomRight],
            [FrustumCorner.FarTopRight, FrustumCorner.FarTopLeft]
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearTopLeft, FrustumCorner.nearBottomLeft],
            [FrustumCorner.FarBottomLeft, FrustumCorner.FarTopLeft],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.nearBottomLeft, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarTopLeft, FrustumCorner.nearTopLeft]
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearBottomRight, FrustumCorner.nearTopRight],
            [FrustumCorner.FarTopRight, FrustumCorner.FarBottomRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.FarBottomRight, FrustumCorner.nearBottomRight],
            [FrustumCorner.nearTopRight, FrustumCorner.FarTopRight]
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearBottomLeft, FrustumCorner.nearBottomRight],
            [FrustumCorner.FarBottomRight, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarBottomLeft, FrustumCorner.nearBottomLeft],
            [FrustumCorner.nearBottomRight, FrustumCorner.FarBottomRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown]
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearTopRight, FrustumCorner.nearTopLeft],
            [FrustumCorner.FarTopLeft, FrustumCorner.FarTopRight],
            [FrustumCorner.nearTopLeft, FrustumCorner.FarTopLeft],
            [FrustumCorner.FarTopRight, FrustumCorner.nearTopRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown]
        ]
    ]
    //now max shadow sample tent is 5x5, atlas borderSize at least 3=ceil(2.5),and +1 pixel is for global border for no cascade mode.
    static var atlasBorderSize: Float = 4.0

    static func shadowResolution(_ value: ShadowResolution) -> UInt32 {
        switch (value) {
        case ShadowResolution.Low:
            return 512
        case ShadowResolution.Medium:
            return 1024
        case ShadowResolution.High:
            return 2048
        case ShadowResolution.VeryHigh:
            return 4096
        }
    }

    static func shadowDepthFormat(_ value: ShadowResolution) -> MTLPixelFormat {
        .depth16Unorm
    }

    static func cullingRenderBounds(_ bounds: BoundingBox, _ cullPlaneCount: Int, _ cullPlanes: [Plane]) -> Bool {
        for i in 0..<cullPlaneCount {
            let plane = cullPlanes[i]
            let normal = plane.normal
            if (normal.x * (normal.x >= 0.0 ? max.x : min.x) +
                    normal.y * (normal.y >= 0.0 ? max.y : min.y) +
                    normal.z * (normal.z >= 0.0 ? max.z : min.z) <
                    -plane.distance
               ) {
                return false
            }
        }
        return true
    }

    static func shadowCullFrustum(_ cameraInfo: CameraInfo, _ renderPipeline: DevicePipeline,
                                  _ renderer: Renderer, _ shadowSliceData: ShadowSliceData) {
        if (renderer.castShadows && ShadowUtils.cullingRenderBounds(renderer.bounds, shadowSliceData.cullPlaneCount, shadowSliceData.cullPlanes)) {
            renderer._prepareRender(cameraInfo, renderPipeline)
        }
    }

    static func getBoundSphereByFrustum(near: Float,
                                        far: Float,
                                        camera: Camera,
                                        forward: Vector3,
                                        shadowSliceData: ShadowSliceData) {
        // https://lxjk.github.io/2017/04/15/Calculate-Minimal-Bounding-Sphere-of-Frustum.html
        var centerZ: Float
        var radius: Float
        let k: Float = sqrt(1.0 + camera.aspectRatio * camera.aspectRatio) * tan(MathUtil.degreeToRadian(camera.fieldOfView) / 2.0)
        let k2 = k * k
        let farSNear = far - near
        let farANear = far + near
        if (k2 > farSNear / farANear) {
            centerZ = far
            radius = far * k
        } else {
            centerZ = 0.5 * farANear * (1 + k2)
            radius = 0.5 * sqrt(farSNear * farSNear + 2.0 * (far * far + near * near) * k2 + farANear * farANear * k2 * k2)
        }

        let center = shadowSliceData.splitBoundSphere.center
        shadowSliceData.splitBoundSphere.radius = radius
        hadowSliceData.splitBoundSphere.center = forward * centerZ + camera.entity.transform.worldPosition
        shadowSliceData.sphereCenterZ = centerZ
    }

    static func getDirectionLightShadowCullPlanes(cameraFrustum: BoundingFrustum,
                                                  splitDistance: Float,
                                                  cameraNear: Float,
                                                  direction: Vector3,
                                                  shadowSliceData: ShadowSliceData) {
        // http://lspiroengine.com/?p=187
        let frustumCorners = ShadowUtils._frustumCorners
        let backPlaneFaces = ShadowUtils._backPlaneFaces
        let planeNeighbors = ShadowUtils._frustumPlaneNeighbors
        let twoPlaneCorners = ShadowUtils._frustumTwoPlaneCorners
        let out = shadowSliceData.cullPlanes

        // cameraFrustumPlanes is share
        let near = cameraFrustum.getPlane(FrustumFace.Near)
        let far = cameraFrustum.getPlane(FrustumFace.Far)
        let left = cameraFrustum.getPlane(FrustumFace.Left)
        let right = cameraFrustum.getPlane(FrustumFace.Right)
        let bottom = cameraFrustum.getPlane(FrustumFace.Bottom)
        let top = cameraFrustum.getPlane(FrustumFace.Top)

        // adjustment the near/far plane
        let splitNearDistance = splitDistance - cameraNear
        let splitNear = ShadowUtils._adjustNearPlane
        let splitFar = ShadowUtils._adjustFarPlane
        splitNear.normal = near.normal
        splitFar.normal = far.normal
        splitNear.distance = near.distance - splitNearDistance
        // do a clamp if the sphere is out of range the far plane
        splitFar.distance = Math.min(
                -near.distance + shadowSliceData.sphereCenterZ + shadowSliceData.splitBoundSphere.radius,
                far.distance
        )

        CollisionUtil.intersectionPointThreePlanes(splitNear, bottom, right, frustumCorners[FrustumCorner.nearBottomRight])
        CollisionUtil.intersectionPointThreePlanes(splitNear, top, right, frustumCorners[FrustumCorner.nearTopRight])
        CollisionUtil.intersectionPointThreePlanes(splitNear, top, left, frustumCorners[FrustumCorner.nearTopLeft])
        CollisionUtil.intersectionPointThreePlanes(splitNear, bottom, left, frustumCorners[FrustumCorner.nearBottomLeft])
        CollisionUtil.intersectionPointThreePlanes(splitFar, bottom, right, frustumCorners[FrustumCorner.FarBottomRight])
        CollisionUtil.intersectionPointThreePlanes(splitFar, top, right, frustumCorners[FrustumCorner.FarTopRight])
        CollisionUtil.intersectionPointThreePlanes(splitFar, top, left, frustumCorners[FrustumCorner.FarTopLeft])
        CollisionUtil.intersectionPointThreePlanes(splitFar, bottom, left, frustumCorners[FrustumCorner.FarBottomLeft])

        let backIndex = 0
        for i in 0..<6 {
            // maybe 3、4、5(light eye is at far, forward is near, or orthographic camera is any axis)
            let plane: Plane
            switch (i) {
            case FrustumFace.Near:
                plane = splitNear
                break
            case FrustumFace.Far:
                plane = splitFar
                break
            default:
                plane = cameraFrustum.getPlane(i)
                break
            }
            if (Vector3.dot(plane.normal, direction) < 0.0) {
                out[backIndex] = plane
                backPlaneFaces[backIndex] = i
                backIndex++
            }
        }

        let edgeIndex = backIndex
        for i in 0..<backIndex {
            let backFace = backPlaneFaces[i]
            let neighborFaces = planeNeighbors[backFace]
            for j in 0..<4 {
                let neighborFace = neighborFaces[j]
                let notBackFace = true
                for k in 0..<backIndex {
                    if (neighborFace == backPlaneFaces[k]) {
                        notBackFace = false
                        break
                    }
                }
                if (notBackFace) {
                    let corners = twoPlaneCorners[backFace][neighborFace]
                    let point0 = frustumCorners[corners[0]]
                    let point1 = frustumCorners[corners[1]]
                    Plane.fromPoints(point0, point1, point0 + direction, out[edgeIndex++])
                }
            }
        }
        shadowSliceData.cullPlaneCount = edgeIndex
    }

}