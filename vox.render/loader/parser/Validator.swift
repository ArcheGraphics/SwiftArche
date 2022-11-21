//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class Validator: Parser {
    override func parse(_ context: ParserContext) {
        let gltf = context.glTFResource.gltf!

        let gltfVersion = Int(gltf.version)!
        if (!(gltfVersion >= 2 && gltfVersion < 3)) {
            fatalError("Only support gltf 2.x.")
        }

        if !gltf.extensionsUsed.isEmpty {
            for extensionName in gltf.extensionsUsed {
                logger.info("\(extensionName) used")
            }
        }

        if !gltf.extensionsRequired.isEmpty {
            for extensionName in gltf.extensionsRequired {
                logger.info("\(extensionName) used")
            }
        }
    }
}