//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class BoundingBoxTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConstructor() {
        // Create a same box by different param.
        let box1 = BoundingBox.fromCenterAndExtent(center: Vector3(0, 0, 0), extent: Vector3(1, 1, 1))

        let points = [
            Vector3(0, 0, 0),
            Vector3(-1, 0, 0),
            Vector3(1, 0, 0),
            Vector3(0, 1, 0),
            Vector3(0, 1, 1),
            Vector3(1, 0, 1),
            Vector3(0, 0.5, 0.5),
            Vector3(0, -0.5, 0.5),
            Vector3(0, -1, 0.5),
            Vector3(0, 0, -1)
        ]
        let box2 = BoundingBox.fromPoints(points: points)

        let sphere = BoundingSphere(Vector3(0, 0, 0), 1)
        let box3 = BoundingBox.fromSphere(sphere: sphere)

        let min1 = box1.min
        let max1 = box1.max

        let min2 = box2.min
        let max2 = box2.max

        let min3 = box3.min
        let max3 = box3.max

        XCTAssertEqual(Vector3.equals(left: min1, right: min2), true)
        XCTAssertEqual(Vector3.equals(left: max1, right: max2), true)
        XCTAssertEqual(Vector3.equals(left: min1, right: min3), true)
        XCTAssertEqual(Vector3.equals(left: max1, right: max3), true)
        XCTAssertEqual(Vector3.equals(left: min2, right: min3), true)
        XCTAssertEqual(Vector3.equals(left: max2, right: max3), true)
    }

    func testTransform() {
        var box = BoundingBox(Vector3(-1, -1, -1), Vector3(1, 1, 1))
        let matrix = Matrix(m11: 2, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 2, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 2, m34: 0,
                m41: 1, m42: 0.5, m43: -1, m44: 1)
        let newBox = BoundingBox.transform(source: box, matrix: matrix)
        _ = box.transform(matrix: matrix)

        let newMin = Vector3(-1, -1.5, -3)
        let newMax = Vector3(3, 2.5, 1)
        XCTAssertEqual(Vector3.equals(left: newBox.min, right: newMin), true)
        XCTAssertEqual(Vector3.equals(left: newBox.max, right: newMax), true)
        XCTAssertEqual(Vector3.equals(left: box.min, right: newMin), true)
        XCTAssertEqual(Vector3.equals(left: box.max, right: newMax), true)
    }

    func testMerge() {
        let box1 = BoundingBox(Vector3(-1, -1, -1), Vector3(2, 2, 2))
        let box2 = BoundingBox(Vector3(-2, -0.5, -2), Vector3(3, 0, 3))
        let box = BoundingBox.merge(box1: box1, box2: box2)
        XCTAssertEqual(Vector3.equals(left: Vector3(-2, -1, -2), right: box.min), true)
        XCTAssertEqual(Vector3.equals(left: Vector3(3, 2, 3), right: box.max), true)
    }

    func testGetCenter() {
        let box = BoundingBox(Vector3(-1, -1, -1), Vector3(3, 3, 3))
        let center = box.getCenter()
        XCTAssertEqual(Vector3.equals(left: Vector3(1, 1, 1), right: center), true)
    }

    func testGetExtent() {
        let box = BoundingBox(Vector3(-1, -1, -1), Vector3(3, 3, 3))
        let extent = box.getExtent()
        XCTAssertEqual(Vector3.equals(left: Vector3(2, 2, 2), right: extent), true)
    }

    func testGetCorners() {
        let min = Vector3(-1, -1, -1)
        let max = Vector3(3, 3, 3)
        let minX = min.x
        let minY = min.y
        let minZ = min.z
        let maxX = max.x
        let maxY = max.y
        let maxZ = max.z
        var expectedCorners = [
            Vector3(),
            Vector3(),
            Vector3(),
            Vector3(),
            Vector3(),
            Vector3(),
            Vector3(),
            Vector3()
        ]
        _ = expectedCorners[0].set(x: minX, y: maxY, z: maxZ)
        _ = expectedCorners[1].set(x: maxX, y: maxY, z: maxZ)
        _ = expectedCorners[2].set(x: maxX, y: minY, z: maxZ)
        _ = expectedCorners[3].set(x: minX, y: minY, z: maxZ)
        _ = expectedCorners[4].set(x: minX, y: maxY, z: minZ)
        _ = expectedCorners[5].set(x: maxX, y: maxY, z: minZ)
        _ = expectedCorners[6].set(x: maxX, y: minY, z: minZ)
        _ = expectedCorners[7].set(x: minX, y: minY, z: minZ)

        let box = BoundingBox(min, max)
        let corners = box.getCorners()
        for i in 0..<8 {
            XCTAssertEqual(Vector3.equals(left: corners[i], right: expectedCorners[i]), true)
        }
    }

    func testClone() {
        let a = BoundingBox(Vector3(0, 0, 0), Vector3(1, 1, 1))
        let b = a
        XCTAssertEqual(Vector3.equals(left: a.min, right: b.min), true)
        XCTAssertEqual(Vector3.equals(left: a.max, right: b.max), true)
    }

    func testCloneTo() {
        let a = BoundingBox(Vector3(0, 0, 0), Vector3(1, 1, 1))
        let out = a
        XCTAssertEqual(Vector3.equals(left: a.min, right: out.min), true)
        XCTAssertEqual(Vector3.equals(left: a.max, right: out.max), true)
    }
}
