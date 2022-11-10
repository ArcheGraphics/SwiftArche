//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class CollisionUtilTests: XCTestCase {
    var plane: Plane!
    var frustum: BoundingFrustum!

    override func setUpWithError() throws {
        plane = Plane(Vector3(0, 1, 0), -5)
        let viewMatrix = Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 1, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: 1, m34: 0,
                m41: 0, m42: 0, m43: -20, m44: 1)
        let projectionMatrix = Matrix(m11: 0.03954802080988884, m12: 0, m13: 0, m14: 0,
                m21: 0, m22: 0.10000000149011612, m23: 0, m24: 0,
                m31: 0, m32: 0, m33: -0.0200200192630291, m34: 0,
                m41: -0, m42: -0, m43: -1.0020020008087158, m44: 1)
        let vpMatrix = projectionMatrix * viewMatrix
        frustum = BoundingFrustum(matrix: vpMatrix)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDistancePlaneAndPoint() {
        let point = Vector3(0, 10, 0)

        let distance = CollisionUtil.distancePlaneAndPoint(plane: plane, point: point)
        XCTAssertEqual(distance, 5)
    }

    func testIntersectsPlaneAndPoint() {
        let point1 = Vector3(0, 10, 0)
        let point2 = Vector3(2, 5, -9)
        let point3 = Vector3(0, 3, 0)

        let intersection1 = CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: point1)
        let intersection2 = CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: point2)
        let intersection3 = CollisionUtil.intersectsPlaneAndPoint(plane: plane, point: point3)
        XCTAssertEqual(intersection1, PlaneIntersectionType.Front)
        XCTAssertEqual(intersection2, PlaneIntersectionType.Intersecting)
        XCTAssertEqual(intersection3, PlaneIntersectionType.Back)
    }

    func testIntersectsPlaneAndBox() {
        let box1 = BoundingBox(Vector3(-1, 6, -2), Vector3(1, 10, 3))
        let box2 = BoundingBox(Vector3(-1, 5, -2), Vector3(1, 10, 3))
        let box3 = BoundingBox(Vector3(-1, 4, -2), Vector3(1, 5, 3))
        let box4 = BoundingBox(Vector3(-1, -5, -2), Vector3(1, 4.9, 3))

        let intersection1 = CollisionUtil.intersectsPlaneAndBox(plane: plane, box: box1)
        let intersection2 = CollisionUtil.intersectsPlaneAndBox(plane: plane, box: box2)
        let intersection3 = CollisionUtil.intersectsPlaneAndBox(plane: plane, box: box3)
        let intersection4 = CollisionUtil.intersectsPlaneAndBox(plane: plane, box: box4)
        XCTAssertEqual(intersection1, PlaneIntersectionType.Front)
        XCTAssertEqual(intersection2, PlaneIntersectionType.Intersecting)
        XCTAssertEqual(intersection3, PlaneIntersectionType.Intersecting)
        XCTAssertEqual(intersection4, PlaneIntersectionType.Back)
    }

    func testIntersectsPlaneAndSphere() {
        let sphere1 = BoundingSphere(Vector3(0, 8, 0), 2)
        let sphere2 = BoundingSphere(Vector3(0, 8, 0), 3)
        let sphere3 = BoundingSphere(Vector3(0, 3, 0), 2)
        let sphere4 = BoundingSphere(Vector3(0, 0, 0), 2)

        let intersection1 = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere1)
        let intersection2 = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere2)
        let intersection3 = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere3)
        let intersection4 = CollisionUtil.intersectsPlaneAndSphere(plane: plane, sphere: sphere4)
        XCTAssertEqual(intersection1, PlaneIntersectionType.Front)
        XCTAssertEqual(intersection2, PlaneIntersectionType.Intersecting)
        XCTAssertEqual(intersection3, PlaneIntersectionType.Intersecting)
        XCTAssertEqual(intersection4, PlaneIntersectionType.Back)
    }

    func testIntersectsRayAndPlane() {
        let ray1 = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let ray2 = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, -1, 0))

        let distance1 = CollisionUtil.intersectsRayAndPlane(ray: ray1, plane: plane)
        let distance2 = CollisionUtil.intersectsRayAndPlane(ray: ray2, plane: plane)
        XCTAssertEqual(distance1, 5)
        XCTAssertEqual(distance2, -1)
    }

    func testIntersectsRayAndBox() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let box1 = BoundingBox(Vector3(-1, 3, -1), Vector3(2, 8, 3))
        let box2 = BoundingBox(Vector3(1, 1, 1), Vector3(2, 2, 2))

        let distance1 = CollisionUtil.intersectsRayAndBox(ray: ray, box: box1)
        let distance2 = CollisionUtil.intersectsRayAndBox(ray: ray, box: box2)
        XCTAssertEqual(distance1, 3)
        XCTAssertEqual(distance2, -1)
    }

    func testIntersectsRayAndSphere() {
        let ray = Ray(origin: Vector3(0, 0, 0), direction: Vector3(0, 1, 0))
        let sphere1 = BoundingSphere(Vector3(0, 4, 0), 3)
        let sphere2 = BoundingSphere(Vector3(0, -5, 0), 4)

        let distance1 = CollisionUtil.intersectsRayAndSphere(ray: ray, sphere: sphere1)
        let distance2 = CollisionUtil.intersectsRayAndSphere(ray: ray, sphere: sphere2)
        XCTAssertEqual(distance1, 1)
        XCTAssertEqual(distance2, -1)
    }

    func testIntersectsFrustumAndBox() {
        let box1 = BoundingBox(Vector3(-2, -2, -2), Vector3(2, 2, 2))
        let flag1 = frustum.intersectsBox(box: box1)
        XCTAssertEqual(flag1, true)

        let box2 = BoundingBox(Vector3(-32, -2, -2), Vector3(-28, 2, 2))
        let flag2 = frustum.intersectsBox(box: box2)
        XCTAssertEqual(flag2, false)
    }

    func testFrustumContainsBox() {
        let box1 = BoundingBox(Vector3(-2, -2, -2), Vector3(2, 2, 2))
        let box2 = BoundingBox(Vector3(-32, -2, -2), Vector3(-28, 2, 2))
        let box3 = BoundingBox(Vector3(-35, -2, -2), Vector3(-18, 2, 2))

        let expected1 = CollisionUtil.frustumContainsBox(frustum: frustum, box: box1)
        let expected2 = CollisionUtil.frustumContainsBox(frustum: frustum, box: box2)
        let expected3 = CollisionUtil.frustumContainsBox(frustum: frustum, box: box3)
        XCTAssertEqual(expected1, ContainmentType.Contains)
        XCTAssertEqual(expected2, ContainmentType.Disjoint)
        XCTAssertEqual(expected3, ContainmentType.Intersects)
    }

    func testFrustumContainsSphere() {
        let sphere1 = BoundingSphere(Vector3(0, 0, 0), 2)
        let sphere2 = BoundingSphere(Vector3(-32, -2, -2), 1)
        let sphere3 = BoundingSphere(Vector3(-32, -2, -2), 15)

        let expected1 = CollisionUtil.frustumContainsSphere(frustum: frustum, sphere: sphere1)
        let expected2 = CollisionUtil.frustumContainsSphere(frustum: frustum, sphere: sphere2)
        let expected3 = CollisionUtil.frustumContainsSphere(frustum: frustum, sphere: sphere3)
        XCTAssertEqual(expected1, ContainmentType.Contains)
        XCTAssertEqual(expected2, ContainmentType.Disjoint)
        XCTAssertEqual(expected3, ContainmentType.Intersects)
    }
}
