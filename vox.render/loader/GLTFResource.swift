//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Product after GLTF parser, usually, `defaultSceneRoot` is only needed to use.
public class GLTFResource {
    public var engine: Engine!
    /** GLTF file url. */
    public var url: URL!
    /** GLTF file content. */
    public var gltf: GLTFAsset!
    /** Oasis Texture2D after TextureParser. */
    public var textures: [MTLTexture]?
    /** Oasis Sampler after TextureParser. */
    public var samplers: [MTLSamplerDescriptor?]?
    /** Oasis Material after MaterialParser. */
    public var materials: [Material]?
    /** Oasis ModelMesh after MeshParser. */
    public var meshes: [[ModelMesh]]?
    /** Oasis Skin after SkinParser. */
    public var skins: [Skin]?
    /** Oasis AnimationClip after AnimationParser. */
    public var animations: [AnimationClip]?
    /** Oasis Entity after EntityParser. */
    public var entities: [Entity]!
    /** Oasis Camera after SceneParser. */
    public var cameras: [Camera]?
    /** GLTF can export lights in extension KHR_lights_punctual */
    public var lights: [Light]?
    /** Oasis RootEntities after SceneParser. */
    public var sceneRoots: [Entity]!
    /** Oasis RootEntity after SceneParser. */
    public var defaultSceneRoot: Entity!
}
