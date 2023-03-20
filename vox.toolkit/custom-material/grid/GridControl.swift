//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Grid Control
public class GridControl: Script {
    private var _material: GridMaterial!
    private var _progress: Float = 0
    private var _is2DGrid: Bool = false
    private var _flipGrid: Bool = false

    /// Flip speed
    public var speed: Float = 10.0

    /// Camera
    public var camera: Camera?

    /// Grid Material.
    public var material: GridMaterial {
        get {
            _material
        }
    }
    
    public var distance: Float = 8

    /// Is 2D Grid.
    public var is2DGrid: Bool {
        get {
            _is2DGrid
        }
        set {
            _is2DGrid = newValue
            _progress = 0
            _flipGrid = true
        }
    }

    public override func onAwake() {
        let gridRenderer = entity.addComponent(MeshRenderer.self)
        gridRenderer.mesh = PrimitiveMesh.createQuadPlane(engine)
        _material = GridMaterial(engine)
        gridRenderer.setMaterial(_material)
    }

    public override func onUpdate(_ deltaTime: Float) {
        if let camera = camera {
            material.nearClipPlane = camera.nearClipPlane
            material.farClipPlane = camera.farClipPlane
            
            let logDistance = log2(distance)
            let upperDistance = pow(2, floor(logDistance) + 1)
            let lowerDistance = pow(2, floor(logDistance))
            
            let level = -floor(logDistance)
            material.primaryScale = pow(2, level)
            material.secondaryScale = pow(2, level + 1)
            material.fade = (distance - lowerDistance) / (upperDistance - lowerDistance)
            
            if (_flipGrid) {
                _progress += deltaTime
                var percent = simd_clamp(_progress * speed, 0, 1)
                if (percent >= 1) {
                    _flipGrid = false
                }

                if (!_is2DGrid) {
                    percent = 1 - percent
                }
                material.flipProgress = percent
            }
        }
    }
}
