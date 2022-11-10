//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class Vector3Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Vector3(2, 3, 4)
        let b = Vector3(-3, 5, 0)
        let out = a + b

        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
        XCTAssertEqual(out.z, 4)
    }

    func testStaticSubtract() {
        let a = Vector3(2, 3, 4)
        let b = Vector3(-3, 5, 1)
        let out = a - b

        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, -2)
        XCTAssertEqual(out.z, 3)
    }

    func testStaticMultiply() {
        let a = Vector3(2, 3, 4)
        let b = Vector3(-3, 5, 0.2)
        let out = a * b

        XCTAssertEqual(out.x, -6)
        XCTAssertEqual(out.y, 15)
        XCTAssertEqual(out.z, 0.8)
    }

    func testStaticDivide() {
        let a = Vector3(2, 3, 4)
        let b = Vector3(-4, 5, 16)
        let out = a / b

        XCTAssertEqual(out.x, -0.5)
        XCTAssertEqual(out.y, 0.6)
        XCTAssertEqual(out.z, 0.25)
    }

    func testStaticDot() {
        let a = Vector3(2, 3, 1)
        let b = Vector3(-4, 5, 1)

        XCTAssertEqual(Vector3.dot(left: a, right: b), 8)
    }

    func testStaticCross() {
        let a = Vector3(1, 2, 3)
        let b = Vector3(4, 5, 6)
        let out = Vector3.cross(left: a, right: b)
        XCTAssertEqual(out.x, -3)
        XCTAssertEqual(out.y, 6)
        XCTAssertEqual(out.z, -3)
    }

    func testStaticDistance() {
        let a = Vector3(1, 2, 3)
        let b = Vector3(4, 6, 3)

        XCTAssertEqual(Vector3.distance(left: a, right: b), 5)
        XCTAssertEqual(Vector3.distanceSquared(left: a, right: b), 25)
    }

    func testStaticEquals() {
        let a = Vector3(1, 2, 3)
        let b = Vector3(1 + MathUtil.zeroTolerance * 0.9, 2, 3)

        XCTAssertEqual(Vector3.equals(left: a, right: b), true)
    }

    func testStaticLerp() {
        let a = Vector3(0, 1, 2)
        let b = Vector3(2, 2, 0)
        let out = Vector3.lerp(left: a, right: b, t: 0.5)
        XCTAssertEqual(out.x, 1)
        XCTAssertEqual(out.y, 1.5)
        XCTAssertEqual(out.z, 1)
    }

    func testStaticMax() {
        let a = Vector3(0, 10, 1)
        let b = Vector3(2, 3, 5)
        let out = Vector3.max(left: a, right: b)
        XCTAssertEqual(out.x, 2)
        XCTAssertEqual(out.y, 10)
        XCTAssertEqual(out.z, 5)
    }

    func testStaticMin() {
        let a = Vector3(0, 10, 1)
        let b = Vector3(2, 3, 5)
        let out = Vector3.min(left: a, right: b)
        XCTAssertEqual(out.x, 0)
        XCTAssertEqual(out.y, 3)
        XCTAssertEqual(out.z, 1)
    }

    func testStaticNegate() {
        let a = Vector3(4, -4, 0)
        let out = -a
        XCTAssertEqual(out.x, -4)
        XCTAssertEqual(out.y, 4)
        XCTAssertEqual(out.z, 0)
    }

    func testStaticNormalize() {
        let a = Vector3(3, 4, 0)
        let out = Vector3.normalize(left: a)
        XCTAssertEqual(Vector3.equals(left: out, right: Vector3(0.6, 0.8, 0)), true)
    }

    func testStaticScale() {
        let a = Vector3(3, 4, 5)
        let out = a * 3
        XCTAssertEqual(out.x, 9)
        XCTAssertEqual(out.y, 12)
        XCTAssertEqual(out.z, 15)
    }

    func testStaticTransform() {
        let a = Vector3(2, 3, 4)
        let m44 = Matrix(m11: 2, m12: 7, m13: 17, m14: 0,
                m21: 3, m22: 11, m23: 19, m24: 0,
                m31: 5, m32: 13, m33: 23, m34: 0,
                m41: 0, m42: 0, m43: 0, m44: 1)
        var out = Vector3.transformNormal(v: a, m: m44)
        XCTAssertEqual(out.x, 33)
        XCTAssertEqual(out.y, 99)
        XCTAssertEqual(out.z, 183)

        let b = Vector4(2, 3, 4, 1)
        var m4 = Matrix()
        _ = m4.set(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: 1, m44: 1)
        out = Vector3.transformCoordinate(v: a, m: m4)
        let out4 = Vector4.transform(v: b, m: m4)
        XCTAssertEqual(out.x, out4.x / out4.w)
        XCTAssertEqual(out.y, out4.y / out4.w)
        XCTAssertEqual(out.z, out4.z / out4.w)

        out = Vector3.transformByQuat(v: a, quaternion: Quaternion())
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)

        out = Vector3.transformByQuat(v: a, quaternion: Quaternion(2, 3, 4, 5))
        XCTAssertEqual(out.x, 108)
        XCTAssertEqual(out.y, 162)
        XCTAssertEqual(out.z, 216)
    }

    func testSetValue() {
        var a = Vector3(3, 4, 5)
        let out = a.set(x: 5, y: 6, z: 7)
        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, 6)
        XCTAssertEqual(out.z, 7)
    }

    func testSetValueByArray() {
        var a = Vector3(3, 4, 3)
        let out = a.set(array: [5, 6, 4])
        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, 6)
        XCTAssertEqual(out.z, 4)

        var b: [Float] = [0, 0, 0]
        a.toArray(out: &b)
        XCTAssertEqual(b[0], 5)
        XCTAssertEqual(b[1], 6)
        XCTAssertEqual(b[2], 4)
    }

    func testClone() {
        let a = Vector3(3, 4, 5)
        let b = a
        XCTAssertEqual(a.x, b.x)
        XCTAssertEqual(a.y, b.y)
        XCTAssertEqual(a.z, b.z)
    }

    func testCloneTo() {
        let a = Vector3(3, 4, 5)
        let out = a
        XCTAssertEqual(a.x, out.x)
        XCTAssertEqual(a.y, out.y)
        XCTAssertEqual(a.z, out.z)
    }

    func testAdd() {
        let a = Vector3(3, 4, 5)
        var ret = Vector3(1, 2, 4)
        let out = ret.add(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(ret.x, 4)
        XCTAssertEqual(ret.y, 6)
        XCTAssertEqual(ret.z, 9)
    }

    func testSubtract() {
        let a = Vector3(3, 4, 5)
        var ret = Vector3(1, 2, 8)
        let out = ret.subtract(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(ret.x, -2)
        XCTAssertEqual(ret.y, -2)
        XCTAssertEqual(ret.z, 3)
    }

    func testMultiply() {
        let a = Vector3(3, 4, 5)
        var ret = Vector3(1, 2, 1)
        let out = ret.multiply(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 8)
        XCTAssertEqual(ret.z, 5)
    }

    func testDivide() {
        let a = Vector3(1, 2, 3)
        var ret = Vector3(3, 4, 12)
        let out = ret.divide(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 2)
        XCTAssertEqual(ret.z, 4)
    }

    func testLength() {
        let a = Vector3(3, 4, 5)
        XCTAssertEqual(MathUtil.equals(sqrt(50), a.length()), true)
        XCTAssertEqual(a.lengthSquared(), 50)
    }

    func testNegate() {
        var a = Vector3(3, 4, 5)
        let out = a.negate()
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(a.x, -3)
        XCTAssertEqual(a.y, -4)
        XCTAssertEqual(a.z, -5)
    }

    func testNormalize() {
        var a = Vector3(3, 4, 0)
        let out = a.normalize()
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(Vector3.equals(left: a, right: Vector3(0.6, 0.8, 0)), true)
    }

    func testScale() {
        var a = Vector3(3, 4, 0)
        let out = a.scale(s: 2)
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(a.x, 6)
        XCTAssertEqual(a.y, 8)
        XCTAssertEqual(a.z, 0)
    }

    func testTransformToVec3() {
        var a = Vector3(2, 3, 4)
        let out = Vector3(2, 3, 5)
        let m = Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: 1, m44: 1)
        _ = a.transformToVec3(m: m)
        XCTAssertEqual(a.x, out.x)
        XCTAssertEqual(a.y, out.y)
        XCTAssertEqual(a.z, out.z)
    }

    func testTransformCoordinate() {
        let a = Vector3(2, 3, 4)
        let b = Vector4(2, 3, 4, 1)
        var m4 = Matrix()
        _ = m4.set(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: 1, m44: 1)
        let out = Vector3.transformCoordinate(v: a, m: m4)
        let out4 = Vector4.transform(v: b, m: m4)
        XCTAssertEqual(out.x, out4.x / out4.w)
        XCTAssertEqual(out.y, out4.y / out4.w)
        XCTAssertEqual(out.z, out4.z / out4.w)
    }

    func testTransformByQuat() {
        var a = Vector3(2, 3, 4)
        _ = a.transformByQuat(quaternion: Quaternion(2, 3, 4, 5))
        XCTAssertEqual(a.x, 108)
        XCTAssertEqual(a.y, 162)
        XCTAssertEqual(a.z, 216)
    }
}
