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

    init(_ name: String, _ description: String = "", _ ext: String = "glb", _ dir: String = "") {
        self.name = name
        self.description = description
        self.ext = ext
        self.dir = dir != "" ? dir : "glTF-Sample-Models/2.0/\(name)/glTF-Binary"
    }
}

class LoaderGUI: Script {
    var currentItem: Int = -1
    let gltfInfo = [
        // Standard
        GLTFInfo("Box", "One mesh and one material. Start with this."),
        GLTFInfo("BoxInterleaved", "Box example with interleaved position and normal attributes."),
        GLTFInfo("BoxTextured", "Box with one texture. Start with this to test textures."),
        GLTFInfo("BoxTexturedNonPowerOfTwo", "Box with a non-power-of-2 (NPOT) texture.  Not all implementations support NPOT textures."),
        GLTFInfo("Box With Spaces", "Box with URI-encoded spaces in the texture names used by a simple PBR material.", "gltf", "glTF-Sample-Models/2.0/Box With Spaces/glTF"),
        GLTFInfo("BoxVertexColors", "Box with vertex colors applied."),
        GLTFInfo("Cube", "A cube with non-smoothed faces.", "gltf", "glTF-Sample-Models/2.0/Cube/glTF"),
        GLTFInfo("AnimatedCube", "Same as previous cube having a linear rotation animation."),
        GLTFInfo("Duck", "The COLLADA duck. One texture."),
        GLTFInfo("2CylinderEngine", "Small CAD data set, including hierarchy."),
        GLTFInfo("ReciprocatingSaw", "Small CAD data set, including hierarchy."),
        GLTFInfo("GearboxAssy", "Medium-sized CAD data set, including hierarchy."),
        GLTFInfo("Buggy", "Medium-sized CAD data set, including hierarchy."),
        GLTFInfo("BoxAnimated", "Rotation and Translation Animations. Start with this to test animations."),
        GLTFInfo("CesiumMilkTruck", "Textured. Multiple nodes/meshes. Animations."),
        GLTFInfo("RiggedSimple", "Animations. Skins. Start with this to test skinning."),
        GLTFInfo("RiggedFigure", "Animations. Skins."),
        GLTFInfo("CesiumMan", "Textured. Animations. Skins."),
        GLTFInfo("BrainStem", "Animations. Skins."),
        GLTFInfo("Fox", "Multiple animations cycles: Survey, Walk, Run."),
        GLTFInfo("VirtualCity", "Textured. Animations."),
        GLTFInfo("Sponza", "Building interior, often used to test lighting."),
        GLTFInfo("TwoSidedPlane", "A plane having the two sided material parameter enabled."),
        // Feature Tests
        GLTFInfo("AlphaBlendModeTest", "Tests alpha modes and settings."),
        GLTFInfo("BoomBoxWithAxes", "Shows X, Y, and Z axis default orientations."),
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
        GLTFInfo("TriangleWithoutIndices", "The simplest possible glTF asset: A single `scene` with a single `node` and a single `mesh` with a single `mesh.primitive` with a single triangle with a single attribute, without indices and without a `material` "),
        GLTFInfo("Triangle", "A very simple glTF asset: The basic structure is the same as in [Triangle Without Indices](TriangleWithoutIndices), but here, the `mesh.primitive` describes an *indexed* geometry"),
        GLTFInfo("AnimatedTriangle", "This sample is similar to the [Triangle](Triangle), but the `node` has a `rotation` property that is modified with a simple `animation`"),
        GLTFInfo("AnimatedMorphCube", "Demonstrates a simple cube with two simple morph targets and an animation that transitions between them both."),
        GLTFInfo("AnimatedMorphSphere", "This sample is similar to the [Animated Morph Cube](AnimatedMorphCube), but the two morph targets move many more vertices and are more extreme than with the cube."),
        GLTFInfo("SimpleMeshes", "A simple `scene` with two `nodes`, both containing the same `mesh`, namely a `mesh` with a single `mesh.primitive` with a single indexed triangle with *multiple* attributes (positions, normals and texture coordinates), but without a `material`"),
        GLTFInfo("SimpleMorph", "A triangle with a morph animation applied"),
        GLTFInfo("SimpleSparseAccessor", "A simple mesh that uses sparse accessors"),
        GLTFInfo("SimpleSkin", "A simple example of vertex skinning in glTF"),
        GLTFInfo("Cameras", "A sample with two different `camera` objects"),
        GLTFInfo("InterpolationTest", "A sample with three different `animation` interpolations"),
        GLTFInfo("Unicode❤♻Test", "A sample with Unicode characters in file, material, and mesh names"),
        //
        GLTFInfo("AntiqueCamera"),
        GLTFInfo("Avocado"),
        GLTFInfo("BarramundiFish"),
        GLTFInfo("BoomBox"),
        GLTFInfo("Corset"),
        GLTFInfo("DamagedHelmet"),
        GLTFInfo("FlightHelmet"),
        GLTFInfo("Lantern"),
        GLTFInfo("SciFiHelmet"),
        GLTFInfo("Suzanne"),
        GLTFInfo("WaterBottle"),
        // Extensions Feature Tests
        GLTFInfo("AttenuationTest", "Tests the interactions between attenuation, thickness, and scale."),
        GLTFInfo("ClearCoatTest", "Tests if the KHR_materials_clearcoat extension is supported properly."),
        GLTFInfo("EmissiveStrengthTest", "Tests if the KHR_materials_emissive_strength extension is supported properly."),
        GLTFInfo("EnvironmentTest", "A simple `scene` with metal and dielectric spheres that range between 0 and 1 roughness. Useful for testing environment lighting."),
        GLTFInfo("IridescenceDielectricSpheres", "Tests KHR_materials_iridescence on a non-metallic material."),
        GLTFInfo("IridescenceMetallicSpheres", "Tests KHR_materials_iridescence on a metallic material."),
        GLTFInfo("IridescenceSuzanne", "Further tests KHR_materials_iridescence."),
        GLTFInfo("SpecGlossVsMetalRough", "Tests if the KHR_materials_pbrSpecularGlossiness extension is supported properly."),
        GLTFInfo("SpecularTest", "Tests if the KHR_materials_specular extension is supported correctly."),
        GLTFInfo("TextureTransformTest", "Tests if the KHR_texture_transform extension is supported for BaseColor."),
        GLTFInfo("TextureTransformMultiTest", "Tests if the KHR_texture_transform extension is supported for several inputs."),
        GLTFInfo("TransmissionRoughnessTest", "Tests the interaction between roughness and IOR."),
        GLTFInfo("TransmissionTest", "Tests if the KHR_materials_transmission extension is supported properly."),
        GLTFInfo("UnlitTest", "Tests if the KHR_materials_unlit extension is supported properly."),
        // Extensions Showcase
        GLTFInfo("ABeautifulGame", "Chess set using [transmission][volume]"),
        GLTFInfo("DragonAttenuation", "Dragon with background, using [material variants][transmission][volume]"),
        GLTFInfo("GlamVelvetSofa", "Sofa using [material variants][sheen][specular]"),
        GLTFInfo("IridescenceLamp", "Wayfair Lamp model using [transmission][volume]KHR_materials_iridescence"),
        GLTFInfo("IridescentDishWithOlives", "Dish using [transmission][volume][IOR][specular]"),
        GLTFInfo("LightsPunctualLamp", "Lamp using [punctual lights]"),
        GLTFInfo("MaterialsVariantsShoe", "Shoe using [material variants]"),
        GLTFInfo("MosquitoInAmber", "Mosquito in amber by Sketchfab, using [transmission][IOR][volume]"),
        GLTFInfo("SheenChair", "Chair using [material variants][sheen]"),
        GLTFInfo("SheenCloth", "Fabric example using [sheen]"),
        GLTFInfo("ToyCar", "Toy car example using [transmission][clearcoat][sheen]")
    ]

    private var loaderItem: Int {
        get {
            currentItem
        }
        set {
            if newValue != currentItem {
                currentItem = newValue
                let assetURL = Bundle.main.url(forResource: gltfInfo[newValue].name,
                        withExtension: gltfInfo[newValue].ext,
                        subdirectory: gltfInfo[newValue].dir)!
                GLTFLoader.parse(engine, assetURL) { [self] resource in
                    entity.clearChildren()
                    entity.addChild(resource.defaultSceneRoot)
                }
            }
        }
    }

    override func onUpdate(_ deltaTime: Float) {
        UIElement.Init(engine.canvas, deltaTime)

        ImGuiNewFrame()

        UIElement.selection("GLTF Name", gltfInfo.map { info in
            return info.name
        }, &loaderItem)
        if loaderItem > -1 {
            ImGuiTextUnformatted(gltfInfo[loaderItem].description)
        }
        ImGuiSeparator()
        UIElement.frameRate()
        // Rendering
        ImGuiRender()
    }
}
