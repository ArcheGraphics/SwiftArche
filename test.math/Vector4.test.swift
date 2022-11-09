//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class Vector4Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Vector4(2, 3, 4, 1)
        let b = Vector4(-3, 5, 0, 2)
        let out = a + b

        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
        XCTAssertEqual(out.z, 4)
        XCTAssertEqual(out.w, 3)
    }

    func testStaticSubtract() {
        let a = Vector4(2, 3, 4, 1)
        let b = Vector4(-3, 5, 1, 2)
        let out = a - b

        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, -2)
        XCTAssertEqual(out.z, 3)
        XCTAssertEqual(out.w, -1)
    }

    func testStaticMultiply() {
        let a = Vector4(2, 3, 4, 1)
        let b = Vector4(-3, 5, 0.2, 2)
        let out = a * b

        XCTAssertEqual(out.x, -6)
        XCTAssertEqual(out.y, 15)
        XCTAssertEqual(out.z, 0.8)
        XCTAssertEqual(out.w, 2)
    }

    func testStaticDivide() {
        let a = Vector4(2, 3, 4, 1)
        let b = Vector4(-4, 5, 16, 2)
        let out = a / b

        XCTAssertEqual(out.x, -0.5)
        XCTAssertEqual(out.y, 0.6)
        XCTAssertEqual(out.z, 0.25)
        XCTAssertEqual(out.w, 0.5)
    }

    func testStaticDot() {
        let a = Vector4(2, 3, 1, 1)
        let b = Vector4(-4, 5, 1, 1)

        XCTAssertEqual(Vector4.dot(left: a, right: b), 9)
    }

    func testStaticDistance() {
        let a = Vector4(1, 2, 3, 0)
        let b = Vector4(4, 6, 3, 0)

        XCTAssertEqual(Vector4.distance(left: a, right: b), 5)
        XCTAssertEqual(Vector4.distanceSquared(left: a, right: b), 25)
    }

    func testStaticEquals() {
        let a = Vector4(1, 2, 3, 4)
        let b = Vector4(1 + MathUtil.zeroTolerance * 0.9, 2, 3, 4)

        XCTAssertEqual(Vector4.equals(left: a, right: b), true)
    }

    func testStaticLerp() {
        let a = Vector4(0, 1, 2, 0)
        let b = Vector4(2, 2, 0, 0)
        let out = Vector4.lerp(left: a, right: b, t: 0.5)
        XCTAssertEqual(out.x, 1)
        XCTAssertEqual(out.y, 1.5)
        XCTAssertEqual(out.z, 1)
        XCTAssertEqual(out.w, 0)
    }

    func testStaticMax() {
        let a = Vector4(0, 10, 1, -1)
        let b = Vector4(2, 3, 5, -5)
        let out = Vector4.max(left: a, right: b)
        XCTAssertEqual(out.x, 2)
        XCTAssertEqual(out.y, 10)
        XCTAssertEqual(out.z, 5)
        XCTAssertEqual(out.w, -1)
    }

    func testStaticMin() {
        let a = Vector4(0, 10, 1, -1)
        let b = Vector4(2, 3, 5, -5)
        let out = Vector4.min(left: a, right: b)
        XCTAssertEqual(out.x, 0)
        XCTAssertEqual(out.y, 3)
        XCTAssertEqual(out.z, 1)
        XCTAssertEqual(out.w, -5)
    }

    func testStaticNegate() {
        let a = Vector4(4, -4, 0, 1)
        let out = Vector4.negate(left: a)
        XCTAssertEqual(out.x, -4)
        XCTAssertEqual(out.y, 4)
        XCTAssertEqual(out.z, 0)
        XCTAssertEqual(out.w, -1)
    }

    func testStaticNormalize() {
        let a = Vector4(3, 4, 0, 0)
        let out = Vector4.normalize(left: a)
        XCTAssertEqual(Vector4.equals(left: out, right: Vector4(0.6, 0.8, 0, 0)), true)
    }

    func testStaticScale() {
        let a = Vector4(3, 4, 5, 0)
        let out = Vector4.scale(left: a, s: 3)
        XCTAssertEqual(out.x, 9)
        XCTAssertEqual(out.y, 12)
        XCTAssertEqual(out.z, 15)
        XCTAssertEqual(out.w, 0)
    }

    func testStaticTransform() {
        let a = Vector4(2, 3, 4, 5)
        var m4 = Matrix()
        _ = m4.set(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: 1, m44: 0)
        var out = Vector4.transform(v: a, m: m4)
        XCTAssertEqual(out.x, 2)
        XCTAssertEqual(out.y, 3)
        XCTAssertEqual(out.z, 9)
        XCTAssertEqual(out.w, 0)

        out = Vector4.transformByQuat(v: a, q: Quaternion())
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(out.w, a.w)

        out = Vector4.transformByQuat(v: a, q: Quaternion(2, 3, 4, 5))
        XCTAssertEqual(out.x, 108)
        XCTAssertEqual(out.y, 162)
        XCTAssertEqual(out.z, 216)
        XCTAssertEqual(out.w, 5)
    }

    func testSetValue() {
        var a = Vector4(3, 4, 5, 0)
        let out = a.set(x: 5, y: 6, z: 7, w: 1)
        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, 6)
        XCTAssertEqual(out.z, 7)
        XCTAssertEqual(out.w, 1)
    }

    func testSetValueByArray() {
        var a = Vector4(3, 4, 3, 8)
        let out = a.set(array: [5, 6, 4, 1])
        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, 6)
        XCTAssertEqual(out.z, 4)
        XCTAssertEqual(out.w, 1)

        var b: [Float] = [0, 0, 0, 0]
        a.toArray(out: &b)
        XCTAssertEqual(b[0], 5)
        XCTAssertEqual(b[1], 6)
        XCTAssertEqual(b[2], 4)
        XCTAssertEqual(b[3], 1)
    }

    func testClone() {
        let a = Vector4(3, 4, 5, 0)
        let b = a
        XCTAssertEqual(a.x, b.x)
        XCTAssertEqual(a.y, b.y)
        XCTAssertEqual(a.z, b.z)
        XCTAssertEqual(a.w, b.w)
    }

    func testCloneTo() {
        let a = Vector4(3, 4, 5, 0)
        let out = a
        XCTAssertEqual(a.x, out.x)
        XCTAssertEqual(a.y, out.y)
        XCTAssertEqual(a.z, out.z)
        XCTAssertEqual(a.w, out.w)
    }

    func testAdd() {
        let a = Vector4(3, 4, 5, 1)
        var ret = Vector4(1, 2, 4, 1)
        let out = ret.add(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(out.w, ret.w)
        XCTAssertEqual(ret.x, 4)
        XCTAssertEqual(ret.y, 6)
        XCTAssertEqual(ret.z, 9)
        XCTAssertEqual(ret.w, 2)
    }

    func testSubtract() {
        let a = Vector4(3, 4, 5, 1)
        var ret = Vector4(1, 2, 8, 1)
        let out = ret.subtract(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(out.w, ret.w)
        XCTAssertEqual(ret.x, -2)
        XCTAssertEqual(ret.y, -2)
        XCTAssertEqual(ret.z, 3)
        XCTAssertEqual(ret.w, 0)
    }

    func testMultiply() {
        let a = Vector4(3, 4, 5, 1)
        var ret = Vector4(1, 2, 1, 1)
        let out = ret.multiply(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(out.w, ret.w)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 8)
        XCTAssertEqual(ret.z, 5)
        XCTAssertEqual(ret.w, 1)
    }

    func testDivide() {
        let a = Vector4(1, 2, 3, 1)
        var ret = Vector4(3, 4, 12, 1)
        let out = ret.divide(right: a)
        XCTAssertEqual(out.x, ret.x)
        XCTAssertEqual(out.y, ret.y)
        XCTAssertEqual(out.z, ret.z)
        XCTAssertEqual(out.w, ret.w)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 2)
        XCTAssertEqual(ret.z, 4)
        XCTAssertEqual(ret.w, 1)
    }

    func testLength() {
        let a = Vector4(3, 4, 5, 0)
        XCTAssertEqual(MathUtil.equals(sqrt(50), a.length()), true)
        XCTAssertEqual(a.lengthSquared(), 50)
    }

    func testNegate() {
        var a = Vector4(3, 4, 5, 0)
        let out = a.negate()
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(out.w, a.w)
        XCTAssertEqual(a.x, -3)
        XCTAssertEqual(a.y, -4)
        XCTAssertEqual(a.z, -5)
        XCTAssertEqual(a.w, 0)
    }

    func testNormalize() {
        var a = Vector4(3, 4, 0, 0)
        let out = a.normalize()
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(out.w, a.w)
        XCTAssertEqual(Vector4.equals(left: a, right: Vector4(0.6, 0.8, 0, 0)), true)
    }

    func testScale() {
        var a = Vector4(3, 4, 0, 0)
        let out = a.scale(s: 2)
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
        XCTAssertEqual(out.z, a.z)
        XCTAssertEqual(out.w, a.w)
        XCTAssertEqual(a.x, 6)
        XCTAssertEqual(a.y, 8)
        XCTAssertEqual(a.z, 0)
        XCTAssertEqual(a.w, 0)
    }
}
