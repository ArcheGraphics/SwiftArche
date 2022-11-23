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
                if let bufferView = inverseBindMatrices.bufferView {
                    if let data = bufferView.buffer.data {
                        let offset = inverseBindMatrices.offset + bufferView.offset
                        skin.inverseBindMatrices = [Matrix](repeating: Matrix(), count: jointCount)
                        for j in 0..<jointCount {
                            (data as NSData).getBytes(&skin.inverseBindMatrices[j],
                                    range: NSRange(location: offset + (bufferView.stride != 0 ? bufferView.stride : MemoryLayout<Matrix>.stride) * j,
                                            length: MemoryLayout<Matrix>.stride))
                        }
                    }
                }
            }

            for j in 0..<jointCount {
                skin.joints[i] = glTFResource.entities[gltfSkin.joints[j].index].name
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
        for index in 0..<joints.count {
            var path: [Entity] = []
            var entity: Entity? = entities[index]
            while (entity != nil) {
                path.insert(entity!, at: 0)
                entity = entity!.parent
            }
            paths[index] = path
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