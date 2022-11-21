//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class ParserContext {
    var engine: Engine!
    var glTFResource: GLTFResource!
    var keepMeshData: Bool = false
    var hasSkinned: Bool = false
    /** adapter subAsset */
    var textureIndex: Int?
    var materialIndex: Int?
    var animationIndex: Int?
    var meshIndex: Int?
    var subMeshIndex: Int?
}