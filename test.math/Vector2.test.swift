//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class Vector2Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticAdd() {
        let a = Vector2(2, 3)
        let b = Vector2(-3, 5)
        let out = a + b

        XCTAssertEqual(out.x, -1)
        XCTAssertEqual(out.y, 8)
    }

    func testStaticSubtract() {
        let a = Vector2(2, 3)
        let b = Vector2(-3, 5)
        let out = a - b

        XCTAssertEqual(out.x, 5)
        XCTAssertEqual(out.y, -2)
    }

    func testStaticMultiply() {
        let a = Vector2(2, 3)
        let b = Vector2(-3, 5)
        let out = a * b

        XCTAssertEqual(out.x, -6)
        XCTAssertEqual(out.y, 15)
    }

    func testStaticDivide() {
        let a = Vector2(2, 3)
        let b = Vector2(-4, 5)
        let out = a / b

        XCTAssertEqual(out.x, -0.5)
        XCTAssertEqual(out.y, 0.6)
    }

    func testStaticDot() {
        let a = Vector2(2, 3)
        let b = Vector2(-4, 5)

        XCTAssertEqual(Vector2.dot(left: a, right: b), 7)
    }

    func testStaticDistance() {
        let a = Vector2(1, 1)
        let b = Vector2(4, 5)

        XCTAssertEqual(Vector2.distance(left: a, right: b), 5)
    }

    func testStaticDistanceSquared() {
        let a = Vector2(1, 1)
        let b = Vector2(4, 5)

        XCTAssertEqual(Vector2.distanceSquared(left: a, right: b), 25)
    }

    func testStaticEquals() {
        let a = Vector2(1, 2)
        let b = Vector2(1 + MathUtil.zeroTolerance * 0.9, 2)

        XCTAssertEqual(Vector2.equals(left: a, right: b), true)
    }

    func testStaticLerp() {
        let a = Vector2(0, 1)
        let b = Vector2(2, 3)
        let out = Vector2.lerp(left: a, right: b, t: 0.5)
        XCTAssertEqual(out.x, 1)
        XCTAssertEqual(out.y, 2)
    }

    func testStaticMax() {
        let a = Vector2(0, 10)
        let b = Vector2(2, 3)
        let out = Vector2.max(left: a, right: b)
        XCTAssertEqual(out.x, 2)
        XCTAssertEqual(out.y, 10)
    }

    func testStaticMin() {
        let a = Vector2(0, 10)
        let b = Vector2(2, 3)
        let out = Vector2.min(left: a, right: b)
        XCTAssertEqual(out.x, 0)
        XCTAssertEqual(out.y, 3)
    }

    func testStaticNegate() {
        let a = Vector2(4, -4)
        let out = Vector2.negate(left: a)
        XCTAssertEqual(out.x, -4)
        XCTAssertEqual(out.y, 4)
    }

    func testStaticNormalize() {
        let a = Vector2(3, 4)
        let out = Vector2.normalize(left: a)
        XCTAssertEqual(Vector2.equals(left: out, right: Vector2(0.6, 0.8)), true)
    }

    func testStaticScale() {
        let a = Vector2(3, 4)
        let out = Vector2.scale(left: a, s: 3)
        XCTAssertEqual(out.x, 9)
        XCTAssertEqual(out.y, 12)
    }

    func testSetValue() {
        var a = Vector2(3, 4)
        _ = a.set(x: 5, y: 6)
        XCTAssertEqual(a.x, 5)
        XCTAssertEqual(a.y, 6)
    }

    func testSetValueByArray() {
        var a = Vector2(3, 4)
        _ = a.set(array: [5, 6])
        XCTAssertEqual(a.x, 5)
        XCTAssertEqual(a.y, 6)

        var b: [Float] = [0, 0]
        a.toArray(out: &b)
        XCTAssertEqual(b[0], 5)
        XCTAssertEqual(b[1], 6)
    }

    func testClone() {
        let a = Vector2(3, 4)
        let b = a
        XCTAssertEqual(b.x, a.x)
        XCTAssertEqual(b.y, a.y)
    }

    func testCloneTo() {
        let a = Vector2(3, 4)
        let out = a
        XCTAssertEqual(out.x, a.x)
        XCTAssertEqual(out.y, a.y)
    }

    func testAdd() {
        let a = Vector2(3, 4)
        var ret = Vector2(1, 2)
        let result = ret.add(right: a)
        XCTAssertEqual(result.x, ret.x)
        XCTAssertEqual(result.y, ret.y)
        XCTAssertEqual(ret.x, 4)
        XCTAssertEqual(ret.y, 6)
    }

    func testSubtract() {
        let a = Vector2(3, 4)
        var ret = Vector2(1, 2)
        let result = ret.subtract(right: a)
        XCTAssertEqual(result.x, ret.x)
        XCTAssertEqual(result.y, ret.y)
        XCTAssertEqual(ret.x, -2)
        XCTAssertEqual(ret.y, -2)
    }

    func testMultiply() {
        let a = Vector2(3, 4)
        var ret = Vector2(1, 2)
        let result = ret.multiply(right: a)
        XCTAssertEqual(result.x, ret.x)
        XCTAssertEqual(result.y, ret.y)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 8)
    }

    func testDivide() {
        let a = Vector2(1, 2)
        var ret = Vector2(3, 4)
        let result = ret.divide(right: a)
        XCTAssertEqual(result.x, ret.x)
        XCTAssertEqual(result.y, ret.y)
        XCTAssertEqual(ret.x, 3)
        XCTAssertEqual(ret.y, 2)
    }

    func testLength() {
        let a = Vector2(3, 4)
        XCTAssertEqual(a.length(), 5)
    }

    func testLengthSquared() {
        let a = Vector2(3, 4)
        XCTAssertEqual(a.lengthSquared(), 25)
    }

    func testNegate() {
        var a = Vector2(3, 4)
        let result = a.negate()
        XCTAssertEqual(result.x, a.x)
        XCTAssertEqual(result.y, a.y)
        XCTAssertEqual(a.x, -3)
        XCTAssertEqual(a.y, -4)
    }

    func testNormalize() {
        var a = Vector2(3, 4)
        let result = a.normalize()
        XCTAssertEqual(result.x, a.x)
        XCTAssertEqual(result.y, a.y)
        XCTAssertEqual(Vector2.equals(left: a, right: Vector2(0.6, 0.8)), true)
    }

    func testScale() {
        var a = Vector2(3, 4)
        let result = a.scale(s: 2)
        XCTAssertEqual(result.x, a.x)
        XCTAssertEqual(result.y, a.y)
        XCTAssertEqual(a.x, 6)
        XCTAssertEqual(a.y, 8)
    }
}
