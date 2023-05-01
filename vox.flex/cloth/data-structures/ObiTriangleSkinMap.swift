//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiTriangleSkinMap {
    private class MasterFace {
        public var p1: Vector3!
        public var p2: Vector3!
        public var p3: Vector3!

        public var n1: Vector3!
        public var n2: Vector3!
        public var n3: Vector3!

        private var v0: Vector3!
        private var v1: Vector3!
        private var dot00: Float!
        private var dot01: Float!
        private var dot11: Float!

        public var faceNormal: Vector3!
        public var size: Float!

        public var index: Int!
        public var master: UInt!

        public func CacheBarycentricData() {}

        public func BarycentricCoords(point _: Vector3, coords _: inout Vector3) -> Bool {
            false
        }
    }

    public struct SkinTransform {
        public var position: Vector3
        public var rotation: Quaternion
        public var scale: Vector3

        public init(position: Vector3, rotation: Quaternion, scale: Vector3) {
            self.position = position
            self.rotation = rotation
            self.scale = scale
        }

        public init(transform: Transform) {
            position = transform.worldPosition
            rotation = transform.worldRotationQuaternion
            scale = transform.lossyWorldScale
        }

        public func Apply(transform _: Transform) {}

        public func GetMatrix4X4() -> Matrix {
            return Matrix()
        }

        public func Reset() {}
    }

    public struct BarycentricPoint {
        public var barycentricCoords: Vector3
        public var height: Float

        public static var zero: BarycentricPoint {
            return BarycentricPoint(position: Vector3.zero, height: 0)
        }

        public init(position: Vector3, height: Float) {
            barycentricCoords = position
            self.height = height
        }
    }

    public class SlaveVertex {
        public var slaveIndex: Int
        public var masterTriangleIndex: Int
        public var position: BarycentricPoint
        public var normal: BarycentricPoint
        public var tangent: BarycentricPoint

        public static var empty: SlaveVertex {
            return SlaveVertex(slaveIndex: -1, masterTriangleIndex: -1, position: BarycentricPoint.zero,
                               normal: BarycentricPoint.zero, tangent: BarycentricPoint.zero)
        }

        public var isEmpty: Bool { return slaveIndex < 0 || masterTriangleIndex < 0 }

        public init(slaveIndex: Int, masterTriangleIndex: Int,
                    position: BarycentricPoint, normal: BarycentricPoint, tangent: BarycentricPoint)
        {
            self.slaveIndex = slaveIndex
            self.masterTriangleIndex = masterTriangleIndex
            self.position = position
            self.normal = normal
            self.tangent = tangent
        }
    }

    public var bound = false

    public var barycentricWeight: Float = 1

    public var normalAlignmentWeight: Float = 1

    public var elevationWeight: Float = 1

    // channels:
    public var m_MasterChannels: [UInt] = []
    public var m_SlaveChannels: [UInt] = []

    // slave transform:
    public var m_SlaveTransform: SkinTransform = .init(position: Vector3.zero, rotation: Quaternion(), scale: Vector3.one)

    // master blueprint and slave mesh:
    public var m_Master: ObiClothBlueprintBase?
    public var m_Slave: ModelMesh?

    // skinmap data (list of slave mesh vertices)
    public var skinnedVertices: [SlaveVertex] = []

    public func Clear() {}

    public func ValidateMasterChannels(clearChannels _: Bool) {}

    public func ValidateSlaveChannels(clearChannels _: Bool) {}

    public func CopyChannel(channels _: [UInt], source _: Int, dest _: Int) {}

    public func FillChannel(channels _: [UInt], channel _: Int) {}

    public func ClearChannel(channels _: [UInt], channel _: Int) {}

    private func BindToFace(slaveIndex _: Int,
                            triangle _: MasterFace,
                            position _: Vector3,
                            normalPoint _: Vector3,
                            tangentPoint _: Vector3,
                            skinning _: inout SlaveVertex) -> Bool
    {
        false
    }

    private func GetBarycentricError(bary _: Vector3) -> Float {
        0
    }

    private func GetFaceMappingError(triangle _: MasterFace,
                                     vertex _: SlaveVertex,
                                     normal _: Vector3) -> Float
    {
        0
    }

    /// We need to find the barycentric coordinates of point such that the interpolated normal at that point passes trough our target position.
    ///
    ///            X
    ///  \        /  /
    ///   \------/--/
    ///
    /// This is necessary to ensure curvature changes in the surface affect skinned points away from the face plane.
    /// To do so, we use an iterative method similar to Newton´s method for root finding:
    ///
    /// - Project the point on the triangle using an initial normal.
    /// - Get interpolated normal at projection.
    /// - Intersect line from point and interpolated normal with triangle, to find a new projection.
    /// - Repeat.
    private func FindSkinBarycentricCoords(triangle _: MasterFace,
                                           position _: Vector3,
                                           max_iterations _: Int,
                                           min_convergence _: Float,
                                           barycentricPoint _: inout BarycentricPoint) -> Bool
    {
        false
    }

    public func Bind() {}
}
