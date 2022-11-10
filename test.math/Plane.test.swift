//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class PlaneTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        let point1 = Vector3(0, 1, 0)
        let point2 = Vector3(0, 1, 1)
        let point3 = Vector3(1, 1, 0)
        var plane1 = Plane.fromPoints(point0: point1, point1: point2, point2: point3)
        var plane2 = Plane(Vector3(0, 1, 0), -1)

        XCTAssertEqual(plane1.distance - plane2.distance, 0)
        _ = plane1.normalize()
        _ = plane2.normalize()
        XCTAssertEqual(Vector3.equals(left: plane1.normal, right: plane2.normal), true)
    }

    func testClone() {
        let plane1 = Plane(Vector3(0, 1, 0), -1)
        let plane2 = plane1
        XCTAssertEqual(plane1.distance - plane2.distance, 0)

        let plane3 = plane1
        XCTAssertEqual(plane1.distance - plane3.distance, 0)
    }
}
