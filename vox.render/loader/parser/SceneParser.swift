//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class SceneParser: Parser {
    private static var _defaultMaterial: PBRMaterial!

    private static func _getDefaultMaterial(_ engine: Engine) -> PBRMaterial {
        if (SceneParser._defaultMaterial == nil) {
            SceneParser._defaultMaterial = PBRMaterial(engine)
        }

        return SceneParser._defaultMaterial
    }

    override func parse(_ context: ParserContext) {
        let glTFResource = context.glTFResource!
        let gltf = glTFResource.gltf!

        if gltf.nodes.isEmpty {
            return
        }

        for i in 0..<gltf.nodes.count {
            let gltfNode = gltf.nodes[i]
            let entity = glTFResource.entities[i]

            if let camera = gltfNode.camera {
                _createCamera(glTFResource, gltf.cameras[camera.index], entity)
            }

            if gltfNode.mesh != nil {
                _createRenderer(context, gltfNode, entity)
            }

            if let light = gltfNode.light {
                KHR_lights_punctual.parseEngineResource(light, entity, context)
            }
        }
    }

    private func _createCamera(_ context: GLTFResource, _ cameraSchema: GLTFCamera, _ entity: Entity) {
        let camera = entity.addComponent(Camera.self)
        camera.farClipPlane = cameraSchema.zFar
        camera.nearClipPlane = cameraSchema.zNear

        if let orthographic = cameraSchema.orthographic {
            camera.isOrthographic = true
            camera.orthographicSize = max(orthographic.xMag, orthographic.yMag) / 2
        }

        if let perspective = cameraSchema.perspective {
            camera.aspectRatio = perspective.aspectRatio
            camera.fieldOfView = perspective.yFOV
        }

        if (context.cameras == nil) {
            context.cameras = []
        }
        context.cameras!.append(camera)
        // @todo: use engine camera by default
        camera.enabled = false
    }

    private func _createRenderer(_ context: ParserContext, _ gltfNode: GLTFNode, _ entity: Entity) {
        let glTFResource = context.glTFResource!
        let glTFMesh = gltfNode.mesh!
        let skin = gltfNode.skin
        let gltfMeshPrimitives = glTFMesh.primitives
        let blendShapeWeights = gltfNode.weights ?? glTFMesh.weights

        for i in 0..<gltfMeshPrimitives.count {
            let mesh = glTFResource.meshes![glTFMesh.index][i]
            let renderer: MeshRenderer

            if (skin != nil || blendShapeWeights != nil) {
                context.hasSkinned = true
                let skinRenderer = entity.addComponent(SkinnedMeshRenderer.self)
                skinRenderer.mesh = mesh
                if let skin = skin {
                    skinRenderer.skin = glTFResource.skins![skin.index]
                }
                if let blendShapeWeights = blendShapeWeights {
                    skinRenderer.blendShapeWeights = blendShapeWeights.map { value in
                        value.floatValue
                    }
                }
                renderer = skinRenderer
            } else {
                renderer = entity.addComponent(MeshRenderer.self)
                renderer.mesh = mesh
            }

            if let gltfMaterial = gltfMeshPrimitives[i].material {
                renderer.setMaterial(glTFResource.materials![gltfMaterial.index])
            } else {
                renderer.setMaterial(SceneParser._getDefaultMaterial(glTFResource.engine))
            }
        }
    }
}
