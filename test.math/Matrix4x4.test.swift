//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
@testable import vox_math

class MatrixTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStaticMultiply() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = Matrix(m11: 16, m12: 15, m13: 14, m14: 13,
                m21: 12, m22: 11, m23: 10, m24: 9,
                m31: 8.88, m32: 7, m33: 6, m34: 5,
                m41: 4, m42: 3, m43: 2, m44: 1)
        let out = a * b

        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 386, m12: 456.599976, m13: 506.799988, m14: 560,
                        m21: 274, m22: 325, m23: 361.600006, m24: 400,
                        m31: 162.880005, m32: 195.1600004, m33: 219.304001, m34: 243.520004,
                        m41: 50, m42: 61.7999992, m43: 71.1999969, m44: 80)
        ), true)
    }

    func testStaticEquals() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let c = Matrix(m11: 16, m12: 15, m13: 14, m14: 13,
                m21: 12, m22: 11, m23: 10, m24: 9,
                m31: 8.88, m32: 7, m33: 6, m34: 5,
                m41: 4, m42: 3, m43: 2, m44: 1)

        XCTAssertEqual(Matrix.equals(left: a, right: b), true)
        XCTAssertEqual(Matrix.equals(left: a, right: c), false)
    }

    func testStaticLerp() {
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let c = Matrix.lerp(start: a, end: b, t: 0.7)

        XCTAssertEqual(Matrix.equals(left: a, right: c), true)
        XCTAssertEqual(Matrix.equals(left: b, right: c), true)
    }

    func testStaticRotationQuaternion() {
        let q = Quaternion(1, 2, 3, 4)
        let out = Matrix.rotationQuaternion(quaternion: q)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -25, m12: 28, m13: -10, m14: 0,
                        m21: -20, m22: -19, m23: 20, m24: 0,
                        m31: 22, m32: 4, m33: -9, m34: 0,
                        m41: 0, m42: 0, m43: 0, m44: 1)), true)
    }

    func testStaticRotationAxisAngle() {
        let out = Matrix.rotationAxisAngle(axis: Vector3(0, 1, 0), r: Float.pi / 3)
        XCTAssertEqual(
                Matrix.equals(
                        left: out, right: Matrix(
                        m11: 0.5000000000000001, m12: 0, m13: -0.8660254037844386, m14: 0,
                        m21: 0, m22: 1, m23: 0, m24: 0,
                        m31: 0.8660254037844386, m32: 0, m33: 0.5000000000000001, m34: 0,
                        m41: 0, m42: 0, m43: 0, m44: 1
                )
                ), true)
    }

    func testStaticRotationTranslation() {
        let q = Quaternion(1, 0.5, 2, 1)
        let v = Vector3(1, 1, 1)
        let out = Matrix.rotationTranslation(quaternion: q, translation: v)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -7.5, m12: 5, m13: 3, m14: 0,
                        m21: -3, m22: -9, m23: 4, m24: 0,
                        m31: 5, m32: 0, m33: -1.5, m34: 0,
                        m41: 1, m42: 1, m43: 1, m44: 1)), true)
    }

    func testStaticAffineTransformation() {
        let q = Quaternion(1, 0.5, 2, 1)
        let v = Vector3(1, 1, 1)
        let s = Vector3(1, 0.5, 2)
        let out = Matrix.affineTransformation(scale: s, rotation: q, translation: v)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -7.5, m12: 5, m13: 3, m14: 0,
                        m21: -1.5, m22: -4.5, m23: 2, m24: 0,
                        m31: 10, m32: 0, m33: -3, m34: 0,
                        m41: 1, m42: 1, m43: 1, m44: 1)), true)
    }

    func testStaticScaling() {
        let a = Matrix()
        let out = Matrix.scale(m: a, s: Vector3(1, 2, 0.5))
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 2, m23: 0, m24: 0,
                        m31: 0, m32: 0, m33: 0.5, m34: 0,
                        m41: 0, m42: 0, m43: 0, m44: 1)), true)
    }

    func testStaticTranslation() {
        let v = Vector3(1, 2, 0.5)

        let out = Matrix.translation(translation: v)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 1, m23: 0, m24: 0,
                        m31: 0, m32: 0, m33: 1, m34: 0,
                        m41: 1, m42: 2, m43: 0.5, m44: 1)), true)
    }

    func testStaticInvert() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4, m21: 5, m22: 6, m23: 7, m24: 8, m31: 9, m32: 10.9, m33: 11, m34: 12, m41: 13, m42: 14, m43: 15, m44: 16)
        let out = Matrix.invert(a: a)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -1.11118591, m12: 1.37044585, m13: -0.740784704, m14: 0.148155302,
                        m21: -0, m22: -0.555588245, m23: 1.11117172, m24: -0.555585861,
                        m31: 3.33351779, m32: -5.00028944, m33: -0, m34: 1.66676235,
                        m41: -2.22234392, m42: 4.06041765, m43: -0.370390594, m44: -1.13432443)), true)
    }

    func testStaticLookAt() {
        var eye = Vector3(0, 0, -8)
        var target = Vector3(0, 0, 0)
        var up = Vector3(0, 1, 0)

        var out = Matrix.lookAt(eye: eye, target: target, up: up)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -1, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 1, m23: 0, m24: 0,
                        m31: 0, m32: 0, m33: -1, m34: 0,
                        m41: 0, m42: 0, m43: -8, m44: 1)), true)

        _ = eye.setValue(x: 0, y: 0, z: 0)
        _ = target.setValue(x: 0, y: 1, z: -1)
        _ = up.setValue(x: 0, y: 1, z: 0)
        out = Matrix.lookAt(eye: eye, target: target, up: up)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 0.7071067690849304, m23: -0.7071067690849304, m24: 0,
                        m31: 0, m32: 0.7071067690849304, m33: 0.7071067690849304, m34: 0,
                        m41: 0, m42: 0, m43: 0, m44: 1)), true)
    }

    func testStaticOrtho() {
        let out = Matrix.ortho(left: 0, right: 2, bottom: -1, top: 1, near: 0.1, far: 100)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 1, m23: 0, m24: 0,
                        m31: 0, m32: 0, m33: -0.02002002002002002, m34: 0,
                        m41: -1, m42: 0, m43: -1.002002002002002, m44: 1)
        ), true)
    }

    func testStaticPerspective() {
        let out = Matrix.perspective(fovy: 1, aspect: 1.5, near: 0.1, far: 100)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1.2203251478083013, m12: 0, m13: 0, m14: 0,
                        m21: 0, m22: 1.830487721712452, m23: 0, m24: 0,
                        m31: 0, m32: 0, m33: -1.002002002002002, m34: -1,
                        m41: 0, m42: 0, m43: -0.20020020020020018, m44: 0
                )
        ), true)
    }

    func testStaticRotateAxisAngle() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let out = Matrix.rotateAxisAngle(m: a, axis: Vector3(0, 1, 0), r: Float.pi / 3)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: -7.294228634059947, m12: -8.439676901250381, m13: -7.876279441628824, m14: -8.392304845413264,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 5.366025403784439, m32: 7.182050807568878, m33: 8.357883832488648, m34: 9.464101615137757,
                        m41: 13, m42: 14, m43: 15, m44: 16
                )
        ), true)
    }

    func testStaticScale() {
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let out = Matrix.scale(m: a, s: Vector3(1, 2, 0.5))
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                        m21: 10, m22: 12, m23: 14, m24: 16,
                        m31: 4.5, m32: 5, m33: 5.5, m34: 6,
                        m41: 13, m42: 14, m43: 15, m44: 16)), true)
    }

    func testStaticTranslate() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let out = Matrix.translate(m: a, v: Vector3(1, 2, 0.5))
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 9, m32: 10.9, m33: 11, m34: 12,
                        m41: 28.5, m42: 33.45, m43: 37.8, m44: 42)), true)
    }

    func testStaticTranspose() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let out = Matrix.transpose(a: a)
        XCTAssertEqual(Matrix.equals(left: out,
                right: Matrix(m11: 1, m12: 5, m13: 9, m14: 13,
                        m21: 2, m22: 6, m23: 10.9, m24: 14,
                        m31: 3.3, m32: 7, m33: 11, m34: 15,
                        m41: 4, m42: 8, m43: 12, m44: 16)), true)
    }

    func testSetValue() {
        var a = Matrix()
        _ = a.setValue(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 9, m32: 10.9, m33: 11, m34: 12,
                        m41: 13, m42: 14, m43: 15, m44: 16)), true)
    }

    func testSetValueByArray() {
        var a = Matrix()
        _ = a.setValueByArray(array: [1, 2, 3.3, 4, 5, 6, 7, 8, 9, 10.9, 11, 12, 13, 14, 15, 16])

        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 9, m32: 10.9, m33: 11, m34: 12,
                        m41: 13, m42: 14, m43: 15, m44: 16)), true)
    }

    func testToArray() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4, m21: 5, m22: 6, m23: 7, m24: 8, m31: 9, m32: 10.9, m33: 11, m34: 12, m41: 13, m42: 14, m43: 15, m44: 16)
        var b = [Float](repeating: 0, count: 16)
        a.toArray(out: &b)
        var c = Matrix()
        _ = c.setValueByArray(array: b)

        XCTAssertEqual(Matrix.equals(left: a, right: c), true)
    }

    func testClone() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = a

        XCTAssertEqual(Matrix.equals(left: a, right: b), true)
    }

    func testCloneTo() {
        let a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let out = a

        XCTAssertEqual(Matrix.equals(left: a, right: out), true)
    }

    func testMultiply() {
        var a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        let b = Matrix(m11: 16, m12: 15, m13: 14, m14: 13,
                m21: 12, m22: 11, m23: 10, m24: 9,
                m31: 8.88, m32: 7, m33: 6, m34: 5,
                m41: 4, m42: 3, m43: 2, m44: 1)

        _ = a.multiply(right: b)
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 386, m12: 456.599976, m13: 506.799988, m14: 560,
                        m21: 274, m22: 325, m23: 361.600006, m24: 400,
                        m31: 162.880005, m32: 195.160004, m33: 219.304001, m34: 243.520004,
                        m41: 50, m42: 61.7999992, m43: 71.1999969, m44: 80)), true)
    }

    func testDeterminant() {
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        XCTAssertEqual(a.determinant(), 0, accuracy: 1.0e-4)
    }

    func testDecompose() {
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)
        // const a = new Matrix(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
        var pos = Vector3()
        var quat = Quaternion()
        var scale = Vector3()

        _ = a.decompose(translation: &pos, rotation: &quat, scale: &scale)
        XCTAssertEqual(Vector3.equals(left: pos, right: Vector3(13, 14, 15)), true)
        XCTAssertEqual(
                Quaternion.equals(
                        left: quat,
                        right: Quaternion(1.879038e-02, -9.554128e-02, 1.844761e-02, 7.831795e-01)
                ), true)
        XCTAssertEqual(Vector3.equals(left: scale, right: Vector3(3.7416573867739413, 10.488088481701515, 17.91116946723357)), true)
    }

    func testGetXXX() {
        let a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        // getRotation
        let quat = a.getRotation()
        XCTAssertEqual(
                Quaternion.equals(
                        left: quat,
                        right: Quaternion(-0.44736068104759547, 0.6882472016116852, -0.3441236008058426, 2.179449471770337)
                ), true)

        // getScaling
        let scale = a.getScaling()
        XCTAssertEqual(Vector3.equals(left: scale, right: Vector3(3.7416573867739413, 10.488088481701515, 17.911169699380327)), true)

        // getTranslation
        let translation = a.getTranslation()
        XCTAssertEqual(Vector3.equals(left: translation, right: Vector3(13, 14, 15)), true)
    }

    func testInvert() {
        var a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        _ = a.invert()
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: -1.11118591, m12: 1.37044585, m13: -0.740784704, m14: 0.148155302,
                        m21: -0, m22: -0.555588245, m23: 1.11117172, m24: -0.555585861,
                        m31: 3.33351779, m32: -5.00028944, m33: -0, m34: 1.66676235,
                        m41: -2.22234392, m42: 4.06041765, m43: -0.370390594, m44: -1.13432443)), true)
    }

    func testRotateAxisAngle() {
        var a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        _ = a.rotateAxisAngle(axis: Vector3(0, 1, 0), r: Float.pi / 3)
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: -7.294228634059947, m12: -8.439676901250381, m13: -7.876279441628824, m14: -8.392304845413264,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 5.366025403784439, m32: 7.182050807568878, m33: 8.357883832488648, m34: 9.464101615137757,
                        m41: 13, m42: 14, m43: 15, m44: 16)), true)
    }

    func testScale() {
        var a = Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        _ = a.scale(s: Vector3(1, 2, 0.5))
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 1, m12: 2, m13: 3, m14: 4,
                        m21: 10, m22: 12, m23: 14, m24: 16,
                        m31: 4.5, m32: 5, m33: 5.5, m34: 6,
                        m41: 13, m42: 14, m43: 15, m44: 16)), true)
    }

    func testTranslate() {
        var a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        _ = a.translate(v: Vector3(1, 2, 0.5))
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                        m21: 5, m22: 6, m23: 7, m24: 8,
                        m31: 9, m32: 10.9, m33: 11, m34: 12,
                        m41: 28.5, m42: 33.45, m43: 37.8, m44: 42)), true)
    }

    func testTranspose() {
        var a = Matrix(m11: 1, m12: 2, m13: 3.3, m14: 4,
                m21: 5, m22: 6, m23: 7, m24: 8,
                m31: 9, m32: 10.9, m33: 11, m34: 12,
                m41: 13, m42: 14, m43: 15, m44: 16)

        _ = a.transpose()
        XCTAssertEqual(Matrix.equals(left: a,
                right: Matrix(m11: 1, m12: 5, m13: 9, m14: 13,
                        m21: 2, m22: 6, m23: 10.9, m24: 14,
                        m31: 3.3, m32: 7, m33: 11, m34: 15,
                        m41: 4, m42: 8, m43: 12, m44: 16)), true)
    }
}
