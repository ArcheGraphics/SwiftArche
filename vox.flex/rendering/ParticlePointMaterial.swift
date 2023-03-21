//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

/// particle point Material.
public class ParticlePointMaterial: BaseMaterial {
    private static let highlightProperty = "hlIndex"
    private static let radiusProperty = "pointRadius"
    private static let scaleProperty = "pointScale"
    var _pointScale: Float = 0
    var _pointRadius: Float = 0
    var _highlightIndex: UInt32 = 0
    
    public var pointScale: Float {
        get {
            _pointScale
        }
        set {
            _pointScale = newValue
            shaderData.setData(ParticlePointMaterial.scaleProperty, _pointScale)
        }
    }
    
    public var pointRadius: Float {
        get {
            _pointRadius
        }
        set {
            _pointRadius = newValue
            shaderData.setData(ParticlePointMaterial.radiusProperty, _pointRadius)
        }
    }
    
    public var highlightIndex: UInt32 {
        get {
            _highlightIndex
        }
        set {
            _highlightIndex = newValue
            shaderData.setData(ParticlePointMaterial.highlightProperty, _highlightIndex)
        }
    }

    public override init(_ name: String = "particle point mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library("flex.shader"), "vertex_particle", "fragment_particle"))

        shaderData.setData(ParticlePointMaterial.scaleProperty, _pointScale)
        shaderData.setData(ParticlePointMaterial.highlightProperty, _highlightIndex)
    }
}
