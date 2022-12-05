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

1. ARKit integration
2. PhysX
3. Cascade Stable ShadowMap
4. PBR Rendering (roghness-metallic, clearcoat)
4. HDR IBL Lighting
5. Fog (Linear, Exponential, ExponentialSquared)
6. ACES ToneMapping with auto luminance exposure
7. Skinned Animation and Morph
