//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

// Encapsulates the pipeline states and intermediate objects for generating a
//  volume of scattered lighting information.
class XScatterVolume {
    // The resulting volume data from the last update.
    var scatteringAccumVolume: MTLTexture? {
        nil
    }

    // User specified noise texture for updates.
    var noiseTexture: MTLTexture?
    var perlinNoiseTexture: MTLTexture?

    // Initializes this object, allocating metal objects from the device based on
    //  functions in the library.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int) {
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool) {

    }

    // Writes commands to update the volume using the command buffer.
    // Applies temporal updates which can be reset with the resetHistory flag.
    func update(commandBuffer: MTLCommandBuffer,
                frameDataBuffer: MTLBuffer,
                cameraParamsBuffer: MTLBuffer,
                shadowMap: MTLTexture,
                pointLightBuffer: MTLBuffer,
                spotLightBuffer: MTLBuffer,
                pointLightIndices: MTLBuffer,
                spotLightIndices: MTLBuffer,
                spotLightShadows: MTLTexture,
                rrData: MTLTexture,
                clustered: Bool,
                resetHistory: Bool) {
    }

    // Resizes the internal data structures to the required output size.
    func resize(_ size: CGSize) {
    }
}
