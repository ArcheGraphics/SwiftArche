//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import simd

class Spherical {
    public var radius: Float = 1.0
    public var phi: Float = 0
    public var theta: Float = 0
    private var _matrix: Matrix = .init()
    private var _matrixInv: Matrix = .init()

    init(radius: Float = 1.0, phi: Float = 0, theta: Float = 0) {
        self.radius = radius
        self.phi = phi
        self.theta = theta
    }

    func makeSafe() -> Spherical {
        let count: Float = floor(phi / .pi)
        phi = simd_clamp(phi, count * .pi + .leastNonzeroMagnitude, (count + 1) * .pi - .leastNonzeroMagnitude)
        return self
    }

    func set(_ radius: Float, _ phi: Float, _ theta: Float) -> Spherical {
        self.radius = radius
        self.phi = phi
        self.theta = theta
        return self
    }

    func setYAxis(_ up: Vector3) {
        var xAxis = Vector3(1, 0, 0)
        let yAxis = up.normalized
        if Vector3.equals(left: xAxis, right: yAxis) {
            xAxis = Vector3(0, 1, 0)
        }
        let zAxis = Vector3.cross(left: xAxis, right: yAxis).normalized
        xAxis = Vector3.cross(left: yAxis, right: zAxis)
        _matrix = Matrix(m11: xAxis.x, m12: xAxis.y, m13: xAxis.z, m14: 0,
                         m21: yAxis.x, m22: yAxis.y, m23: yAxis.z, m24: 0,
                         m31: zAxis.x, m32: zAxis.y, m33: zAxis.z, m34: 0,
                         m41: 0, m42: 0, m43: 0, m44: 1)
        _matrixInv = Matrix(m11: xAxis.x, m12: yAxis.x, m13: zAxis.x, m14: 0,
                            m21: xAxis.y, m22: yAxis.y, m23: zAxis.y, m24: 0,
                            m31: xAxis.z, m32: yAxis.z, m33: zAxis.z, m34: 0,
                            m41: 0, m42: 0, m43: 0, m44: 1)
    }

    func setFromVec3(_ value: Vector3, atTheBack: Bool = false) -> Spherical {
        var value = value
        _ = value.transformNormal(m: _matrixInv)
        radius = value.length()
        if radius == 0 {
            theta = 0
            phi = 0
        } else {
            if atTheBack {
                phi = 2 * .pi - acos(simd_clamp(value.y / radius, -1, 1))
                theta = atan2(-value.x, -value.z)
            } else {
                phi = acos(simd_clamp(value.y / radius, -1, 1))
                theta = atan2(value.x, value.z)
            }
        }
        return self
    }

    func setToVec3(_ value: inout Vector3) -> Bool {
        let sinPhiRadius = sin(phi) * radius
        phi -= floor(phi / .pi / 2) * .pi * 2
        value = Vector3(sinPhiRadius * sin(theta), radius * cos(phi), sinPhiRadius * cos(theta))
        _ = value.transformNormal(m: _matrix)
        return phi > .pi
    }
}
