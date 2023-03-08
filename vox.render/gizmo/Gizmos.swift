//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class Gizmos {
    static let gCapsuleVertices: [Vector3] = [
        Vector3(0.0000, -2.0000, -0.0000),
        Vector3(0.3827, -1.9239, -0.0000),
        Vector3(0.2706, -1.9239, 0.2706),
        Vector3(-0.0000, -1.9239, 0.3827),
        Vector3(-0.2706, -1.9239, 0.2706),
        Vector3(-0.3827, -1.9239, -0.0000),
        Vector3(-0.2706, -1.9239, -0.2706),
        Vector3(0.0000, -1.9239, -0.3827),
        Vector3(0.2706, -1.9239, -0.2706),
        Vector3(0.7071, -1.7071, -0.0000),
        Vector3(0.5000, -1.7071, 0.5000),
        Vector3(-0.0000, -1.7071, 0.7071),
        Vector3(-0.5000, -1.7071, 0.5000),
        Vector3(-0.7071, -1.7071, -0.0000),
        Vector3(-0.5000, -1.7071, -0.5000),
        Vector3(0.0000, -1.7071, -0.7071),
        Vector3(0.5000, -1.7071, -0.5000),
        Vector3(0.9239, -1.3827, -0.0000),
        Vector3(0.6533, -1.3827, 0.6533),
        Vector3(-0.0000, -1.3827, 0.9239),
        Vector3(-0.6533, -1.3827, 0.6533),
        Vector3(-0.9239, -1.3827, -0.0000),
        Vector3(-0.6533, -1.3827, -0.6533),
        Vector3(0.0000, -1.3827, -0.9239),
        Vector3(0.6533, -1.3827, -0.6533),
        Vector3(1.0000, -1.0000, -0.0000),
        Vector3(0.7071, -1.0000, 0.7071),
        Vector3(-0.0000, -1.0000, 1.0000),
        Vector3(-0.7071, -1.0000, 0.7071),
        Vector3(-1.0000, -1.0000, -0.0000),
        Vector3(-0.7071, -1.0000, -0.7071),
        Vector3(0.0000, -1.0000, -1.0000),
        Vector3(0.7071, -1.0000, -0.7071),
        Vector3(1.0000, 1.0000, 0.0000),
        Vector3(0.7071, 1.0000, 0.7071),
        Vector3(-0.0000, 1.0000, 1.0000),
        Vector3(-0.7071, 1.0000, 0.7071),
        Vector3(-1.0000, 1.0000, -0.0000),
        Vector3(-0.7071, 1.0000, -0.7071),
        Vector3(0.0000, 1.0000, -1.0000),
        Vector3(0.7071, 1.0000, -0.7071),
        Vector3(0.9239, 1.3827, 0.0000),
        Vector3(0.6533, 1.3827, 0.6533),
        Vector3(-0.0000, 1.3827, 0.9239),
        Vector3(-0.6533, 1.3827, 0.6533),
        Vector3(-0.9239, 1.3827, -0.0000),
        Vector3(-0.6533, 1.3827, -0.6533),
        Vector3(0.0000, 1.3827, -0.9239),
        Vector3(0.6533, 1.3827, -0.6533),
        Vector3(0.7071, 1.7071, 0.0000),
        Vector3(0.5000, 1.7071, 0.5000),
        Vector3(-0.0000, 1.7071, 0.7071),
        Vector3(-0.5000, 1.7071, 0.5000),
        Vector3(-0.7071, 1.7071, 0.0000),
        Vector3(-0.5000, 1.7071, -0.5000),
        Vector3(0.0000, 1.7071, -0.7071),
        Vector3(0.5000, 1.7071, -0.5000),
        Vector3(0.3827, 1.9239, 0.0000),
        Vector3(0.2706, 1.9239, 0.2706),
        Vector3(-0.0000, 1.9239, 0.3827),
        Vector3(-0.2706, 1.9239, 0.2706),
        Vector3(-0.3827, 1.9239, 0.0000),
        Vector3(-0.2706, 1.9239, -0.2706),
        Vector3(0.0000, 1.9239, -0.3827),
        Vector3(0.2706, 1.9239, -0.2706),
        Vector3(0.0000, 2.0000, 0.0000),
    ]

    static let gCapsuleIndices: [Int] = [
        1, 0, 2, 2, 0, 3, 3, 0, 4, 4, 0, 5, 5, 0, 6, 6, 0, 7, 7, 0, 8,
        8, 0, 1, 9, 1, 10, 10, 1, 2, 10, 2, 11, 11, 2, 3, 11, 3, 12,
        12, 3, 4, 12, 4, 13, 13, 4, 5, 13, 5, 14, 14, 5, 6, 14, 6, 15,
        15, 6, 7, 15, 7, 16, 16, 7, 8, 16, 8, 9, 9, 8, 1, 17, 9, 18,
        18, 9, 10, 18, 10, 19, 19, 10, 11, 19, 11, 20, 20, 11, 12, 20, 12, 21,
        21, 12, 13, 21, 13, 22, 22, 13, 14, 22, 14, 23, 23, 14, 15, 23, 15, 24,
        24, 15, 16, 24, 16, 17, 17, 16, 9, 25, 17, 26, 26, 17, 18, 26, 18, 27,
        27, 18, 19, 27, 19, 28, 28, 19, 20, 28, 20, 29, 29, 20, 21, 29, 21, 30,
        30, 21, 22, 30, 22, 31, 31, 22, 23, 31, 23, 32, 32, 23, 24, 32, 24, 25,
        25, 24, 17, 33, 25, 34, 34, 25, 26, 34, 26, 35, 35, 26, 27, 35, 27, 36,
        36, 27, 28, 36, 28, 37, 37, 28, 29, 37, 29, 38, 38, 29, 30, 38, 30, 39,
        39, 30, 31, 39, 31, 40, 40, 31, 32, 40, 32, 33, 33, 32, 25, 41, 33, 42,
        42, 33, 34, 42, 34, 43, 43, 34, 35, 43, 35, 44, 44, 35, 36, 44, 36, 45,
        45, 36, 37, 45, 37, 46, 46, 37, 38, 46, 38, 47, 47, 38, 39, 47, 39, 48,
        48, 39, 40, 48, 40, 41, 41, 40, 33, 49, 41, 50, 50, 41, 42, 50, 42, 51,
        51, 42, 43, 51, 43, 52, 52, 43, 44, 52, 44, 53, 53, 44, 45, 53, 45, 54,
        54, 45, 46, 54, 46, 55, 55, 46, 47, 55, 47, 56, 56, 47, 48, 56, 48, 49,
        49, 48, 41, 57, 49, 58, 58, 49, 50, 58, 50, 59, 59, 50, 51, 59, 51, 60,
        60, 51, 52, 60, 52, 61, 61, 52, 53, 61, 53, 62, 62, 53, 54, 62, 54, 63,
        63, 54, 55, 63, 55, 64, 64, 55, 56, 64, 56, 57, 57, 56, 49, 65, 57, 58,
        65, 58, 59, 65, 59, 60, 65, 60, 61, 65, 61, 62, 65, 62, 63, 65, 63, 64,
        65, 64, 57,
    ]
    static let gNumCapsuleIndices = gCapsuleIndices.count
    static let NB_CIRCLE_PTS: Int = 20
    static let MAX_TEMP_VERTEX_BUFFER: Int = 400

