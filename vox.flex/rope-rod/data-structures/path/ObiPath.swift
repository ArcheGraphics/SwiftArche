//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiPath {
    var m_Names: [String] = []
    public var m_Points = ObiPointsDataChannel()
    var m_Normals = ObiNormalDataChannel()
    var m_Colors = ObiColorDataChannel()
    var m_Thickness = ObiThicknessDataChannel()
    var m_Masses = ObiMassDataChannel()
    var m_RotationalMasses = ObiRotationalMassDataChannel()

    var m_Filters = ObiPhaseDataChannel()

    private var m_Closed = false

    var dirty = false
    let arcLenghtSamples = 20
    var m_ArcLengthTable: [Float] = []
    var m_TotalSplineLenght: Float = 0.0

    public func GetSpanCount() -> Int {
        0
    }

    public func GetSpanControlPointForMu(mu _: Float, spanMu _: inout Float) -> Int {
        0
    }

    public func GetClosestControlPointIndex(mu _: Float) -> Int {
        0
    }

    /// Returns the curve parameter (mu) at a certain length of the curve, using linear interpolation
    /// of the values cached in arcLengthTable.
    public func GetMuAtLenght(length _: Float) -> Float {
        0
    }

    /// Recalculates spline arc lenght in world space using Gauss-Lobatto adaptive integration.
    /// - Parameters:
    ///   - referenceFrame: referenceFrame
    ///   - acc: minimum accuray desired (eg 0.00001f)
    ///   - maxevals: maximum number of spline evaluations we want to allow per segment.
    public func RecalculateLenght(referenceFrame _: Matrix, acc _: Float, maxevals _: Int) -> Float {
        0
    }

    /// One step of the adaptive integration method using Gauss-Lobatto quadrature.
    /// Takes advantage of the fact that the arc lenght of a vector function is equal to the
    /// integral of the magnitude of first derivative.
    private func GaussLobattoIntegrationStep(p1 _: Vector3, p2 _: Vector3, p3 _: Vector3, p4 _: Vector3,
                                             a _: Float, b _: Float,
                                             fa _: Float, fb _: Float, nevals _: Int, maxevals _: Int, acc _: Float) -> Float
    {
        0
    }

    public func SetName(index _: Int, name _: String) {}

    public func GetName(index _: Int) -> String {
        ""
    }

    public func AddControlPoint(position _: Vector3, inTangentVector _: Vector3, outTangentVector _: Vector3,
                                normal _: Vector3, mass _: Float, rotationalMass _: Float,
                                thickness _: Float, filter _: Int, color _: Color, name _: String) {}

    public func InsertControlPoint(index _: Int, position _: Vector3, inTangentVector _: Vector3,
                                   outTangentVector _: Vector3, normal _: Vector3, mass _: Float,
                                   rotationalMass _: Float, thickness _: Float,
                                   filter _: Int, color _: Color, name _: String) {}

    public func InsertControlPoint(mu _: Float) -> Int {
        0
    }

    public func Clear() {}

    public func RemoveControlPoint(index _: Int) {}

    public func FlushEvents() {}
}
