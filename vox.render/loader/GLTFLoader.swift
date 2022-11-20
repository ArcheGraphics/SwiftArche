//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class GLTFLoader {
    private let _engine: Engine
    public var asset: GLTFAsset?

    public init(_ engine: Engine, with assetUrl: URL) {
        _engine = engine
        GLTFAsset.load(with: assetUrl, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async { [self] in
                if status == .complete {
                    asset = maybeAsset!
                    _parseAsset()
                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }

    private func _parseAsset() {
        guard let asset = asset else {
            return
        }
        let rootEntity = Entity(_engine)
        for node in asset.nodes {
            _parseNode(node, rootEntity)
        }

        for material in asset.materials {
            _parseMaterial(material)
        }
    }

    private func _parseMaterial(_ material: GLTFMaterial) {

    }

    private func _parseNode(_ node: GLTFNode, _ root: Entity) {
        for node in node.childNodes {
            let child = root.createChild()
            child.transform.localMatrix = Matrix(node.matrix)
            if let gltfCamera = node.camera {
                _parseCamera(gltfCamera, child)
            }
            _parseNode(node, child)
        }
    }

    private func _parseCamera(_ gltfCamera: GLTFCamera, _ entity: Entity) {
        let camera: Camera = entity.addComponent()
        camera.nearClipPlane = gltfCamera.zNear
        camera.farClipPlane = gltfCamera.zFar
        if let gltfPerspectiveCamera = gltfCamera.perspective {
            camera.aspectRatio = gltfPerspectiveCamera.aspectRatio
            camera.fieldOfView = gltfPerspectiveCamera.yFOV
        }
        if let gltfOrthographicCamera = gltfCamera.orthographic {
            camera.orthographicSize = max(gltfOrthographicCamera.xMag, gltfOrthographicCamera.yMag)
            camera.isOrthographic = true
        }
    }
}
