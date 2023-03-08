//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class Gizmos {
    public static var pointSize: Float {
        get {
            PointSubpass.ins.pointSize
        }
        set {
            PointSubpass.ins.pointSize = newValue
        }
    }
    
    public static func set(camera: Camera) {
        PointSubpass.ins.setCamera(camera)
        LineSubpass.ins.setCamera(camera)
        TriangleSubpass.ins.setCamera(camera)
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
    
    public static func addTriangle(p0: Vector3, p1: Vector3, color: Color32) {
        LineSubpass.ins.addLine(p0: p0, p1: p1, color: color)
    }
    
    public static func addArrow(posA: Vector3, posB: Vector3, color: Color32) {
        let t0 = (posB - posA).normalized()
        let a = abs(t0.x)<0.707 ? Vector3(1,0,0): Vector3(0,1,0)
        let t1 = Vector3.cross(left: t0, right: a).normalized()
        let t2 = Vector3.cross(left: t0, right: t1).normalized()

        addLine(p0: posA, p1: posB, color: color)
        addLine(p0: posB, p1: posB - t0*0.15 + t1 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0*0.15 - t1 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0*0.15 + t2 * 0.15, color: color)
        addLine(p0: posB, p1: posB - t0*0.15 - t2 * 0.15, color: color)
    }
}

// MARK: -
extension Gizmos {
    
}
