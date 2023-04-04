//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import Math

/// Wireframe primitive.
class WireframePrimitive {
    /** global settings for vertex count */
    static let circleVertexCount: UInt32 = 40

    /// Get cuboid wire frame index count.
    static var cuboidIndexCount: UInt32 {
        48
    }

    /// Get sphere wire frame index count.
    static var sphereIndexCount: UInt32 {
        WireframePrimitive.circleIndexCount * 3
    }

    /// Get cone wire frame index count.
    static var coneIndexCount: UInt32 {
        WireframePrimitive.circleIndexCount + 8
    }

    /// Get unbound cylinder wire frame index count.
    static var unboundCylinderIndexCount: UInt32 {
        WireframePrimitive.circleIndexCount + 16
    }

    /// Get capsule wire frame index count.
    static var capsuleIndexCount: UInt32 {
        (WireframePrimitive.circleIndexCount + WireframePrimitive.ellipticIndexCount) * 2
    }

    /// Get circle wire frame index count.
    static var circleIndexCount: UInt32 {
        WireframePrimitive.circleVertexCount * 2
    }

    /// Get elliptic wire frame index count.
    static var ellipticIndexCount: UInt32 {
        WireframePrimitive.circleVertexCount * 2
    }

    /// Store cuboid wireframe mesh data.
    /// The origin located in center of cuboid.
    /// - Parameters:
    ///   - width: Cuboid width
    ///   - height: Cuboid height
    ///   - depth: Cuboid depth
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createCuboidWireframe(_ width: Float,
                                      _ height: Float,
                                      _ depth: Float,
                                      _ positions: inout [Vector3],
                                      _ positionOffset: UInt32,
                                      _ indices: inout [UInt32],
                                      _ indicesOffset: Int)
    {
        let halfWidth: Float = width / 2
        let halfHeight: Float = height / 2
        let halfDepth: Float = depth / 2

        // Up
        positions.append(Vector3(-halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, halfHeight, halfDepth))
        positions.append(Vector3(-halfWidth, halfHeight, halfDepth))

        // Down
        positions.append(Vector3(-halfWidth, -halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, halfDepth))
        positions.append(Vector3(-halfWidth, -halfHeight, halfDepth))

        // Left
        positions.append(Vector3(-halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(-halfWidth, halfHeight, halfDepth))
        positions.append(Vector3(-halfWidth, -halfHeight, halfDepth))
        positions.append(Vector3(-halfWidth, -halfHeight, -halfDepth))

        // Right
        positions.append(Vector3(halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, halfHeight, halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, -halfDepth))

        // Front
        positions.append(Vector3(-halfWidth, halfHeight, halfDepth))
        positions.append(Vector3(halfWidth, halfHeight, halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, halfDepth))
        positions.append(Vector3(-halfWidth, -halfHeight, halfDepth))

        // Back
        positions.append(Vector3(-halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, halfHeight, -halfDepth))
        positions.append(Vector3(halfWidth, -halfHeight, -halfDepth))
        positions.append(Vector3(-halfWidth, -halfHeight, -halfDepth))

        var indicesOffset = indicesOffset
        // Up
        indices[indicesOffset] = positionOffset
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 1
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 1
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 2
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 2
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 3
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 3
        indicesOffset += 1
        indices[indicesOffset] = positionOffset
        indicesOffset += 1

        // Down
        indices[indicesOffset] = positionOffset + 4
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 5
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 5
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 6
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 6
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 7
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 7
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 4
        indicesOffset += 1

        // Left
        indices[indicesOffset] = positionOffset + 8
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 9
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 9
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 10
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 10
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 11
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 11
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 8
        indicesOffset += 1

        // Right
        indices[indicesOffset] = positionOffset + 12
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 13
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 13
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 14
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 14
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 15
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 15
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 12
        indicesOffset += 1

        // Front
        indices[indicesOffset] = positionOffset + 16
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 17
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 17
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 18
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 18
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 19
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 19
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 16
        indicesOffset += 1

        // Back
        indices[indicesOffset] = positionOffset + 20
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 21
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 21
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 22
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 22
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 23
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 23
        indicesOffset += 1
        indices[indicesOffset] = positionOffset + 20
        indicesOffset += 1
    }

    /// Store sphere wireframe mesh data.
    /// The origin located in center of sphere.
    /// - Parameters:
    ///   - radius: Sphere radius
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createSphereWireframe(_ radius: Float,
                                      _ positions: inout [Vector3],
                                      _ positionOffset: UInt32,
                                      _ indices: inout [UInt32],
                                      _ indicesOffset: Int)
    {
        let shift = Vector3()

        // X
        WireframePrimitive.createCircleWireframe(radius, 0, shift, &positions, positionOffset, &indices, indicesOffset)

        // Y
        WireframePrimitive.createCircleWireframe(radius, 1, shift, &positions,
                                                 positionOffset + WireframePrimitive.circleVertexCount,
                                                 &indices,
                                                 indicesOffset + Int(WireframePrimitive.circleIndexCount))

        // Z
        WireframePrimitive.createCircleWireframe(radius, 2, shift, &positions,
                                                 positionOffset + WireframePrimitive.circleVertexCount * 2,
                                                 &indices,
                                                 indicesOffset + Int(WireframePrimitive.circleIndexCount * 2))
    }

    /// Store cone wireframe mesh data.
    /// The origin located in top of cone.
    /// - Parameters:
    ///   - radius: The radius of cap
    ///   - height: The height of cone
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createConeWireframe(_ radius: Float, _ height: Float, _ positions: inout [Vector3], _ positionOffset: UInt32,
                                    _ indices: inout [UInt32], _ indicesOffset: Int)
    {
        let shift = Vector3(0, -height, 0)

        // Y
        WireframePrimitive.createCircleWireframe(radius, 1, shift, &positions, positionOffset, &indices, indicesOffset)

        positions.append(Vector3())
        positions.append(Vector3(-radius, -height, 0))
        positions.append(Vector3(radius, -height, 0))
        positions.append(Vector3(0, -height, radius))
        positions.append(Vector3(0, -height, -radius))
        let indexBegin = positionOffset + WireframePrimitive.circleVertexCount
        var indicesOffset = indicesOffset
        indicesOffset += Int(WireframePrimitive.circleIndexCount)
        indices[indicesOffset] = indexBegin
        indicesOffset += 1
        indices[indicesOffset] = indexBegin + 1
        indicesOffset += 1
        indices[indicesOffset] = indexBegin
        indicesOffset += 1
        indices[indicesOffset] = indexBegin + 2
        indicesOffset += 1
        indices[indicesOffset] = indexBegin
        indicesOffset += 1
        indices[indicesOffset] = indexBegin + 3
        indicesOffset += 1
        indices[indicesOffset] = indexBegin
        indicesOffset += 1
        indices[indicesOffset] = indexBegin + 4
        indicesOffset += 1
    }

    /// Store unbound cylinder wireframe mesh data.
    /// The origin located in center of sphere.
    /// - Parameters:
    ///   - radius: The radius
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createUnboundCylinderWireframe(_ radius: Float, _ positions: inout [Vector3], _ positionOffset: UInt32,
                                               _ indices: inout [UInt32], _ indicesOffset: Int)
    {
        let height: Float = 5
        let shift = Vector3()

        // Y
        WireframePrimitive.createCircleWireframe(radius, 1, shift, &positions, positionOffset, &indices, indicesOffset)

        let indexBegin = positionOffset + WireframePrimitive.circleVertexCount
        var indicesOffset = indicesOffset
        indicesOffset += Int(WireframePrimitive.circleIndexCount)
        for i in 0 ..< 8 {
            let radian: Float = MathUtil.degreeToRadian(Float(45 * i))
            positions.append(Vector3(radius * cos(radian), 0, radius * sin(radian)))
            positions.append(Vector3(radius * cos(radian), -height, radius * sin(radian)))

            indices[indicesOffset + i * 2] = indexBegin + UInt32(2 * i)
            indices[indicesOffset + i * 2 + 1] = indexBegin + UInt32(2 * i + 1)
        }
    }

    /// Store capsule wireframe mesh data.
    /// The origin located in center of capsule.
    /// - Parameters:
    ///   - radius: The radius of the two hemispherical ends
    ///   - height: The height of the cylindrical part, measured between the centers of the hemispherical ends
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createCapsuleWireframe(_ radius: Float, _ height: Float, _ positions: inout [Vector3],
                                       _ positionOffset: UInt32, _ indices: inout [UInt32], _ indicesOffset: Int)
    {
        let circleIndicesCount = WireframePrimitive.circleIndexCount
        let vertexCount = WireframePrimitive.circleVertexCount
        let halfHeight = height / 2

        // Y-Top
        var shift = Vector3(0, halfHeight, 0)
        WireframePrimitive.createCircleWireframe(radius, 1, shift, &positions, positionOffset, &indices, indicesOffset)

        // Y-Bottom
        shift = Vector3(0, -halfHeight, 0)
        WireframePrimitive.createCircleWireframe(
            radius,
            1,
            shift,
            &positions,
            positionOffset + vertexCount,
            &indices,
            indicesOffset + Int(circleIndicesCount)
        )

        // X-Elliptic
        WireframePrimitive.createEllipticWireframe(
            radius,
            halfHeight,
            2,
            &positions,
            positionOffset + vertexCount * 2,
            &indices,
            indicesOffset + Int(circleIndicesCount) * 2
        )

        // Z-Elliptic
        WireframePrimitive.createEllipticWireframe(
            radius,
            halfHeight,
            0,
            &positions,
            positionOffset + vertexCount * 3,
            &indices,
            indicesOffset + Int(circleIndicesCount) * 2 + Int(WireframePrimitive.ellipticIndexCount)
        )
    }

    /// Store circle wireframe mesh data.
    /// - Parameters:
    ///   - radius: The radius
    ///   - axis: The default direction
    ///   - shift: The default shift
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createCircleWireframe(_ radius: Float, _ axis: Int, _ shift: Vector3,
                                      _ positions: inout [Vector3], _ positionOffset: UInt32, _ indices: inout [UInt32], _ indicesOffset: Int)
    {
        let vertexCount = WireframePrimitive.circleVertexCount

        let twoPi = Float.pi * 2
        let countReciprocal = 1.0 / Float(vertexCount)
        for i: Int in 0 ..< Int(vertexCount) {
            let v = Float(i) * countReciprocal
            let thetaDelta = v * twoPi

            switch axis {
            case 0:
                positions.append(Vector3(shift.x, radius * cos(thetaDelta) + shift.y, radius * sin(thetaDelta) + shift.z))
            case 1:
                positions.append(Vector3(radius * cos(thetaDelta) + shift.x, shift.y, radius * sin(thetaDelta) + shift.z))
            case 2:
                positions.append(Vector3(radius * cos(thetaDelta) + shift.x, radius * sin(thetaDelta) + shift.y, shift.z))
            default:
                break
            }

            let globalIndex = UInt32(i) + positionOffset
            if i < vertexCount - 1 {
                indices[indicesOffset + 2 * i] = globalIndex
                indices[indicesOffset + 2 * i + 1] = globalIndex + 1
            } else {
                indices[indicesOffset + 2 * i] = globalIndex
                indices[indicesOffset + 2 * i + 1] = positionOffset
            }
        }
    }

    /// Store elliptic wireframe mesh data.
    /// - Parameters:
    ///   - radius: The radius of the two hemispherical ends
    ///   - height: The height of the cylindrical part, measured between the centers of the hemispherical ends
    ///   - axis: The default direction
    ///   - positions: position array
    ///   - positionOffset: The min of index list
    ///   - indices: index array
    ///   - indicesOffset: index array offset
    static func createEllipticWireframe(_ radius: Float, _ height: Float, _ axis: Int,
                                        _ positions: inout [Vector3], _ positionOffset: UInt32, _ indices: inout [UInt32], _ indicesOffset: Int)
    {
        let vertexCount = WireframePrimitive.circleVertexCount
        let twoPi = Float.pi * 2
        let countReciprocal: Float = 1.0 / Float(vertexCount)
        var height = height
        for i: Int in 0 ..< Int(vertexCount) {
            let v = Float(i) * countReciprocal
            let thetaDelta = v * twoPi

            switch axis {
            case 0:
                positions.append(Vector3(0, radius * sin(thetaDelta) + height, radius * cos(thetaDelta)))
            case 1:
                positions.append(Vector3(radius * cos(thetaDelta), height, radius * sin(thetaDelta)))
            case 2:
                positions.append(Vector3(radius * cos(thetaDelta), radius * sin(thetaDelta) + height, 0))
            default:
                break
            }

            if i == vertexCount / 2 {
                height = -height
            }

            let globalIndex = UInt32(i) + positionOffset
            if i < vertexCount - 1 {
                indices[indicesOffset + 2 * i] = globalIndex
                indices[indicesOffset + 2 * i + 1] = globalIndex + 1
            } else {
                indices[indicesOffset + 2 * i] = globalIndex
                indices[indicesOffset + 2 * i + 1] = positionOffset
            }
        }
    }
}
