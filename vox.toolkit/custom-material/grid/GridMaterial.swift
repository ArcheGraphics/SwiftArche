//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Metal

public class GridMaterial: BaseMaterial {
    private static let _gridProperty = "u_grid"
    private var _gridData = GridData(u_far: 100, u_near: 0.1, u_primaryScale: 10, u_secondaryScale: 1,
            u_gridIntensity: 0.2, u_axisIntensity: 0.1, u_flipProgress: 0)

    /// Near clip plane - the closest point to the camera when rendering occurs.
    public var nearClipPlane: Float {
        get {
            _gridData.u_near
        }
        set {
            _gridData.u_near = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// Far clip plane - the furthest point to the camera when rendering occurs.
    public var farClipPlane: Float {
        get {
            _gridData.u_far
        }
        set {
            _gridData.u_far = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// Primary scale of grid size.
    public var primaryScale: Float {
        get {
            _gridData.u_primaryScale
        }
        set {
            _gridData.u_primaryScale = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// Secondary scale of grid size.
    public var secondaryScale: Float {
        get {
            _gridData.u_secondaryScale
        }
        set {
            _gridData.u_secondaryScale = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// Grid color intensity.
    public var gridIntensity: Float {
        get {
            _gridData.u_gridIntensity
        }
        set {
            _gridData.u_gridIntensity = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// Axis color intensity.
    public var axisIntensity: Float {
        get {
            _gridData.u_axisIntensity
        }
        set {
            _gridData.u_axisIntensity = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    /// 2D-3D flip progress.
    public var flipProgress: Float {
        get {
            _gridData.u_flipProgress
        }
        set {
            _gridData.u_flipProgress = newValue
            shaderData.setData(GridMaterial._gridProperty, _gridData)
        }
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("toolkit.shader"), "vertex_grid", "fragment_grid"))
    }
}
