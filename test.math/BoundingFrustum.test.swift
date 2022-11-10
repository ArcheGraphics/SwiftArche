//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class BoundingFrustumTests: XCTestCase {
    var projectionMatrix: Matrix!
    var vpMatrix: Matrix!
    var frustum: BoundingFrustum!

    override func setUpWithError() throws {
        let viewMatrix = Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: -20, m44: 1)
        projectionMatrix = Matrix(
                m11: 0.03954802080988884, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 0.10000000149011612, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: -0.0200200192630291, m34: 0,
                m41: -0, m42: -0, m43: -1.0020020008087158, m44: 1
        )
        vpMatrix = projectionMatrix * viewMatrix
        frustum = BoundingFrustum(matrix: vpMatrix)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIntersectsBox() {
        let box1 = BoundingBox(Vector3(-2, -2, -2), Vector3(2, 2, 2))
        let flag1 = frustum.intersectsBox(box: box1)
        XCTAssertEqual(flag1, true)

        let box2 = BoundingBox(Vector3(-32, -2, -2), Vector3(-28, 2, 2))
        let flag2 = frustum.intersectsBox(box: box2)
        XCTAssertEqual(flag2, false)
    }

    func testIntersectsSphere() {
        let box1 = BoundingBox(Vector3(-2, -2, -2), Vector3(2, 2, 2))
        let sphere1 = BoundingSphere.fromBox(box: box1)
        let flag1 = frustum.intersectsSphere(sphere: sphere1)
        XCTAssertEqual(flag1, true)

        let box2 = BoundingBox(Vector3(-32, -2, -2), Vector3(-28, 2, 2))
        let sphere2 = BoundingSphere.fromBox(box: box2)
        let flag2 = frustum.intersectsSphere(sphere: sphere2)
        XCTAssertEqual(flag2, false)
    }

    func testClone() {
        let a = BoundingFrustum(matrix: projectionMatrix)
        let b = a

        for i in 0..<6 {
            let aPlane = a.getPlane(index: i)
            let bPlane = b.getPlane(index: i)

            XCTAssertEqual(aPlane.distance, bPlane.distance)
            XCTAssertEqual(Vector3.equals(left: aPlane.normal, right: bPlane.normal), true)
        }
    }

    func testCloneTo() {
        let a = BoundingFrustum(matrix: projectionMatrix)
        let out = a

        for i in 0..<6 {
            let aPlane = a.getPlane(index: i)
            let outPlane = out.getPlane(index: i)

            XCTAssertEqual(aPlane.distance, outPlane.distance)
            XCTAssertEqual(Vector3.equals(left: aPlane.normal, right: outPlane.normal), true)
        }
    }

    func testCalculateFromMatrix() {
        var a = BoundingFrustum()
        a.calculateFromMatrix(matrix: vpMatrix)

        for i in 0..<6 {
            let aPlane = a.getPlane(index: i)
            let bPlane = frustum.getPlane(index: i)

            XCTAssertEqual(aPlane.distance, bPlane.distance)
            XCTAssertEqual(Vector3.equals(left: aPlane.normal, right: bPlane.normal), true)
        }
    }
}
