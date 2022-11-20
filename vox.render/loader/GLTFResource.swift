//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Product after GLTF parser, usually, `defaultSceneRoot` is only needed to use.
public struct GLTFResource {
    /** GLTF file url. */
    var url: String!
    /** GLTF file content. */
    var gltf: GLTFAsset!
    /** Oasis Texture2D after TextureParser. */
    var textures: [MTLTexture]?
    /** Oasis Material after MaterialParser. */
    var materials: [Material]?
    /** Oasis ModelMesh after MeshParser. */
    var meshes: [[ModelMesh]]?
    /** Oasis Skin after SkinParser. */
    var skins: [Skin]?
    /** Oasis AnimationClip after AnimationParser. */
    var animations: [AnimationClip]?
    /** Oasis Entity after EntityParser. */
    var entities: [Entity]!
    /** Oasis Camera after SceneParser. */
    var cameras: [Camera]?
    /** GLTF can export lights in extension KHR_lights_punctual */
    var lights: [Light]?
    /** Oasis RootEntities after SceneParser. */
    var sceneRoots: [Entity]!
    /** Oasis RootEntity after SceneParser. */
    var defaultSceneRoot: Entity!
}