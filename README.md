# SwiftArche - Metal Graphics Engine written by Swift

## Motivation

ArcheGraphics was originally designed to develop a graphics engine based on WebGPU. Therefore, the design goal of
Arche-cpp is cross-platform versatility. This project is a heterogeneous project, aiming to design an engine based on
Metal and Swift under the Apple platform. This design is mainly for mobile devices, especially AR scenarios, and aims to
highlight AR-based user interaction.

This architecture of project is very similar to Unity's component entity pattern (not ECS). Based on entity and
component, it is easy to combine other open-source ability

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

###. ARKit integration
1. Face Tracking with morph

###. PhysX 
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
