//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class MathUtilTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquals() {
        XCTAssertEqual(MathUtil.equals(10, 10), true)

        var scale: Float = 0.9
        XCTAssertEqual(MathUtil.equals(10, 10 - MathUtil.zeroTolerance * scale), true)
        XCTAssertEqual(MathUtil.equals(10, 10 + MathUtil.zeroTolerance * scale), true)

        XCTAssertEqual(MathUtil.equals(10, 10 - MathUtil.zeroTolerance), true)
        XCTAssertEqual(MathUtil.equals(10, 10 + MathUtil.zeroTolerance), true)

        scale = 1.2
        XCTAssertEqual(MathUtil.equals(10, 10 - MathUtil.zeroTolerance * scale), false)
        XCTAssertEqual(MathUtil.equals(10, 10 + MathUtil.zeroTolerance * scale), false)
    }

    func testIsPowerOf2() {
        XCTAssertEqual(MathUtil.isPowerOf2(16), true)
        XCTAssertEqual(MathUtil.isPowerOf2(15), false)
    }

    func testRadianToDegree() {
        let d = MathUtil.radianToDegree(Float.pi / 3)
        XCTAssertEqual(MathUtil.equals(d, 60), true)
    }

    func testDegreeToRadian() {
        let r = MathUtil.degreeToRadian(60)
        XCTAssertEqual(MathUtil.equals(r, Float.pi / 3), true)
    }
}
