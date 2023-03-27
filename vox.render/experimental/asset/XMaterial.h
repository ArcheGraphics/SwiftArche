//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <simd/simd.h>

// Data only structure storing encoded material information.
struct XMaterial {
    vector_float3 baseColor;                    // Fallback diffuse color.
    unsigned int baseColorTextureHash;         // Hash of diffuse texture.
    bool hasBaseColorTexture;          // Flag indicating a valid diffuse texture index.
    bool hasDiffuseMask;               // Flag indicating an alpha mask in the diffuse texture.
    vector_float3 metallicRoughness;            // Fallback metallic roughness.
    unsigned int metallicRoughnessHash;        // Hash of specular texture.
    bool hasMetallicRoughnessTexture;  // Flag indicating a valid metallic roughness texture index.
    unsigned int normalMapHash;                // Hash of normal map texture.
    bool hasNormalMap;                 // Flag indicating a valid normal map texture index.
    vector_float3 emissiveColor;                // Fallback emissive color.
    unsigned int emissiveTextureHash;          // Hash of emissive texture.
    bool hasEmissiveTexture;           // Flag indicating a valid emissive texture index.
    float opacity;
};
