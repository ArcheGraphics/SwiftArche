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
            if (normal.x * (normal.x >= 0.0 ? bounds.max.x : bounds.min.x) +
                    normal.y * (normal.y >= 0.0 ? bounds.max.y : bounds.min.y) +
                    normal.z * (normal.z >= 0.0 ? bounds.max.z : bounds.min.z) <
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

        shadowSliceData.splitBoundSphere = BoundingSphere(forward * centerZ + camera.entity.transform.worldPosition, radius)
        shadowSliceData.sphereCenterZ = centerZ
    }

    static func getDirectionLightShadowCullPlanes(cameraFrustum: BoundingFrustum,
                                                  splitDistance: Float,
                                                  cameraNear: Float,
                                                  direction: Vector3,
                                                  shadowSliceData: ShadowSliceData) {
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
        for i in 0..<6 {
            // maybe 3、4、5(light eye is at far, forward is near, or orthographic camera is any axis)
            let plane: Plane
            switch (i) {
            case FrustumFace.Near.rawValue:
                plane = splitNear
                break
            case FrustumFace.Far.rawValue:
                plane = splitFar
                break
            default:
                plane = cameraFrustum.getPlane(index: i)
                break
            }
            if (Vector3.dot(left: plane.normal, right: direction) < 0.0) {
                shadowSliceData.cullPlanes[backIndex] = plane
                ShadowUtils._backPlaneFaces[backIndex] = FrustumFace(rawValue: i)!
                backIndex += 1
            }
        }

        var edgeIndex = backIndex
        for i in 0..<backIndex {
            let backFace = ShadowUtils._backPlaneFaces[i]
            let neighborFaces = ShadowUtils._frustumPlaneNeighbors[backFace.rawValue]
            for j in 0..<4 {
                let neighborFace = neighborFaces[j]
                var notBackFace = true
                for k in 0..<backIndex {
                    if (neighborFace == ShadowUtils._backPlaneFaces[k]) {
                        notBackFace = false
                        break
                    }
                }
                if (notBackFace) {
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
                                            outShadowMatrices: inout [simd_float4x4]) {
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
        let newCenter = Vector3(lightUp.x * upLen + lightSide.x * sideLen + lightForward.x * forwardLen,
                lightUp.y * upLen + lightSide.y * sideLen + lightForward.y * forwardLen,
                lightUp.z * upLen + lightSide.z * sideLen + lightForward.z * forwardLen)
        shadowSliceData.splitBoundSphere = BoundingSphere(newCenter, radius)

        // Direction light use shadow pancaking tech,do special dispose with nearPlane.
        let virtualCamera = shadowSliceData.virtualCamera
        virtualCamera.position = center - lightForward * (radius + nearPlane)
        virtualCamera.viewMatrix = Matrix.lookAt(eye: virtualCamera.position, target: center, up: lightUp)
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

    static func getMaxTileResolutionInAtlas(atlasWidth: UInt32, atlasHeight: UInt32, tileCount: Int) -> UInt32 {
        var resolution = min(atlasWidth, atlasHeight)
        var currentTileCount = atlasWidth / resolution * atlasHeight / resolution
        while (currentTileCount < tileCount) {
            resolution = resolution >> 1
            currentTileCount = atlasWidth / resolution * atlasHeight / resolution
        }
        return resolution
    }

    static func getShadowBias(light: DirectLight, projectionMatrix: Matrix, shadowResolution: UInt32) -> Vector2 {
        // Frustum size is guaranteed to be a cube as we wrap shadow frustum around a sphere
        // elements[0] = 2.0 / (right - left)
        let frustumSize: Float = 2.0 / projectionMatrix.elements.columns.0[0]

        // depth and normal bias scale is in shadowmap texel size in world space
        let texelSize: Float = frustumSize / Float(shadowResolution)
        var depthBias: Float = -light.shadowBias * texelSize
        var normalBias: Float = -light.shadowNormalBias * texelSize

        if (light.shadowType == ShadowType.SoftHigh) {
            // TODO: depth and normal bias assume sample is no more than 1 texel away from shadowmap
            // This is not true with PCF. Ideally we need to do either
            // cone base bias (based on distance to center sample)
            // or receiver place bias based on derivatives.
            // For now we scale it by the PCF kernel size (5x5)
            let kernelRadius: Float = 2.5
            depthBias *= kernelRadius
            normalBias *= kernelRadius
        }
        return Vector2(depthBias, normalBias)
    }

    /// Apply shadow slice scale and offset
    static func applySliceTransform(tileSize: UInt32,
                                    atlasWidth: Int,
                                    atlasHeight: Int,
                                    cascadeIndex: Int,
                                    atlasOffset: Vector2,
                                    outShadowMatrices: inout [simd_float4x4]) {
        var slice = simd_float4x4()

        let oneOverAtlasWidth: Float = 1.0 / Float(atlasWidth)
        let oneOverAtlasHeight: Float = 1.0 / Float(atlasHeight)
        let scaleX: Float = Float(tileSize) * oneOverAtlasWidth
        let scaleY: Float = Float(tileSize) * oneOverAtlasHeight
        let offsetX: Float = atlasOffset.x * oneOverAtlasWidth
        let offsetY: Float = atlasOffset.y * oneOverAtlasHeight

        slice.columns.0[0] = scaleX
        slice.columns.0[1] = 0
        slice.columns.0[2] = 0
        slice.columns.0[3] = 0

        slice.columns.1[0] = 0
        slice.columns.1[1] = scaleY
        slice.columns.1[2] = 0
        slice.columns.1[3] = 0

        slice.columns.2[0] = 0
        slice.columns.2[1] = 0
        slice.columns.2[2] = 1
        slice.columns.2[3] = 0

        slice.columns.3[0] = offsetX
        slice.columns.3[1] = offsetY
        slice.columns.3[2] = 0
        slice.columns.3[3] = 1

        outShadowMatrices[cascadeIndex] *= slice
    }
}