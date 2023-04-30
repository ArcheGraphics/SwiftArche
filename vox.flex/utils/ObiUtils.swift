//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class Constants {
    public let maxVertsPerMesh = 65000
    public let maxInstancesPerBatch = 1023
}

public enum ObiUtils {
    public static let epsilon: Float = 0.0000001
    public static let sqrt3: Float = 1.73205080
    public static let sqrt2: Float = 1.41421356

    public static let FilterMaskBitmask = 0xFFFF_0000
    public static let FilterCategoryBitmask = 0x0000_FFFF
    public static let ParticleGroupBitmask = 0x00FF_FFFF

    public static let CollideWithEverything = 0x0000_FFFF
    public static let CollideWithNothing = 0x0

    public static let MaxCategory = 15
    public static let MinCategory = 0

    public struct ParticleFlags: OptionSet {
        public let rawValue: UInt32

        /// this initializer is required, but it's also automatically
        /// synthesized if `rawValue` is the only member, so writing it
        /// here is optional:
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let SelfCollide = ParticleFlags(rawValue: 1 << 24)
        public static let Fluid = ParticleFlags(rawValue: 1 << 25)
        public static let OneSided = ParticleFlags(rawValue: 1 << 26)
    }

    // Colour alphabet from https://www.aic-color.org/resources/Documents/jaic_v5_06.pdf
    public static let colorAlphabet: [Color32] = [
        Color32(r: 240, g: 163, b: 255, a: 255),
        Color32(r: 0, g: 117, b: 220, a: 255),
        Color32(r: 153, g: 63, b: 0, a: 255),
        Color32(r: 76, g: 0, b: 92, a: 255),
        Color32(r: 25, g: 25, b: 25, a: 255),
        Color32(r: 0, g: 92, b: 49, a: 255),
        Color32(r: 43, g: 206, b: 72, a: 255),
        Color32(r: 255, g: 204, b: 153, a: 255),
        Color32(r: 128, g: 128, b: 128, a: 255),
        Color32(r: 148, g: 255, b: 181, a: 255),
        Color32(r: 143, g: 124, b: 0, a: 255),
        Color32(r: 157, g: 204, b: 0, a: 255),
        Color32(r: 194, g: 0, b: 136, a: 255),
        Color32(r: 0, g: 51, b: 128, a: 255),
        Color32(r: 255, g: 164, b: 5, a: 255),
        Color32(r: 255, g: 168, b: 187, a: 255),
        Color32(r: 66, g: 102, b: 0, a: 255),
        Color32(r: 255, g: 0, b: 16, a: 255),
        Color32(r: 94, g: 241, b: 242, a: 255),
        Color32(r: 0, g: 153, b: 143, a: 255),
        Color32(r: 224, g: 255, b: 102, a: 255),
        Color32(r: 116, g: 10, b: 255, a: 255),
        Color32(r: 153, g: 0, b: 0, a: 255),
        Color32(r: 255, g: 255, b: 128, a: 255),
        Color32(r: 255, g: 255, b: 0, a: 255),
        Color32(r: 255, g: 80, b: 5, a: 255),
    ]