// MARK: - API
    public struct RenderFlag: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let Wireframe = RenderFlag(rawValue: 0 << 0)
        public static let Solid = RenderFlag(rawValue: 1 << 0)
        public static let Default: RenderFlag = [Wireframe]
    }

    public static var pointSize: Float {
        get {
            PointSubpass.ins.pointSize
        }
        set {
            PointSubpass.ins.pointSize = newValue
        }
    }

    public static func addPoint(_ p0: Vector3, color: Color32) {
        PointSubpass.ins.addPoint(p0, color: color)
    }

    public static func addLine(p0: Vector3, p1: Vector3, color: Color32) {
        LineSubpass.ins.addLine(p0: p0, p1: p1, color: color)
    }

    public static func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3,
                                   n0: Vector3, n1: Vector3, n2: Vector3, color: Color32) {
        TriangleSubpass.ins.addTriangle(p0: p0, p1: p1, p2: p2,
                n0: n0, n1: n1, n2: n2, color: color)
    }

    public static func addTriangle(p0: Vector3, p1: Vector3, p2: Vector3, color: Color32) {
        TriangleSubpass.ins.addTriangle(p0: p0, p1: p1, p2: p2, color: color)
    }

    public static func addArrow(posA: Vector3, posB: Vector3, color: Color32) {
        let t0 = (posB - posA).normalized()
        let a = abs(t0.x) < 0.707 ? Vector3(1, 0, 0) : Vector3(0, 1, 0)
        let t1 = Vector3.cross(left: t0, right: a).normalized()
        let t2 = Vector3.cross(left: t0, right: t1).normalized()

        addLine(p0: posA, p1: posB, color: color)
        addLine(p0: posB, p1: posB - t0 * 0.15 + t1 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0 * 0.15 - t1 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0 * 0.15 + t2 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0 * 0.15 - t2 * 0.15, color: color)
    }

    public static func addStar(p: Vector3, size: Float, color: Color32) {
        let up = Vector3(0.0, size, 0.0)
        let right = Vector3(size, 0.0, 0.0)
        let forwards = Vector3(0.0, 0.0, size)
        addLine(p0: p + up, p1: p - up, color: color)
        addLine(p0: p + right, p1: p - right, color: color)
        addLine(p0: p + forwards, p1: p - forwards, color: color)
    }

    public static func addAABB(box: BoundingBox, color: Color32, renderFlags: RenderFlag) {
        let min = box.min
        let max = box.max

        //     7+------+6            0 = ---
        //     /|     /|            1 = +--
        //    / |    / |            2 = ++-
        //   / 4+---/--+5            3 = -+-
        // 3+------+2 /    y   z    4 = --+
        //  | /    | /     |  /        5 = +-+
        //  |/     |/      |/        6 = +++
        // 0+------+1      *---x    7 = -++

        // Generate 8 corners of the bbox
        var pts = [Vector3](repeating: Vector3(), count: 8)
        pts[0] = Vector3(min.x, min.y, min.z)
        pts[1] = Vector3(max.x, min.y, min.z)
        pts[2] = Vector3(max.x, max.y, min.z)
        pts[3] = Vector3(min.x, max.y, min.z)
        pts[4] = Vector3(min.x, min.y, max.z)
        pts[5] = Vector3(max.x, min.y, max.z)
        pts[6] = Vector3(max.x, max.y, max.z)
        pts[7] = Vector3(min.x, max.y, max.z)

        addBox(pts: pts, color: color, renderFlags: renderFlags)
    }

    public static func addSphere(sphereCenter: Vector3, sphereRadius: Float, color: Color32, renderFlags: RenderFlag) {
        let nbVerts = NB_CIRCLE_PTS
        var pts = [Vector3](repeating: Vector3(), count: NB_CIRCLE_PTS)

        if renderFlags.contains(.Wireframe) {
            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XY, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)

            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XZ, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)

            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_YZ, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)
        }

        if renderFlags.contains(.Solid) {
            let halfHeight: Float = 0.0
            for i in 0..<gNumCapsuleIndices / 3 {
                let i0 = gCapsuleIndices[i * 3 + 0]
                let i1 = gCapsuleIndices[i * 3 + 1]
                let i2 = gCapsuleIndices[i * 3 + 2]
                var v0 = gCapsuleVertices[i0]
                var v1 = gCapsuleVertices[i1]
                var v2 = gCapsuleVertices[i2]

                fixCapsuleVertex(p: &v0, radius: sphereRadius, halfHeight: halfHeight)
                fixCapsuleVertex(p: &v1, radius: sphereRadius, halfHeight: halfHeight)
                fixCapsuleVertex(p: &v2, radius: sphereRadius, halfHeight: halfHeight)

                addTriangle(p0: v0 + sphereCenter, p1: v1 + sphereCenter, p2: v2 + sphereCenter, color: color)
            }
        }
    }

    public static func addSphereExt(sphereCenter: Vector3, sphereRadius: Float, color: Color32, renderFlags: RenderFlag) {
        if renderFlags.contains(.Wireframe) {
            let nbVerts = NB_CIRCLE_PTS
            var pts = [Vector3](repeating: Vector3(), count: NB_CIRCLE_PTS)

            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XY, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)

            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XZ, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)

            generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_YZ, amplitude: sphereRadius, phase: 0.0)
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: sphereCenter)
        }

        if renderFlags.contains(.Solid) {
            var initDone = false
            var nbVerts: Int = 0
            var verts = [Vector3](repeating: Vector3(), count: MAX_TEMP_VERTEX_BUFFER * 6)
            var normals = [Vector3](repeating: Vector3(), count: MAX_TEMP_VERTEX_BUFFER * 6)

            if (!initDone) {
                generateSphere(nbSeg: 16, nbVerts: &nbVerts, verts: &verts, normals: &normals)
                initDone = true
            }

            var i = 0
            while (i < nbVerts) {
                addTriangle(p0: sphereCenter + sphereRadius * verts[i],
                        p1: sphereCenter + sphereRadius * verts[i + 1],
                        p2: sphereCenter + sphereRadius * verts[i + 2],
                        n0: normals[i], n1: normals[i + 1], n2: normals[i + 2], color: color)
                i += 3
            }
        }
    }

    public static func addCone(radius: Float, height: Float, tr: Matrix, color: Color32, renderFlags: RenderFlag) {
        let nbVerts = NB_CIRCLE_PTS
        var pts = [Vector3](repeating: Vector3(), count: NB_CIRCLE_PTS)
        generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XZ, amplitude: radius, phase: 0.0, transform: tr)

        let tip = Vector3.transformCoordinate(v: Vector3(0.0, height, 0.0), m: tr)

        if renderFlags.contains(.Wireframe) {
            addCircle(nbPts: nbVerts, pts: pts, color: color, offset: Vector3(0))
            for i in 0..<nbVerts {
                addLine(p0: tip, p1: pts[i], color: color)    // side of the cone
                addLine(p0: tr.getTranslation(), p1: pts[i], color: color)    // base disk of the cone
            }
        }

        if renderFlags.contains(.Solid) {
            for i in 0..<nbVerts {
                let j = (i + 1) % nbVerts
                addTriangle(p0: tip, p1: pts[i], p2: pts[j], color: color)
                addTriangle(p0: tr.getTranslation(), p1: pts[i], p2: pts[j], color: color)
            }
        }
    }

    public static func addCylinder(radius: Float, height: Float, tr: Matrix, color: Color32, renderFlags: RenderFlag) {
        let nbVerts = NB_CIRCLE_PTS
        var pts = [Vector3](repeating: Vector3(), count: NB_CIRCLE_PTS)
        generatePolygon(nbVerts: nbVerts, verts: &pts, orientation: .ORIENTATION_XZ, amplitude: radius, phase: 0.0, transform: tr)

        let translate = Vector3.transformCoordinate(v: Vector3(0.0, height, 0.0), m: tr)
        var elements = tr.elements
        elements.columns.3[0] = translate.x
        elements.columns.3[1] = translate.y
        elements.columns.3[2] = translate.z
        let tr2 = Matrix(elements)
        var pts2 = [Vector3](repeating: Vector3(), count: NB_CIRCLE_PTS)
        generatePolygon(nbVerts: nbVerts, verts: &pts2, orientation: .ORIENTATION_XZ, amplitude: radius, phase: 0.0, transform: tr2)

        if renderFlags.contains(.Wireframe) {
            for i in 0..<nbVerts {
                let j = (i + 1) % nbVerts
                addLine(p0: pts[i], p1: pts[j], color: color)        // circle
                addLine(p0: pts2[i], p1: pts2[j], color: color)    // circle
            }

            for i in 0..<nbVerts {
                addLine(p0: pts[i], p1: pts2[i], color: color)    // side
                addLine(p0: tr.getTranslation(), p1: pts[i], color: color)        // disk
                addLine(p0: tr2.getTranslation(), p1: pts2[i], color: color)        // disk
            }
        }

        if renderFlags.contains(.Solid) {
            for i in 0..<nbVerts {
                let j = (i + 1) % nbVerts
                addTriangle(p0: tr.getTranslation(), p1: pts[i], p2: pts[j], color: color)
                addTriangle(p0: tr2.getTranslation(), p1: pts2[i], p2: pts2[j], color: color)
                addTriangle(p0: pts[i], p1: pts[j], p2: pts2[j], color: color)
                addTriangle(p0: pts[i], p1: pts2[j], p2: pts2[i], color: color)
            }
        }
    }

    public static func addCapsule(p0: Vector3, p1: Vector3, radius: Float,
                                  height: Float, tr: Matrix, color: Color32, renderFlags: RenderFlag) {
        addSphere(sphereCenter: p0, sphereRadius: radius, color: color, renderFlags: renderFlags)
        addSphere(sphereCenter: p1, sphereRadius: radius, color: color, renderFlags: renderFlags)
        addCylinder(radius: radius, height: height, tr: tr, color: color, renderFlags: renderFlags)
    }

    public static func addRectangle(width: Float, length: Float, tr: Matrix, color: Color32) {
        let m33 = Matrix3x3.rotationQuaternion(quaternion: tr.getRotation()).elements
        var Axis1 = Vector3(m33.columns.1)
        var Axis2 = Vector3(m33.columns.2)

        Axis1 *= length
        Axis2 *= width

        var pts = [Vector3](repeating: Vector3(), count: 4)
        pts[0] = tr.getTranslation() + Axis1 + Axis2
        pts[1] = tr.getTranslation() - Axis1 + Axis2
        pts[2] = tr.getTranslation() - Axis1 - Axis2
        pts[3] = tr.getTranslation() + Axis1 - Axis2

        addTriangle(p0: pts[0], p1: pts[1], p2: pts[2], color: color)
        addTriangle(p0: pts[0], p1: pts[2], p2: pts[3], color: color)
    }

}

