//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

final class SphericalHarmonics3Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddLight() throws {
        var a = SphericalHarmonics3()
        a.addLight(direction: Vector3(0, 1, 0), color: Color(1, 0, 0, 1), deltaSolidAngle: 10)
        let b: [Float] = [
            2.8209500312805176,
            0,
            0,
            -4.886030197143555,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            -3.1539199352264404,
            0,
            0,
            0,
            0,
            0,
            -5.462739944458008,
            0,
            0
        ]
        var i = 0
        for _ in b {
            XCTAssertEqual(MathUtil.equals(a.coefficients[i], b[i]), true)
            i = i + 1;
        }
    }

    func testEvaluate() {
        var a = SphericalHarmonics3();
        a.addLight(direction: Vector3(0, 1, 0), color: Color(1, 0, 0, 1), deltaSolidAngle: 10);
        let color = a.evaluate(direction: Vector3(0, 1, 0));
        XCTAssertEqual(color.r, 10.625004777489186);
    }

    func testScale() {
        var a = SphericalHarmonics3();
        a.addLight(direction: Vector3(0, 1, 0), color: Color(1, 0, 0, 1), deltaSolidAngle: 10);
        a *= 0.5;
        let b: [Float] = [
            1.4104750156402588,
            0,
            0,
            -2.4430150985717773,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            -1.5769599676132202,
            0,
            0,
            0,
            0,
            0,
            -2.731369972229004,
            0,
            0
        ];
        var i = 0
        for _ in b {
            XCTAssertEqual(MathUtil.equals(a.coefficients[i], b[i]), true)
            i = i + 1;
        }
    }

    func testSetValueByArray() {
        var a = SphericalHarmonics3();
        let b: [Float] = [
            1.4104750156402588,
            0,
            0,
            -2.4430150985717773,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            -1.5769599676132202,
            0,
            0,
            0,
            0,
            0,
            -2.731369972229004,
            0,
            0
        ];
        a.set(array: b);
        var i = 0
        for _ in b {
            XCTAssertEqual(MathUtil.equals(a.coefficients[i], b[i]), true)
            i = i + 1;
        }
    }
}
