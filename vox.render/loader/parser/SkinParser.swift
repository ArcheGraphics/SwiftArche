//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd
import vox_math

class SkinParser: Parser {
    override func parse(_ context: ParserContext) {
        let glTFResource = context.glTFResource!
        let gltfSkins = glTFResource.gltf.skins
        if gltfSkins.isEmpty {
            return
        }

        var skins: [Skin] = []
        for i in 0..<gltfSkins.count {
            let gltfSkin = gltfSkins[i]
            let jointCount = gltfSkin.joints.count
            let skin = Skin("SKIN_\(i)")

            if let inverseBindMatrices = gltfSkin.inverseBindMatrices {
                skin.inverseBindMatrices = [Matrix](repeating: Matrix(), count: jointCount)
                GLTFUtil.convert(inverseBindMatrices, out: &skin.inverseBindMatrices)
            }

            skin.joints = [String](repeating: "", count: jointCount)
            for j in 0..<jointCount {
                skin.joints[j] = glTFResource.entities[gltfSkin.joints[j].index].name
            }

            if (gltfSkin.skeleton != nil) {
                skin.skeleton = glTFResource.entities[gltfSkin.skeleton!.index].name
            } else {
                let rootBone = _findSkeletonRootBone(gltfSkin.joints, glTFResource.entities)
                if let rootBone = rootBone {
                    skin.skeleton = rootBone.name
                } else {
                    fatalError("Failed to find skeleton root bone.")
                }
            }

            skins.append(skin)
        }
        glTFResource.skins = skins
    }

    private func _findSkeletonRootBone(_ joints: [GLTFNode], _ entities: [Entity]) -> Entity? {
        var paths: [Int: [Entity]] = [:]
        for joint in joints {
            var path: [Entity] = []
            var entity: Entity? = entities[joint.index]
            while (entity != nil) {
                path.insert(entity!, at: 0)
                entity = entity!.parent
            }
            paths[joint.index] = path
        }

        var rootNode: Entity? = nil
        var i = 0
        while true {
            i += 1
            var path = paths[joints[0].index]
            if (i >= path!.count) {
                return rootNode
            }

            let entity = path![i]
            for j in 1..<joints.count {
                path = paths[joints[j].index]
                if (i >= path!.count || entity !== path![i]) {
                    return rootNode
                }
            }

            rootNode = entity
        }
    }
}
