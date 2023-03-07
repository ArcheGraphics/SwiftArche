//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit
import ImGui

struct GLTFInfo {
    let name: String
    let ext: String
    let dir: String
    let description: String
    let fileName: String

    init(_ name: String, _ description: String = "", _ ext: String = "glb", _ dir: String = "", _ fileName: String = "") {
        self.name = name
        self.description = description
        self.ext = ext
        self.dir = dir != "" ? dir : "glTF-Sample-Models/2.0/\(name)/glTF-Binary"
        if fileName == "" {
            self.fileName = name
        } else {
            self.fileName = fileName
        }
    }
}

class LoaderGUI: Script {
    var camera: Camera!
    var currentItem: Int = -1
    var currentAnimationItem: Int = -1
    var animator: Animator?
    var animationName: [String] = []
    
    let gltfInfo = [
        GLTFInfo("AntiqueCamera"),
        GLTFInfo("Avocado"),
        GLTFInfo("BarramundiFish"),
        GLTFInfo("BoomBox"),
        GLTFInfo("Corset"),
        GLTFInfo("DamagedHelmet"),
        GLTFInfo("FlightHelmet", "", "gltf", "glTF-Sample-Models/2.0/FlightHelmet/glTF"),
        GLTFInfo("Lantern"),
        GLTFInfo("SciFiHelmet", "", "gltf", "glTF-Sample-Models/2.0/SciFiHelmet/glTF"),
        GLTFInfo("Suzanne", "", "gltf", "glTF-Sample-Models/2.0/Suzanne/glTF"),
        GLTFInfo("WaterBottle"),
        GLTFInfo("------------------Standard-------------------------------", "", "gltf", "glTF-Sample-Models/2.0/Cube/glTF", "Cube"),
        GLTFInfo("Box", "One mesh and one material. Start with this."),
        GLTFInfo("BoxInterleaved", "Box example with interleaved position and normal attributes."),
        GLTFInfo("BoxTextured", "Box with one texture. Start with this to test textures."),
        GLTFInfo("BoxTexturedNonPowerOfTwo", "Box with a non-power-of-2 (NPOT) texture.  Not all implementations support NPOT textures."),
        GLTFInfo("Box With Spaces", "Box with URI-encoded spaces in the texture names used by a simple PBR material.",
                 "gltf", "glTF-Sample-Models/2.0/Box With Spaces/glTF"),
        GLTFInfo("BoxVertexColors", "Box with vertex colors applied."),
        GLTFInfo("Cube", "A cube with non-smoothed faces.",
                 "gltf", "glTF-Sample-Models/2.0/Cube/glTF"),
        GLTFInfo("AnimatedCube", "Same as previous cube having a linear rotation animation.",
                 "gltf", "glTF-Sample-Models/2.0/AnimatedCube/glTF", ""),
        GLTFInfo("Duck", "The COLLADA duck. One texture."),
        GLTFInfo("2CylinderEngine", "Small CAD data set, including hierarchy."),
        GLTFInfo("ReciprocatingSaw", "Small CAD data set, including hierarchy."),
        GLTFInfo("GearboxAssy", "Medium-sized CAD data set, including hierarchy."),
        GLTFInfo("Buggy", "Medium-sized CAD data set, including hierarchy."),
        GLTFInfo("BoxAnimated", "Rotation and Translation Animations. Start with this to test animations.",
                 "glb", "glTF-Sample-Models/2.0/BoxAnimated/glTF-Binary", ""),
        GLTFInfo("CesiumMilkTruck", "Textured. Multiple nodes/meshes. Animations."),
        GLTFInfo("RiggedSimple", "Animations. Skins. Start with this to test skinning."),
        GLTFInfo("RiggedFigure", "Animations. Skins."),
        GLTFInfo("CesiumMan", "Textured. Animations. Skins."),
        GLTFInfo("BrainStem", "Animations. Skins."),
        GLTFInfo("Fox", "Multiple animations cycles: Survey, Walk, Run."),
        GLTFInfo("VirtualCity", "Textured. Animations.",
                 "glb", "glTF-Sample-Models/2.0/VC/glTF-Binary", "VC"),
        GLTFInfo("Sponza", "Building interior, often used to test lighting.",
                 "gltf", "glTF-Sample-Models/2.0/Sponza/glTF"),
        GLTFInfo("TwoSidedPlane", "A plane having the two sided material parameter enabled.",
                 "gltf", "glTF-Sample-Models/2.0/TwoSidedPlane/glTF"),
        // Feature Tests
        GLTFInfo("-----------------Feature Tests----------------------------", "", "gltf", "glTF-Sample-Models/2.0/AlphaBlendModeTest/glTF", "AlphaBlendModeTest"),
        GLTFInfo("AlphaBlendModeTest", "Tests alpha modes and settings."),
        GLTFInfo("BoomBoxWithAxes", "Shows X, Y, and Z axis default orientations.",
                 "gltf", "glTF-Sample-Models/2.0/BoomBoxWithAxes/glTF"),
        GLTFInfo("MetalRoughSpheres", "Tests various metal and roughness values (texture mapped)."),
        GLTFInfo("MetalRoughSpheresNoTextures", "Tests various metal and roughness values (textureless)."),
        GLTFInfo("MorphPrimitivesTest", "Tests a morph target on multiple primitives."),
        GLTFInfo("MorphStressTest", "Tests up to 8 morph targets."),
        GLTFInfo("MultiUVTest", "Tests a second set of texture coordinates."),
        GLTFInfo("NormalTangentTest", "Tests an engine's ability to automatically generate tangent vectors for a normal map."),
        GLTFInfo("NormalTangentMirrorTest", "Tests an engine's ability to load supplied tangent vectors for a normal map."),
        GLTFInfo("OrientationTest", "Tests node translations and rotations."),
        GLTFInfo("RecursiveSkeletons", "Tests unusual skinning cases with reused meshes and recursive skeletons."),
        GLTFInfo("TextureCoordinateTest", "Shows how XYZ and UV positions relate to displayed geometry."),
        GLTFInfo("TextureLinearInterpolationTest", "Tests that linear texture interpolation is performed on linear values, i.e. after sRGB decoding."),
        GLTFInfo("TextureSettingsTest", "Tests single/double-sided and various texturing modes."),
        GLTFInfo("VertexColorTest", "Tests if vertex colors are supported."),
        // Minimal Tests
        GLTFInfo("-----------------Minimal Tests-----------------------------", "", "gltf", "glTF-Sample-Models/2.0/Unicode❤♻Test/glTF", "Unicode❤♻Test"),
        GLTFInfo("TriangleWithoutIndices", "The simplest possible glTF asset: A single `scene` with a single `node` and a single `mesh` with a single `mesh.primitive` with a single triangle with a single attribute, without indices and without a `material` ", "gltf", "glTF-Sample-Models/2.0/TriangleWithoutIndices/glTF"),
        GLTFInfo("Triangle", "A very simple glTF asset: The basic structure is the same as in [Triangle Without Indices](TriangleWithoutIndices), but here, the `mesh.primitive` describes an *indexed* geometry", "gltf", "glTF-Sample-Models/2.0/Triangle/glTF"),
        GLTFInfo("AnimatedTriangle", "This sample is similar to the [Triangle](Triangle), but the `node` has a `rotation` property that is modified with a simple `animation`", "gltf", "glTF-Sample-Models/2.0/AnimatedTriangle/glTF"),
        GLTFInfo("AnimatedMorphCube", "Demonstrates a simple cube with two simple morph targets and an animation that transitions between them both."),
        GLTFInfo("AnimatedMorphSphere", "This sample is similar to the [Animated Morph Cube](AnimatedMorphCube), but the two morph targets move many more vertices and are more extreme than with the cube."),
        GLTFInfo("SimpleMeshes", "A simple `scene` with two `nodes`, both containing the same `mesh`, namely a `mesh` with a single `mesh.primitive` with a single indexed triangle with *multiple* attributes (positions, normals and texture coordinates), but without a `material`",
                 "gltf", "glTF-Sample-Models/2.0/SimpleMeshes/glTF"),
        GLTFInfo("SimpleMorph", "A triangle with a morph animation applied",
                 "gltf", "glTF-Sample-Models/2.0/SimpleMorph/glTF"),
        GLTFInfo("SimpleSparseAccessor", "A simple mesh that uses sparse accessors",
                 "gltf", "glTF-Sample-Models/2.0/SimpleSparseAccessor/glTF"),
        GLTFInfo("SimpleSkin", "A simple example of vertex skinning in glTF",
                 "gltf", "glTF-Sample-Models/2.0/SimpleSkin/glTF"),
        GLTFInfo("Cameras", "A sample with two different `camera` objects",
                 "gltf", "glTF-Sample-Models/2.0/Cameras/glTF"),
        GLTFInfo("InterpolationTest", "A sample with three different `animation` interpolations"),
        GLTFInfo("Unicode❤♻Test", "A sample with Unicode characters in file, material, and mesh names"),
        // Extensions Feature Tests
        GLTFInfo("-----------------Extensions Feature Tests------------------", "", "glb", "glTF-Sample-Models/2.0/UnlitTest/glTF-Binary", "UnlitTest"),
        GLTFInfo("AttenuationTest", "Tests the interactions between attenuation, thickness, and scale."),
        GLTFInfo("ClearCoatTest", "Tests if the KHR_materials_clearcoat extension is supported properly."),
        GLTFInfo("EmissiveStrengthTest", "Tests if the KHR_materials_emissive_strength extension is supported properly."),
        GLTFInfo("EnvironmentTest", "A simple `scene` with metal and dielectric spheres that range between 0 and 1 roughness. Useful for testing environment lighting.",
                 "gltf", "glTF-Sample-Models/2.0/EnvironmentTest/glTF"),
        GLTFInfo("IridescenceDielectricSpheres", "Tests KHR_materials_iridescence on a non-metallic material.",
                 "gltf", "glTF-Sample-Models/2.0/IridescenceDielectricSpheres/glTF"),
        GLTFInfo("IridescenceMetallicSpheres", "Tests KHR_materials_iridescence on a metallic material.",
                 "gltf", "glTF-Sample-Models/2.0/IridescenceMetallicSpheres/glTF"),
        GLTFInfo("IridescenceSuzanne", "Further tests KHR_materials_iridescence."),
        GLTFInfo("SpecGlossVsMetalRough", "Tests if the KHR_materials_pbrSpecularGlossiness extension is supported properly."),
        GLTFInfo("SpecularTest", "Tests if the KHR_materials_specular extension is supported correctly."),
        GLTFInfo("TextureTransformTest", "Tests if the KHR_texture_transform extension is supported for BaseColor.",
                 "gltf", "glTF-Sample-Models/2.0/TextureTransformTest/glTF"),
        GLTFInfo("TextureTransformMultiTest", "Tests if the KHR_texture_transform extension is supported for several inputs."),
        GLTFInfo("TransmissionRoughnessTest", "Tests the interaction between roughness and IOR."),
        GLTFInfo("TransmissionTest", "Tests if the KHR_materials_transmission extension is supported properly."),
        GLTFInfo("UnlitTest", "Tests if the KHR_materials_unlit extension is supported properly."),
        // Extensions Showcase
        GLTFInfo("----------------Extensions Showcase-------------------------", "", "glb", "glTF-Sample-Models/2.0/ToyCar/glTF-Binary", "ToyCar"),
        GLTFInfo("ABeautifulGame", "Chess set using [transmission][volume]",
                 "gltf", "glTF-Sample-Models/2.0/ABeautifulGame/glTF"),
        GLTFInfo("DragonAttenuation", "Dragon with background, using [material variants][transmission][volume]"),
        GLTFInfo("GlamVelvetSofa", "Sofa using [material variants][sheen][specular]"),
        GLTFInfo("IridescenceLamp", "Wayfair Lamp model using [transmission][volume]KHR_materials_iridescence"),
        GLTFInfo("IridescentDishWithOlives", "Dish using [transmission][volume][IOR][specular]"),
        GLTFInfo("LightsPunctualLamp", "Lamp using [punctual lights]"),
        GLTFInfo("MaterialsVariantsShoe", "Shoe using [material variants]"),
        GLTFInfo("MosquitoInAmber", "Mosquito in amber by Sketchfab, using [transmission][IOR][volume]"),
        GLTFInfo("SheenChair", "Chair using [material variants][sheen]"),
        GLTFInfo("SheenCloth", "Fabric example using [sheen]",
                 "gltf", "glTF-Sample-Models/2.0/SheenCloth/glTF"),
        GLTFInfo("ToyCar", "Toy car example using [transmission][clearcoat][sheen]")
    ]