// MARK: - Private
extension Gizmos {
    static func addBox(pts: [Vector3], color: Color32, renderFlags: RenderFlag) {
        if renderFlags.contains(.Wireframe) {
            let indices: [Int] = [
                0, 1, 1, 2, 2, 3, 3, 0,
                7, 6, 6, 5, 5, 4, 4, 7,
                1, 5, 6, 2,
                3, 7, 4, 0
            ]

            for i in 0..<12 {
                addLine(p0: pts[indices[i * 2]], p1: pts[indices[i * 2 + 1]], color: color)
            }
        }

        if renderFlags.contains(.Solid) {
            let indices: [Int] = [
                0, 2, 1, 0, 3, 2,
                1, 6, 5, 1, 2, 6,
                5, 7, 4, 5, 6, 7,
                4, 3, 0, 4, 7, 3,
                3, 6, 2, 3, 7, 6,
                5, 0, 1, 5, 4, 0
            ]

            for i in 0..<12 {
                addTriangle(p0: pts[indices[i * 3 + 0]], p1: pts[indices[i * 3 + 1]], p2: pts[indices[i * 3 + 2]], color: color)
            }
        }
    }

    static func addCircle(nbPts: Int, pts: [Vector3], color: Color32, offset: Vector3) {
        for i in 0..<nbPts {
            let j = (i + 1) % nbPts
            addLine(p0: pts[i] + offset, p1: pts[j] + offset, color: color)
        }
    }

