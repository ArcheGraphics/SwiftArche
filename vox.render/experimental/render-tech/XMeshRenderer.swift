//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Encapsulates the pipeline states and intermediate objects for rendering meshes.
class XMeshRenderer {
    /// Initializes this object, allocating metal objects from the device based on functions in the library.
    init(with device: MTLDevice,
         textureManager: XTextureManager,
         materialSize: Int,
         alignedMaterialSize: Int,
         library: MTLLibrary,
         GBufferPixelFormats: [MTLPixelFormat],
         lightingPixelFormat: MTLPixelFormat,
         depthStencilFormat: MTLPixelFormat,
         sampleCount: Int,
         useRasterizationRate: Bool,
         singlePassDeferredLighting: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int,
         useSinglePassCSMGeneration: Bool,
         genCSMUsingVertexAmplification: Bool) {
    }

    func rebuildPipelines(with library: MTLLibrary,
                          GBufferPixelFormats: [MTLPixelFormat],
                          lightingPixelFormat: MTLPixelFormat,
                          depthStencilFormat: MTLPixelFormat,
                          sampleCount: Int,
                          useRasterizationRate: Bool,
                          singlePassDeferredLighting: Bool,
                          useSinglePassCSMGeneration: Bool,
                          genCSMUsingVertexAmplification: Bool) {

    }

    // Writes commands prior to executing a set of passes for rendering a mesh.
    func prerender(mesh: XMesh,
                   direct: Bool,
                   icbData: inout XICBData,
                   onEncoder: MTLRenderCommandEncoder) {

    }

    // Writes commands to render meshes using the command buffer.
    func render(mesh: XMesh,
                pass: XRenderPass,
                direct: Bool,
                icbData: inout XICBData,
                flags: [String: Bool],
                cameraParams: inout XCameraParams,
                onEncoder: MTLRenderCommandEncoder) {
    }
}
