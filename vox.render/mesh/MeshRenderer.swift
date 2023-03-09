//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class MeshRenderer: Renderer {
    enum MeshRendererUpdateFlags: Int {
        /// VertexElementMacro.
        case  VertexElementMacro = 0x2
        /// All.
        case  All = 0x3
    }
    
    var _mesh: Mesh?

    /// Mesh assigned to the renderer.
    public var mesh: Mesh? {
        get {
            _mesh
        }
        set {
            let lastMesh = _mesh
            if (lastMesh != nil) {
                let listener = ListenerUpdateFlag()
                listener.listener = _onMeshChanged
                lastMesh!._updateFlagManager.removeFlag(flag: listener)
            }
            if (newValue != nil) {
                let listener = ListenerUpdateFlag()
                listener.listener = _onMeshChanged
                newValue!._updateFlagManager.addFlag(flag: listener)
                _dirtyUpdateFlag |= MeshRendererUpdateFlags.All.rawValue
            }
            _mesh = newValue
        }
    }

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
        let mesh = _mesh
        if (mesh != nil) {
            let localBounds = mesh!.bounds
            let worldMatrix = _entity.transform.worldMatrix
            worldBounds = BoundingBox.transform(source: localBounds, matrix: worldMatrix)
        } else {
            worldBounds = BoundingBox(Vector3(), Vector3())
        }
    }

    override func _render(_ devicePipeline: DevicePipeline) {
        if (_mesh != nil) {
            if (_dirtyUpdateFlag & MeshRendererUpdateFlags.VertexElementMacro.rawValue != 0) {
                let vertexDescriptor = mesh!._vertexDescriptor
                shaderData.disableMacro(HAS_UV.rawValue)
                shaderData.disableMacro(HAS_NORMAL.rawValue)
                shaderData.disableMacro(HAS_TANGENT.rawValue)
                shaderData.disableMacro(HAS_VERTEXCOLOR.rawValue)

                if vertexDescriptor.attributes[Int(UV_0.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_UV.rawValue)
                }
                if vertexDescriptor.attributes[Int(Normal.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_NORMAL.rawValue)
                }
                if vertexDescriptor.attributes[Int(Tangent.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_TANGENT.rawValue)
                }
                if vertexDescriptor.attributes[Int(Color_0.rawValue)].format != .invalid {
                    shaderData.enableMacro(HAS_VERTEXCOLOR.rawValue)
                }
                _dirtyUpdateFlag &= ~MeshRendererUpdateFlags.VertexElementMacro.rawValue
            }

            let subMeshes = mesh!.subMeshes
            for i in 0..<subMeshes.count {
                let material: Material?
                if i < _materials.count {
                    material = _materials[i]
                } else {
                    material = nil
                }
                if (material != nil) {
                    for j in 0..<material!.shader.count {
                        devicePipeline.pushPrimitive(RenderElement(self, mesh!, subMeshes[i], material!, material!.shader[j]))
                    }
                }
            }
        }
    }

    private func _onMeshChanged(type: Int?, object: AnyObject?) {
        if type! & MeshModifyFlags.Bounds.rawValue != 0 {
            _dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume.rawValue
        }
        if type! & MeshModifyFlags.VertexElements.rawValue != 0 {
            _dirtyUpdateFlag |= MeshRendererUpdateFlags.VertexElementMacro.rawValue
        }
    }
}