    public static let categoryNames: [String] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15",
    ]

    public static func DrawArrowGizmo(bodyLenght _: Float, bodyWidth _: Float, headLenght _: Float, headWidth _: Float) {}

    public static func DebugDrawCross(pos _: Vector3, size _: Float, color _: Color) {}

    public static func ShiftLeft<T>(source _: [T], index _: Int, count _: Int, positions _: Int) {}

    public static func ShiftRight<T>(source _: [T], index _: Int, count _: Int, positions _: Int) {}

    public static func AreValid(bounds _: Bounds) -> Bool { false }

    public static func Transform(b _: Bounds, m _: Matrix) -> Bounds { Bounds() }

    public static func CountTrailingZeroes(x _: Int) -> Int { 0 }

    public static func Add(a _: Vector3, b _: Vector3, result _: inout Vector3) {}

    public static func Remap(value _: Float, from1 _: Float, to1 _: Float, from2 _: Float, to2 _: Float) -> Float { 0 }

    public static func Mod(a _: Float, b _: Float) -> Float { 0 }

    public static func Add(a _: Matrix, other _: Matrix) -> Matrix { Matrix() }

    public static func FrobeniusNorm(a _: Matrix) -> Float { 0 }

    public static func ScalarMultiply(a _: Matrix, s _: Float) -> Matrix { Matrix() }

    public static func ProjectPointLine(point _: Vector3, lineStart _: Vector3, lineEnd _: Vector3,
                                        mu _: inout Float, clampToSegment _: Bool = true) -> Vector3
    {
        Vector3()
    }

    public static func LinePlaneIntersection(planePoint _: Vector3, planeNormal _: Vector3,
                                             linePoint _: Vector3, lineDirection _: Vector3, point _: inout Vector3) -> Bool
    {
        false
    }

    public static func RaySphereIntersection(rayOrigin _: Vector3, rayDirection _: Vector3,
                                             center _: Vector3, radius _: Float) -> Float
    {
        0
    }

    public static func InvMassToMass(invMass _: Float) -> Float { 0 }

    public static func MassToInvMass(mass _: Float) -> Float { 0 }

    public static func PureSign(val _: Float) -> Int { 0 }

    public static func NearestPointOnTri(p1 _: Vector3,
                                         p2 _: Vector3,
                                         p3 _: Vector3,
                                         p _: Vector3,
                                         result _: inout Vector3) {}

    public static func TriangleArea(p1 _: Vector3, p2 _: Vector3, p3 _: Vector3) -> Float { 0 }

    public static func EllipsoidVolume(principalRadii _: Vector3) -> Float { 0 }

    public static func RestDarboux(q1 _: Quaternion, q2 _: Quaternion) -> Quaternion {
        Quaternion()
    }

    public static func RestBendingConstraint(positionA _: Vector3, positionB _: Vector3, positionC _: Vector3) -> Float {
        0
    }

    public static func BilateralInterleaved(count _: Int) {}

    public static func BarycentricCoordinates(A _: Vector3,
                                              B _: Vector3,
                                              C _: Vector3,
                                              P _: Vector3,
                                              bary _: inout Vector3) {}

    public static func BarycentricInterpolation(p1 _: Vector3, p2 _: Vector3, p3 _: Vector3, coords _: Vector3, result _: Vector3) {}

    public static func BarycentricInterpolation(p1 _: Float, p2 _: Float, p3 _: Float, coords _: Vector3) -> Float {
        0
    }

    public static func BarycentricExtrapolationScale(coords _: Vector3) -> Float {
        0
    }

    public static func CalculateAngleWeightedNormals(vertices _: [Vector3], triangles _: [Int]) -> [Vector3] {
        []
    }

    public static func MakePhase(group _: Int, flags _: ParticleFlags) -> Int {
        0
    }

    public static func GetGroupFromPhase(phase _: Int) -> Int {
        0
    }

    public static func GetFlagsFromPhase(phase _: Int) -> ParticleFlags {
        []
    }

    public static func MakeFilter(mask _: Int, category _: Int) -> Int {
        0
    }

    public static func GetCategoryFromFilter(filter _: Int) -> Int {
        0
    }

    public static func GetMaskFromFilter(filter _: Int) -> Int {
        0
    }

    public static func EigenSolve(D _: Matrix, S _: inout Vector3, V _: inout Matrix) {}

    static func unitOrthogonal(input _: Vector3) -> Vector3 {
        Vector3()
    }

    static func EigenVector(D _: Matrix, S _: Float) -> Vector3 {
        Vector3()
    }

    static func EigenValues(D _: Matrix) -> Vector3 {
        Vector3()
    }

    public static func GetPointCloudCentroid(points _: [Vector3]) -> Vector3 {
        Vector3()
    }

    public static func GetPointCloudAnisotropy(points _: [Vector3], max_anisotropy _: Float, radius _: Float, hint_normal _: Vector3,
                                               centroid _: inout Vector3, orientation _: inout Quaternion, principal_radii _: inout Vector3) {}
}
