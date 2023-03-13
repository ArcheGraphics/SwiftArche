//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class GLTFLoader {
    private static let defaultPipeline = GLTFLoader([
        Validator(),
        TextureParser(),
        MaterialParser(),
        MeshParser(),
        EntityParser(),
        SceneParser()
    ]);
    private static let texturePipeline = GLTFLoader([TextureParser()]);
    private static let materialPipeline = GLTFLoader([TextureParser(), MaterialParser()]);
    private static let meshPipeline = GLTFLoader([MeshParser()]);

    private var _pipes: [Parser] = [];

    private init(_ pipes: [Parser]) {
        _pipes = pipes
    }

    public static func parse(_ engine: Engine, _ url: URL, _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.glTFResource = GLTFResource()
        context.glTFResource.engine = engine
        context.keepMeshData = keepMeshData
        GLTFLoader.defaultPipeline._parse(url, context, callback)
    }

    public static func parseTexture(_ engine: Engine, _ url: URL, _ callback: @escaping (GLTFResource) -> Void,
                                    _ keepMeshData: Bool = false, _ textureIndex: Int? = nil) {
        let context = ParserContext()
        context.glTFResource = GLTFResource()
        context.glTFResource.engine = engine
        context.keepMeshData = keepMeshData
        context.textureIndex = textureIndex
        GLTFLoader.texturePipeline._parse(url, context, callback)
    }

    public static func parseMaterial(_ engine: Engine, _ url: URL, _ callback: @escaping (GLTFResource) -> Void,
                                     _ keepMeshData: Bool = false, _ materialIndex: Int? = nil) {
        let context = ParserContext()
        context.glTFResource = GLTFResource()
        context.glTFResource.engine = engine
        context.keepMeshData = keepMeshData
        context.materialIndex = materialIndex
        GLTFLoader.materialPipeline._parse(url, context, callback)
    }

    public static func parseMesh(_ engine: Engine, _ url: URL, _ callback: @escaping (GLTFResource) -> Void,
                                 _ keepMeshData: Bool = false, _ meshIndex: Int? = nil, _ subMeshIndex:Int? = nil) {
        let context = ParserContext()
        context.glTFResource = GLTFResource()
        context.glTFResource.engine = engine
        context.keepMeshData = keepMeshData
        context.meshIndex = meshIndex
        context.subMeshIndex = subMeshIndex
        GLTFLoader.meshPipeline._parse(url, context, callback)
    }

    private func _parse(_ url: URL, _ context: ParserContext, _ callback: @escaping (GLTFResource) -> Void) {
        GLTFAsset.load(with: url, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async { [self] in
                if status == .complete {
                    context.glTFResource.url = url
                    context.glTFResource.gltf = maybeAsset!
                    for pipe in _pipes {
                        pipe.parse(context)
                    }
                    callback(context.glTFResource)
                } else if let error = maybeError {
                    logger.warning("Failed to load glTF asset: \(error)")
                }
            }
        }
    }
}