    enum Orientation {
        case ORIENTATION_XY
        case ORIENTATION_XZ
        case ORIENTATION_YZ
    }

    @discardableResult
    static func generatePolygon(nbVerts: Int, verts: inout [Vector3], orientation: Orientation,
                                amplitude: Float, phase: Float, transform: Matrix? = nil) -> Bool {
        if nbVerts == 0 {
            return false
        }

        let step = 2 * Float.pi / Float(nbVerts)

        for i in 0..<nbVerts {
            let angle = phase + Float(i) * step
            let y = sinf(angle) * amplitude
            let x = cosf(angle) * amplitude

            if (orientation == .ORIENTATION_XY) {
                verts[i] = Vector3(x, y, 0.0)
            } else if (orientation == .ORIENTATION_XZ) {
                verts[i] = Vector3(x, 0.0, y)
            } else if (orientation == .ORIENTATION_YZ) {
                verts[i] = Vector3(0.0, x, y)
            }

            if let transform = transform {
                verts[i] = Vector3.transformCoordinate(v: verts[i], m: transform)
            }
        }
        return true
    }

    @inlinable
    static func fixCapsuleVertex(p: inout Vector3, radius: Float, halfHeight: Float) {
        let sign: Float = p.y > 0 ? 1.0 : -1.0
        p.y -= sign
        p *= radius
        p.y += halfHeight * sign
    }

