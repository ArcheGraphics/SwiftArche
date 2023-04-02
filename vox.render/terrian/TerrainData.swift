//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class TerrianData {
    struct HabitatTextures {
        var diffSpecTextureArray: MTLTexture?
        var normalTextureArray: MTLTexture?
    }

    // Terrain rendering data
    var terrainTextures: [HabitatTextures] = []
    
    var targetHeightmap: MTLTexture
    
    init(targetHeightmap: MTLTexture) {
        self.targetHeightmap = targetHeightmap
    }
}
