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
    }
    
    public static func addPoint(_ p0: Vector3, color: Color32) {
        PointSubpass.ins.addPoint(p0, color: color)
    }
}
