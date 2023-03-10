# SwiftArche - Metal Graphics Engine written by Swift

## Motivation

SwiftArche aims to develop an exclusive game engine for the Apple platform based on Swift and Metal. 
This idea stems from my many practices in engine development, including the experience of developing on Vulkan, WebGPU, C++ and other platforms. 
As a personal project, I hope to focus on a single platform to reduce the workload of development, 
and I like the Swift language very much, I think it has the potential to be comparable to those game engines based on C#.

The architecture of the entire engine adopts a component system architecture similar to Unity. 
And similar to Unity, I will use a lot of C++ third-party libraries and bridge them through OBJC++, so the whole project is a mixed project. 
I will try my best to improve the comments to make it easier for other developers to understand the structure of the code, 
but I don't have much time to write additional documents. Developers can Clone this project and use Xcode to generate Apple-style documentation.

## Cloning && Install

This repository contains submodules for external dependencies, so when doing a fresh clone you need to clone
recursively:

```
git clone --recursive https://github.com/ArcheGraphics/SwiftArche.git
```

Existing repositories can be updated manually:

```
git submodule init
git submodule update
```

## Feature

Please Refer to [Demos](https://github.com/ArcheGraphics/Demo) which show some gifs.

### ARKit integration
1. Face Tracking with morph

### PhysX 
1. Collider
2. Character Controller
3. Joint
4. Scene Query

### Rendering
1. Cascade Stable ShadowMap
2. PBR Rendering (roghness-metallic, clearcoat)
3. HDR IBL Lighting and baker (pure compute shader)
4. Fog (Linear, Exponential, ExponentialSquared)
5. ACES ToneMapping with auto luminance exposure
6. Custom Shader with split Metal Shading Library

### Animation
1. Skinned Animation
2. Morph Traget

### Gizmos
1. SDF Text
2. Debugger tools with auxiliary wireframe rendering

### GPGPU
1. Fluid simulation

## Assets
In order to speed up the speed of git clone, assets are not introduced in the way of submodule. 
Since this project mainly builds and tests on the Mac, and then develops on the iOS platform, 
a series of assets are required for Mac testing:
1. [glTF-Sample-Models](https://github.com/KhronosGroup/glTF-Sample-Models)
2. [other assets](https://github.com/ArcheGraphics/assets) include hdr, texture and others downloads from:
    1. [Polyhaven](https://polyhaven.com)
    2. [Sketchfab](https://sketchfab.com/)
Please downloads these files and copy into the folder. 
If you add new assets, please include them into the xcode project which will package them.