    var loaderItem: Int {
        get {
            currentItem
        }
        set {
            if newValue != currentItem {
                currentItem = newValue
                let assetURL = Bundle.main.url(forResource: gltfInfo[newValue].fileName,
                        withExtension: gltfInfo[newValue].ext,
                        subdirectory: gltfInfo[newValue].dir)!
                GLTFLoader.parse(engine, assetURL) { [self] resource in
                    entity.clearChildren()
                    animationName = []
                    animator = nil
                    currentAnimationItem = -1
                    
                    entity.addChild(resource.defaultSceneRoot)
                    let renderers = resource.defaultSceneRoot.getComponentsIncludeChildren(Renderer.self)
                    var bounds = BoundingBox()
                    for renderer in renderers {
                        bounds = BoundingBox.merge(box1: bounds, box2: renderer.bounds)
                    }
                    let scale = 1 / bounds.getExtent().internalValue.max()
                    resource.defaultSceneRoot.transform.worldPosition = Vector3()
                    resource.defaultSceneRoot.transform.scale *= scale
                    
                    animator = resource.defaultSceneRoot!.getComponent(Animator.self)
                    if let animation = resource.animations {
                        animationName = animation.map { clip in
                            return clip.name
                        }
                        animationItem = 0
                    }
                }
            }
        }
    }
    
    var animationItem: Int {
        get {
            currentAnimationItem
        }
        set {
            if newValue != currentAnimationItem {
                currentAnimationItem = newValue
                if let animator = animator {
                    animator.play(animationName[currentAnimationItem])
                }
            }
        }
    }

    override func onGUI() {
        UIElement.Init(engine)

        ImGuiNewFrame()

        UIElement.selection("GLTF Name", gltfInfo.map { info in
            return info.name
        }, &loaderItem)
        if !animationName.isEmpty {
            UIElement.selection("Animation Name", animationName, &animationItem)
            ImGuiSliderFloat("Speed", &animator!.speed, -1.0, 1.0, nil, 1)
        }
        
        if loaderItem > -1 {
            ImGuiTextUnformatted(gltfInfo[loaderItem].description)
        }
        ImGuiSeparator()
        if ImGuiButton("Reset Camera", ImVec2(x: 100, y: 20)) {
            camera.entity.transform.worldPosition = Vector3(3, 2, 3)
        }
        ImGuiSliderFloat("Manual Exposure", &scene.postprocessManager.manualExposure, 0.0, 1.0, nil, 1)
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}
