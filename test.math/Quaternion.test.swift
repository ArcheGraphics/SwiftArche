//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class QuaternionTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Quaternion(2, 3, 4, 1)
        let b = Quaternion(-3, 5, 0, 2)
        let out = a + b

        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
        XCTAssertEqual(out.z, 4)
        XCTAssertEqual(out.w, 3)
    }

    func testStaticMultiply() {
        let a = Quaternion(2, 3, 4, 1)
        let b = Quaternion(-3, 5, 0, 2)
        let out = a * b

        XCTAssertEqual(out.x, -19)
        XCTAssertEqual(out.y, -1)
        XCTAssertEqual(out.z, 27)
        XCTAssertEqual(out.w, -7)
    }

    func testStaticConjugate() {
        let a = Quaternion(2, 3, 4, 5)
        let out = Quaternion.conjugate(a: a)
        XCTAssertEqual(out.x, -2)
        XCTAssertEqual(out.y, -3)
        XCTAssertEqual(out.z, -4)
        XCTAssertEqual(out.w, 5)
    }

    func testStaticDot() {
        let a = Quaternion(2, 3, 1, 1)
        let b = Quaternion(-4, 5, 1, 1)

        XCTAssertEqual(Quaternion.dot(left: a, right: b), 9)
        XCTAssertEqual(a.dot(quat: b), 9)
    }

    func testStaticEquals() {
        let a = Quaternion(1, 2, 3, 4)
        let b = Quaternion(1 + MathUtil.zeroTolerance * 0.9, 2, 3, 4)

        XCTAssertEqual(Quaternion.equals(left: a, right: b), true)
    }

    func testStaticRotationAxisAngle() {
        var a = Vector3(3, 7, 5)
        let out = Quaternion.rotationAxisAngle(axis: a, rad: Float.pi / 3)
        var b = out.axis
        let rad = out.angle

        XCTAssertEqual(MathUtil.equals(rad, Float.pi / 3), true)
        XCTAssertEqual(Vector3.equals(left: b.normalize(), right: a.normalize()), true)
    }

    func testStaticRotationEuler() {
        let out1 = Quaternion.rotationEuler(x: 0, y: Float.pi / 3, z: Float.pi / 2)
        let out2 = Quaternion.rotationYawPitchRoll(yaw: 0, pitch: Float.pi / 3, roll: Float.pi / 2)

        let a = out1.toEuler()
        let b = out2.toYawPitchRoll()
        XCTAssertEqual(Vector3.equals(left: a, right: Vector3(0, Float.pi / 3, Float.pi / 2)), true)
        XCTAssertEqual(Vector3.equals(left: b, right: Vector3(0, Float.pi / 3, Float.pi / 2)), true)
    }

    func testStaticRotationMatrix3x3() {
        let a1 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: 9)
        let a2 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: -5, m23: 6, m31: 7, m32: 8, m33: -9)
        let a3 = Matrix3x3(m11: 1, m12: 2, m13: 3, m21: 4, m22: 5, m23: 6, m31: 7, m32: 8, m33: -9)
        let a4 = Matrix3x3(m11: -7, m12: 2, m13: 3, m21: 4, m22: -5, m23: 6, m31: 7, m32: 8, m33: 9)

        var out = Quaternion.rotationMatrix3x3(m: a1)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(-0.25, 0.5, -0.25, 2)), true)
        out = Quaternion.rotationMatrix3x3(m: a2)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(2, 0.75, 1.25, -0.25)), true)
        out = Quaternion.rotationMatrix3x3(m: a3)
        XCTAssertEqual(
                Quaternion.equals(
                        left: out,
                        right: Quaternion(0.8017837257372732, 1.8708286933869707, 1.8708286933869709, 0.5345224838248488)
                ), true)
        out = Quaternion.rotationMatrix3x3(m: a4)
        XCTAssertEqual(
                Quaternion.equals(
                        left: out,
                        right: Quaternion(1.066003581778052, 1.4924050144892729, 2.345207879911715, -0.21320071635561041)
                ), true)
    }

    func testStaticInvert() {
        let a = Quaternion(1, 1, 1, 0.5)
        let out = Quaternion.invert(a: a)
        XCTAssertEqual(
                Quaternion.equals(
                        left: out,
                        right: Quaternion(-0.3076923076923077, -0.3076923076923077, -0.3076923076923077, 0.15384615384615385)
                ), true)
    }

    func testStaticSlerp() {
        let a = Quaternion(1, 1, 1, 0.5)
        let b = Quaternion(0.5, 0.5, 0.5, 0.5)
        let out = Quaternion.slerp(start: a, end: b, t: 0.5)
        XCTAssertEqual(out.x, 0.5388158)
        XCTAssertEqual(out.y, 0.5388158)
        XCTAssertEqual(out.z, 0.5388158)
        XCTAssertEqual(out.w, 0.35921052)
    }

    func testStaticNormalize() {
        let a = Quaternion(3, 4, 0, 0)
        let out = Quaternion.normalize(left: a)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0.6, 0.8, 0, 0)), true)
    }

    func testStaticRotation() {
        var out = Quaternion.rotationX(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0.6816387600233341, 0, 0, 0.7316888688738209)), true)

        out = Quaternion.rotationY(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0, 0.6816387600233341, 0, 0.7316888688738209)), true)

        out = Quaternion.rotationZ(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0, 0, 0.6816387600233341, 0.7316888688738209)), true)
    }

    func testStaticRotate() {
        let a = Quaternion()
        var b = Quaternion()

        var out = Quaternion.rotateX(quaternion: a, rad: 1.5)
        _ = b.rotateX(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0.6816387600233341, 0, 0, 0.7316888688738209)), true)
        XCTAssertEqual(Quaternion.equals(left: out, right: b), true)

        out = Quaternion.rotateY(quaternion: a, rad: 1.5)
        _ = b.set(x: 0, y: 0, z: 0, w: 1)
        _ = b.rotateY(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0, 0.6816387600233341, 0, 0.7316888688738209)), true)
        XCTAssertEqual(Quaternion.equals(left: out, right: b), true)

        out = Quaternion.rotateZ(quaternion: a, rad: 1.5)
        _ = b.set(x: 0, y: 0, z: 0, w: 1)
        _ = b.rotateZ(rad: 1.5)
        XCTAssertEqual(Quaternion.equals(left: out, right: Quaternion(0, 0, 0.6816387600233341, 0.7316888688738209)), true)
        XCTAssertEqual(Quaternion.equals(left: out, right: b), true)
    }

    func testStaticScale() {
        let a = Quaternion(3, 4, 5, 0)
        let out = Quaternion.scale(left: a, s: 3)
        XCTAssertEqual(out.x, 9)
        XCTAssertEqual(out.y, 12)
        XCTAssertEqual(out.z, 15)
        XCTAssertEqual(out.w, 0)
    }

    func testStaticToEuler() {
        let a = Quaternion.rotationEuler(x: 0, y: Float.pi / 3, z: 0)
        let euler = a.toEuler()
        let ypr = a.toYawPitchRoll()
        XCTAssertEqual(Vector3.equals(left: euler, right: Vector3(0, Float.pi / 3, 0)), true)
        XCTAssertEqual(Vector3.equals(left: ypr, right: Vector3(Float.pi / 3, 0, 0)), true)
    }

    func testSetValue() {
        var a = Quaternion()
        _ = a.set(x: 1, y: 1, z: 1, w: 1)
        var b = Quaternion()
        _ = b.set(array: [1, 1, 1, 1])
        XCTAssertEqual(Quaternion.equals(left: a, right: b), true)

        var c = [Float](repeating: 0, count: 4)
        b.toArray(out: &c)
        var d = Quaternion()
        _ = d.set(array: c)
        XCTAssertEqual(Quaternion.equals(left: a, right: d), true)
    }

    func testClone() {
        let a = Quaternion(3, 4, 5, 0)
        let b = a
        XCTAssertEqual(a.x, b.x)
        XCTAssertEqual(a.y, b.y)
        XCTAssertEqual(a.z, b.z)
        XCTAssertEqual(a.w, b.w)
    }

    func testCloneTo() {
        let a = Quaternion(3, 4, 5, 0)
        let out = a
        XCTAssertEqual(a.x, out.x)
        XCTAssertEqual(a.y, out.y)
        XCTAssertEqual(a.z, out.z)
        XCTAssertEqual(a.w, out.w)
    }

    func testConjugate() {
        var a = Quaternion(1, 1, 1, 1)
        let out = a.conjugate()
        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, -1)
        XCTAssertEqual(out.z, -1)
        XCTAssertEqual(out.w, 1)
    }

    func testIdentity() {
        var a = Quaternion()
        _ = a.identity()
        XCTAssertEqual(a.x, 0)
        XCTAssertEqual(a.y, 0)
        XCTAssertEqual(a.z, 0)
        XCTAssertEqual(a.w, 1)
    }

    func testLength() {
        let a = Quaternion(3, 4, 5, 0)
        XCTAssertEqual(MathUtil.equals(sqrt(50), a.length()), true)
        XCTAssertEqual(a.lengthSquared(), 50)
    }
}