    /// create triangle strip of spheres
    @discardableResult
    static func generateSphere(nbSeg: Int, nbVerts: inout Int, verts: inout [Vector3], normals: inout [Vector3]) -> Bool {
        var tempVertexBuffer = [Vector3](repeating: Vector3(), count: MAX_TEMP_VERTEX_BUFFER)
        var tempNormalBuffer = [Vector3](repeating: Vector3(), count: MAX_TEMP_VERTEX_BUFFER)

        let halfSeg = nbSeg / 2
        let nSeg = halfSeg * 2

        if (((nSeg + 1) * (nSeg + 1)) > MAX_TEMP_VERTEX_BUFFER) {
            return false
        }

        let stepTheta = 2 * Float.pi / Float(nSeg)
        let stepPhi = Float.pi / Float(nSeg)

        // compute sphere vertices on the temporary buffer
        nbVerts = 0
        for i in 0...nSeg {
            let theta = Float(i) * stepTheta
            let cosi = cos(theta)
            let sini = sin(theta)

            for j in -halfSeg...halfSeg {
                let phi = Float(j) * stepPhi
                let sinj = sin(phi)
                let cosj = cos(phi)

                let y = cosj * cosi
                let x = sinj
                let z = cosj * sini

                tempVertexBuffer[nbVerts] = Vector3(x, y, z)
                tempNormalBuffer[nbVerts] = Vector3(x, y, z).normalized()
                nbVerts += 1
            }
        }

        nbVerts = 0
        // now create triangle soup data
        for i in 0..<nSeg {
            for j in 0..<nSeg {
                // add one triangle
                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * i + j]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * i + j]
                nbVerts += 1

                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * i + j + 1]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * i + j + 1]
                nbVerts += 1

                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * (i + 1) + j + 1]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * (i + 1) + j + 1]
                nbVerts += 1

                // add another triangle
                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * i + j]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * i + j]
                nbVerts += 1

                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * (i + 1) + j + 1]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * (i + 1) + j + 1]
                nbVerts += 1

                verts[nbVerts] = tempVertexBuffer[(nSeg + 1) * (i + 1) + j]
                normals[nbVerts] = tempNormalBuffer[(nSeg + 1) * (i + 1) + j]
                nbVerts += 1

            }
        }

        return true
    }
}
