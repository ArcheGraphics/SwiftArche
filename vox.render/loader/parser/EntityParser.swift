//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class EntityParser: Parser {
    override func parse(_ context: ParserContext) {
        let glTFResource = context.glTFResource!
        let nodes = glTFResource.gltf.nodes
        if (nodes.isEmpty) {
            return
        }

        var entities: [Entity] = []
        for i in 0..<nodes.count {
            let gltfNode = nodes[i]
            let entity = Entity(glTFResource.engine, gltfNode.name ?? "EntityParser._defaultName\(i)")
            entity.transform.localMatrix = Matrix(gltfNode.matrix)
            entities.append(entity)
        }
        glTFResource.entities = entities
        _buildEntityTree(glTFResource)
        _createSceneRoots(glTFResource)
    }

    private func _buildEntityTree(_ context: GLTFResource) {
        for i in 0..<context.gltf.nodes.count {
            let children = context.gltf.nodes[i].childNodes
            let entity = context.entities[i]

            if (!children.isEmpty) {
                for j in 0..<children.count {
                    let childEntity: Entity = context.entities![children[j].index]
                    entity.addChild(childEntity)
                }
            }
        }
    }

    private func _createSceneRoots(_ context: GLTFResource) {
        let scenes = context.gltf.scenes
        if (scenes.isEmpty) {
            return
        }

        var sceneRoots: [Entity] = []
        for i in 0..<scenes.count {
            let nodes = scenes[i].nodes

            if (nodes.isEmpty) {
                continue
            }

            if (nodes.count == 1) {
                sceneRoots.append(context.entities![nodes[0].index])
            } else {
                let rootEntity = Entity(context.engine, "GLTF_ROOT")
                for j in 0..<nodes.count {
                    rootEntity.addChild(context.entities![nodes[j].index])
                }
                sceneRoots.append(rootEntity)
            }
        }

        context.sceneRoots = sceneRoots
        context.defaultSceneRoot = sceneRoots[context.gltf.defaultScene!.index]
    }
}
