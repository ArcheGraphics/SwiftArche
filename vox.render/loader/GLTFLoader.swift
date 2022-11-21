//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class GLTFLoader {
    private static let defaultPipeline = GLTFLoader([
        Validator(),
        TextureParser(),
        MaterialParser(),
        MeshParser(),
        EntityParser(),
        SkinParser(),
        AnimationParser(),
        SceneParser()
    ]);
    private static let texturePipeline = GLTFLoader([TextureParser()]);
    private static let materialPipeline = GLTFLoader([TextureParser(), MaterialParser()]);
    private static let animationPipeline = GLTFLoader([EntityParser(), AnimationParser()]);
    private static let meshPipeline = GLTFLoader([MeshParser()]);

    private var _pipes: [Parser] = [];

    private init(_ pipes: [Parser]) {
        _pipes = pipes
    }

    static func parse(_ engine: Engine, _ url: URL, _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.engine = engine
        context.keepMeshData = keepMeshData
        GLTFLoader.defaultPipeline._parse(url, context, callback)
    }

    static func parseTexture(_ engine: Engine, _ url: URL, _ textureIndex: Int,
                             _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.engine = engine
        context.keepMeshData = keepMeshData
        context.textureIndex = textureIndex
        GLTFLoader.texturePipeline._parse(url, context, callback)
    }

    static func parseMaterial(_ engine: Engine, _ url: URL, _ materialIndex: Int,
                             _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.engine = engine
        context.keepMeshData = keepMeshData
        context.materialIndex = materialIndex
        GLTFLoader.materialPipeline._parse(url, context, callback)
    }

    static func parseAnimation(_ engine: Engine, _ url: URL, _ animationIndex: Int,
                              _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.engine = engine
        context.keepMeshData = keepMeshData
        context.animationIndex = animationIndex
        GLTFLoader.animationPipeline._parse(url, context, callback)
    }

    static func parseMesh(_ engine: Engine, _ url: URL, _ meshIndex: Int, _ subMeshIndex:Int,
                               _ callback: @escaping (GLTFResource) -> Void, _ keepMeshData: Bool = false) {
        let context = ParserContext()
        context.engine = engine
        context.keepMeshData = keepMeshData
        context.meshIndex = meshIndex
        context.subMeshIndex = subMeshIndex
        GLTFLoader.meshPipeline._parse(url, context, callback)
    }

    private func _parse(_ url: URL, _ context: ParserContext, _ callback: @escaping (GLTFResource) -> Void) {
        GLTFAsset.load(with: url, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async { [self] in
                if status == .complete {
                    context.glTFResource = GLTFResource()
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