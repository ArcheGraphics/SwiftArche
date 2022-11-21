//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class GLTFLoader {
    static let defaultPipeline = GLTFLoader([
        Validator(),
        TextureParser(),
        MaterialParser(),
        MeshParser(),
        EntityParser(),
        SkinParser(),
        AnimationParser(),
        SceneParser()
    ]);

    static let texturePipeline = GLTFLoader([TextureParser()]);
    static let materialPipeline = GLTFLoader([TextureParser(), MaterialParser()]);
    static let animationPipeline = GLTFLoader([EntityParser(), AnimationParser()]);
    static let meshPipeline = GLTFLoader([MeshParser()]);

    private var _pipes: [Parser] = [];

    private init(_ pipes: [Parser]) {
        _pipes = pipes
    }

    func parse(_ resource: GLTFResource, keepMeshData: Bool) {
        GLTFAsset.load(with: resource.url, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async { [self] in
                if status == .complete {
                    resource.gltf = maybeAsset!
                    var context = ParserContext()
                    context.glTFResource = resource
                    context.keepMeshData = keepMeshData
                    for pipe in _pipes {
                        pipe.parse(&context)
                    }

                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }
}