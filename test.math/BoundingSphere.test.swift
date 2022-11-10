//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class BoundingSphereTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        // Create a same sphere by different param.
        let points = [
            Vector3(0, 0, 0),
            Vector3(-1, 0, 0),
            Vector3(0, 0, 0),
            Vector3(0, 1, 0),
            Vector3(1, 1, 1),
            Vector3(0, 0, 1),
            Vector3(-1, -0.5, -0.5),
            Vector3(0, -0.5, -0.5),
            Vector3(1, 0, -1),
            Vector3(0, -1, 0)
        ]
        let sphere1 = BoundingSphere.fromPoints(points: points)

        let box = BoundingBox(Vector3(-1, -1, -1), Vector3(1, 1, 1))
        let sphere2 = BoundingSphere.fromBox(box: box)

        let center1 = sphere1.center
        let radius1 = sphere1.radius
        let center2 = sphere2.center
        let radius2 = sphere2.radius
        XCTAssertEqual(Vector3.equals(left: center1, right: center2), true)
        XCTAssertEqual(radius1, radius2)
    }

    func testClone() {
        let a = BoundingSphere(Vector3(0, 0, 0), 3)
        let b = a
        XCTAssertEqual(Vector3.equals(left: a.center, right: b.center), true)
        XCTAssertEqual(a.radius, b.radius)
    }

    func testCloneTo() {
        let a = BoundingSphere(Vector3(0, 0, 0), 3)
        let out = a
        XCTAssertEqual(Vector3.equals(left: a.center, right: out.center), true)
        XCTAssertEqual(a.radius, out.radius)
    }
}
