//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
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

enum ShadowUtils {
    // negative bacause of y-flip
    private static var _shadowMapCoordMatrix: Matrix = .init(
        m11: 0.5, m12: 0.0, m13: 0.0, m14: 0.0,
        m21: 0.0, m22: -0.5, m23: 0.0, m24: 0.0,
        m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
        m41: 0.5, m42: 0.5, m43: 0.0, m44: 1.0
    )
    private static var _frustumCorners: [Vector3] = .init(repeating: Vector3(), count: 8)
    private static var _backPlaneFaces: [FrustumFace] = .init(repeating: .Near, count: 5)

    /** near, far, left, right, bottom, top  */
    private static var _frustumPlaneNeighbors: [[FrustumFace]] = [
        [FrustumFace.Left, FrustumFace.Right, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Left, FrustumFace.Right, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Top, FrustumFace.Bottom],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Left, FrustumFace.Right],
        [FrustumFace.Near, FrustumFace.Far, FrustumFace.Left, FrustumFace.Right],
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
            [FrustumCorner.nearTopLeft, FrustumCorner.nearTopRight],
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.FarTopLeft, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarBottomRight, FrustumCorner.FarTopRight],
            [FrustumCorner.FarBottomLeft, FrustumCorner.FarBottomRight],
            [FrustumCorner.FarTopRight, FrustumCorner.FarTopLeft],
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearTopLeft, FrustumCorner.nearBottomLeft],
            [FrustumCorner.FarBottomLeft, FrustumCorner.FarTopLeft],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.nearBottomLeft, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarTopLeft, FrustumCorner.nearTopLeft],
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearBottomRight, FrustumCorner.nearTopRight],
            [FrustumCorner.FarTopRight, FrustumCorner.FarBottomRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.FarBottomRight, FrustumCorner.nearBottomRight],
            [FrustumCorner.nearTopRight, FrustumCorner.FarTopRight],
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearBottomLeft, FrustumCorner.nearBottomRight],
            [FrustumCorner.FarBottomRight, FrustumCorner.FarBottomLeft],
            [FrustumCorner.FarBottomLeft, FrustumCorner.nearBottomLeft],
            [FrustumCorner.nearBottomRight, FrustumCorner.FarBottomRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
        ],
        [
            // near, far, left, right, bottom, top
            [FrustumCorner.nearTopRight, FrustumCorner.nearTopLeft],
            [FrustumCorner.FarTopLeft, FrustumCorner.FarTopRight],
            [FrustumCorner.nearTopLeft, FrustumCorner.FarTopLeft],
            [FrustumCorner.FarTopRight, FrustumCorner.nearTopRight],
            [FrustumCorner.unknown, FrustumCorner.unknown],
            [FrustumCorner.unknown, FrustumCorner.unknown],
        ],
    ]
    // now max shadow sample tent is 5x5, atlas borderSize at least 3=ceil(2.5),and +1 pixel is for global border for no cascade mode.
    static var atlasBorderSize: Float = 4.0

    static func shadowResolution(_ value: ShadowResolution) -> UInt32 {
        switch value {
        case ShadowResolution.Low:
            return 128
        case ShadowResolution.Medium:
            return 256
        case ShadowResolution.High:
            return 512
        case ShadowResolution.VeryHigh:
            return 1024
        }
    }

    static func shadowDepthFormat(_: ShadowResolution) -> MTLPixelFormat {
        .depth32Float
    }

    static func cullingRenderBounds(_ bounds: BoundingBox, _ cullPlaneCount: Int, _ cullPlanes: [Plane]) -> Bool {
        for i in 0 ..< cullPlaneCount {
            let plane = cullPlanes[i]
            let normal = plane.normal
            if normal.x * (normal.x >= 0.0 ? bounds.max.x : bounds.min.x) +
                normal.y * (normal.y >= 0.0 ? bounds.max.y : bounds.min.y) +
                normal.z * (normal.z >= 0.0 ? bounds.max.z : bounds.min.z) <
                -plane.distance
            {
                return false
            }
        }
        return true
    }

    static func shadowCullFrustum(_ cameraInfo: CameraInfo, _ renderPipeline: DevicePipeline,
                                  _ camera: Camera, _ light: Light,
                                  _ renderer: Renderer, _ shadowSliceData: ShadowSliceData)
    {
        // filter by camera culling mask.
        let layer = renderer._entity.layer
        if camera.cullingMask.rawValue & layer.rawValue != 0, light.cullingMask.rawValue & layer.rawValue != 0 {
            if renderer.castShadows, ShadowUtils.cullingRenderBounds(renderer.bounds, shadowSliceData.cullPlaneCount, shadowSliceData.cullPlanes) {
                renderer._prepareRender(cameraInfo, renderPipeline)
            }
        }
    }

    static func getBoundSphereByFrustum(near: Float,
                                        far: Float,
                                        camera: Camera,
                                        forward: Vector3,
                                        shadowSliceData: ShadowSliceData)
    {
        // https://lxjk.github.io/2017/04/15/Calculate-Minimal-Bounding-Sphere-of-Frustum.html
        var centerZ: Float
        var radius: Float
        let k: Float = sqrt(1.0 + camera.aspectRatio * camera.aspectRatio) * tan(MathUtil.degreeToRadian(camera.fieldOfView) / 2.0)
        let k2 = k * k
        let farSNear = far - near
        let farANear = far + near
        if k2 > farSNear / farANear {
            centerZ = far
            radius = far * k
        } else {
            centerZ = 0.5 * farANear * (1 + k2)
            radius = 0.5 * sqrt(farSNear * farSNear + 2.0 * (far * far + near * near) * k2 + farANear * farANear * k2 * k2)
        }

        shadowSliceData.splitBoundSphere = BoundingSphere(forward * centerZ + camera.entity.transform.worldPosition, radius)
        shadowSliceData.sphereCenterZ = centerZ
    }

    static func getDirectionLightShadowCullPlanes(cameraFrustum: BoundingFrustum,
                                                  splitDistance: Float,
                                                  cameraNear: Float,
                                                  direction: Vector3,
                                                  shadowSliceData: ShadowSliceData)
    {
        // http://lspiroengine.com/?p=187
        // cameraFrustumPlanes is share
        let near = cameraFrustum.getPlane(face: FrustumFace.Near)
        let far = cameraFrustum.getPlane(face: FrustumFace.Far)
        let left = cameraFrustum.getPlane(face: FrustumFace.Left)
        let right = cameraFrustum.getPlane(face: FrustumFace.Right)
        let bottom = cameraFrustum.getPlane(face: FrustumFace.Bottom)
        let top = cameraFrustum.getPlane(face: FrustumFace.Top)

        // adjustment the near/far plane
        let splitNearDistance = splitDistance - cameraNear
        let splitNear = Plane(near.normal, near.distance - splitNearDistance)
        // do a clamp if the sphere is out of range the far plane
        let splitFar = Plane(far.normal, min(-near.distance + shadowSliceData.sphereCenterZ + shadowSliceData.splitBoundSphere.radius, far.distance))

        ShadowUtils._frustumCorners[FrustumCorner.nearBottomRight.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitNear, p2: bottom, p3: right)
        ShadowUtils._frustumCorners[FrustumCorner.nearTopRight.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitNear, p2: top, p3: right)
        ShadowUtils._frustumCorners[FrustumCorner.nearTopLeft.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitNear, p2: top, p3: left)
        ShadowUtils._frustumCorners[FrustumCorner.nearBottomLeft.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitNear, p2: bottom, p3: left)
        ShadowUtils._frustumCorners[FrustumCorner.FarBottomRight.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitFar, p2: bottom, p3: right)
        ShadowUtils._frustumCorners[FrustumCorner.FarTopRight.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitFar, p2: top, p3: right)
        ShadowUtils._frustumCorners[FrustumCorner.FarTopLeft.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitFar, p2: top, p3: left)
        ShadowUtils._frustumCorners[FrustumCorner.FarBottomLeft.rawValue] = CollisionUtil.intersectionPointThreePlanes(p1: splitFar, p2: bottom, p3: left)

        var backIndex = 0
        for i in 0 ..< 6 {
            // maybe 3、4、5(light eye is at far, forward is near, or orthographic camera is any axis)
            let plane: Plane
            switch i {
            case FrustumFace.Near.rawValue:
                plane = splitNear
            case FrustumFace.Far.rawValue:
                plane = splitFar
            default:
                plane = cameraFrustum.getPlane(index: i)
            }
            if Vector3.dot(left: plane.normal, right: direction) < 0.0 {
                shadowSliceData.cullPlanes[backIndex] = plane
                ShadowUtils._backPlaneFaces[backIndex] = FrustumFace(rawValue: i)!
                backIndex += 1
            }
        }

        var edgeIndex = backIndex
        for i in 0 ..< backIndex {
            let backFace = ShadowUtils._backPlaneFaces[i]
            let neighborFaces = ShadowUtils._frustumPlaneNeighbors[backFace.rawValue]
            for j in 0 ..< 4 {
                let neighborFace = neighborFaces[j]
                var notBackFace = true
                for k in 0 ..< backIndex {
                    if neighborFace == ShadowUtils._backPlaneFaces[k] {
                        notBackFace = false
                        break
                    }
                }
                if notBackFace {
                    let corners: [FrustumCorner] = ShadowUtils._frustumTwoPlaneCorners[backFace.rawValue][neighborFace.rawValue]
                    let point0 = ShadowUtils._frustumCorners[corners[0].rawValue]
                    let point1 = ShadowUtils._frustumCorners[corners[1].rawValue]
                    shadowSliceData.cullPlanes[edgeIndex] = Plane.fromPoints(point0: point0, point1: point1, point2: point0 + direction)
                    edgeIndex += 1
                }
            }
        }
        shadowSliceData.cullPlaneCount = edgeIndex
    }

    static func getDirectionalLightMatrices(lightUp: Vector3,
                                            lightSide: Vector3,
                                            lightForward: Vector3,
                                            cascadeIndex: Int,
                                            nearPlane: Float,
                                            shadowResolution: UInt32,
                                            shadowSliceData: ShadowSliceData,
                                            outShadowMatrices: inout [simd_float4x4])
    {
        let boundSphere = shadowSliceData.splitBoundSphere
        shadowSliceData.resolution = shadowResolution

        // To solve shadow swimming problem.
        let center = boundSphere.center
        let radius = boundSphere.radius
        let halfShadowResolution = shadowResolution / 2
        // Add border to project edge pixel PCF.
        // Improve:the clip planes not consider the border,but I think is OK,because the object can clip is not continuous.
        let borderRadius: Float = (radius * Float(halfShadowResolution)) / (Float(halfShadowResolution) - ShadowUtils.atlasBorderSize)
        let borderDiam = borderRadius * 2.0
        let sizeUnit = Float(shadowResolution) / borderDiam
        let radiusUnit = borderDiam / Float(shadowResolution)
        let upLen = ceil(Vector3.dot(left: center, right: lightUp) * sizeUnit) * radiusUnit
        let sideLen = ceil(Vector3.dot(left: center, right: lightSide) * sizeUnit) * radiusUnit
        let forwardLen = Vector3.dot(left: center, right: lightForward)
        let newCenter = Vector3(
            lightUp.x * upLen + lightSide.x * sideLen + lightForward.x * forwardLen,
            lightUp.y * upLen + lightSide.y * sideLen + lightForward.y * forwardLen,
            lightUp.z * upLen + lightSide.z * sideLen + lightForward.z * forwardLen
        )
        shadowSliceData.splitBoundSphere = BoundingSphere(newCenter, radius)

        // Direction light use shadow pancaking tech,do special dispose with nearPlane.
        let virtualCamera = shadowSliceData.virtualCamera
        virtualCamera.position = newCenter - lightForward * (radius + nearPlane)
        virtualCamera.viewMatrix = Matrix.lookAt(eye: virtualCamera.position, target: newCenter, up: lightUp)
        virtualCamera.projectionMatrix = Matrix.ortho(
            left: -borderRadius,
            right: borderRadius,
            bottom: -borderRadius,
            top: borderRadius,
            near: 0.0,
            far: radius * 2.0 + nearPlane
        )

        virtualCamera.viewProjectionMatrix = virtualCamera.projectionMatrix * virtualCamera.viewMatrix
        outShadowMatrices[cascadeIndex] = ShadowUtils._shadowMapCoordMatrix.elements * virtualCamera.viewProjectionMatrix.elements
    }
}
