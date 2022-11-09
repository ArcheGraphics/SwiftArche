//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
import simd
@testable import vox_math

class ColorTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let color1 = Color(1, 0.5, 0.5, 1)
        let color2 = Color(1, 0.5, 0.5, 1)

        XCTAssertEqual(Color.equals(left: color1, right: color2), true)
    }

    func testSetValue() {
        let color1 = Color(1, 0.5, 0.5, 1)
        var color2 = Color()
        _ = color2.set(r: 1, g: 0.5, b: 0.5, a: 1)

        XCTAssertEqual(Color.equals(left: color1, right: color2), true)
    }

    func testScale() {
        var color1 = Color(0.5, 0.5, 0.5, 0.5)
        var color2 = Color(1, 1, 1, 1)

        _ = color1.scale(s: 2)
        XCTAssertEqual(color1.r, color2.r)
        XCTAssertEqual(color1.g, color2.g)
        XCTAssertEqual(color1.b, color2.b)
        XCTAssertEqual(color1.a, color2.a)

        color2 = color1 * 0.5
        XCTAssertEqual(color2.r, 0.5)
        XCTAssertEqual(color2.g, 0.5)
        XCTAssertEqual(color2.b, 0.5)
        XCTAssertEqual(color2.a, 0.5)
    }

    func testAdd() {
        var color1 = Color(1, 0, 0, 0)
        var color2 = Color(0, 1, 0, 0)

        _ = color1.add(color: color2)
        XCTAssertEqual(color1.r, 1)
        XCTAssertEqual(color1.g, 1)
        XCTAssertEqual(color1.b, 0)
        XCTAssertEqual(color1.a, 0)

        color2 = color1 + Color(0, 0, 1, 0)
        XCTAssertEqual(color2.r, 1)
        XCTAssertEqual(color2.g, 1)
        XCTAssertEqual(color2.b, 1)
        XCTAssertEqual(color2.a, 0)
    }

    func testClone() {
        let a = Color()
        let b = a

        XCTAssertEqual(Color.equals(left: a, right: b), true)
    }

    func testCloneTo() {
        let a = Color()
        let out = a

        XCTAssertEqual(Color.equals(left: a, right: out), true)
    }

    func testLinearAndGamma() {
        let fixColor = { (color: inout Color) in
            color.set(r: floor(color.r * 1000) / 1000,
                    g: floor(color.g * 1000) / 1000,
                    b: floor(color.b * 1000) / 1000, a: 1)
        }

        var colorLinear = Color()
        var colorGamma = Color()
        var colorNewLinear = Color()

        for _ in 0..<100 {
            _ = colorLinear.set(r: Float.random(in: 0..<1),
                    g: Float.random(in: 0..<1),
                    b: Float.random(in: 0..<1), a: 1)
            _ = fixColor(&colorLinear)

            colorGamma = colorLinear.toGamma()
            colorNewLinear = colorGamma.toLinear()

            _ = fixColor(&colorLinear)
            _ = fixColor(&colorNewLinear)

            XCTAssertEqual(simd_distance(colorLinear.elements, colorNewLinear.elements) < 1.0e-3, true)
        }
    }
}
