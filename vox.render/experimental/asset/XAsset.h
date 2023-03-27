//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <Metal/Metal.h>

@class XMeshData;

// Uncompresses a block of data to another block.
NSData *_Nonnull uncompressData(NSData *_Nonnull data);

// Calculates the size of an uncompressed block of data.
size_t uncompressedDataSize(NSData *_Nonnull data);

// Uncompresses a block of data to a dynamically allocated buffer.
void uncompressDataWithAllocator(NSData *_Nonnull data, uint8_t *_Nonnull (^_Nonnull allocatorCallback)(size_t));

#if !TARGET_OS_IPHONE

// Helper to get the properties of block compressed pixel formats used by this sample.
void getBCProperties(MTLPixelFormat pixelFormat, NSUInteger *_Nonnull blockSize,
        NSUInteger *_Nonnull bytesPerBlock,
        NSUInteger *_Nonnull channels, int *_Nonnull alpha);

#endif

void getPixelFormatBlockDesc(MTLPixelFormat pixelFormat,
        NSUInteger *_Nonnull blockSize,
        NSUInteger *_Nonnull bytesPerBlock);

// MARK: - XTextureData
// Class to decode texture content from binary data.
FOUNDATION_EXPORT
@interface XTextureData : NSObject <NSSecureCoding>

// Path to original texture.
@property(nonatomic, readonly, nonnull) NSString *path;

// Texture properties.
@property(nonatomic, readonly) NSUInteger width;
@property(nonatomic, readonly) NSUInteger height;
@property(nonatomic, readonly) NSUInteger mipmapLevelCount;
@property(nonatomic, readonly) MTLPixelFormat pixelFormat;

// Offset to texture data in mesh data block.
@property(nonatomic, readonly) NSUInteger pixelDataOffset;
// Length of texture data in mesh data block.
@property(nonatomic, readonly) NSUInteger pixelDataLength;

@property(nonatomic, readonly, nonnull) NSArray *mipOffsets;
@property(nonatomic, readonly, nonnull) NSArray *mipLengths;

+ (BOOL)supportsSecureCoding;

// NSCoding protocol initialization.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder;

// NSCoding protocol serialization.
- (void)encodeWithCoder:(nonnull NSCoder *)coder;

@end

// MARK: - XMeshData
// Class to decode mesh content from binary data.
FOUNDATION_EXPORT
@interface XMeshData : NSObject <NSSecureCoding>

@property(nonatomic, readonly, nullable) NSData *textureData;

@property(nonatomic, readonly, nullable) NSData *vertexData;
@property(nonatomic, readonly, nullable) NSData *normalData;
@property(nonatomic, readonly, nullable) NSData *tangentData;
@property(nonatomic, readonly, nullable) NSData *uvData;

// Indices for rendering.
@property(nonatomic, readonly, nullable) NSData *indexData;

// Chunk data in XMeshChunk format.
@property(nonatomic, readonly, nullable) NSData *chunkData;

// Mesh data in XSubMesh format.
@property(nonatomic, readonly, nullable) NSData *meshData;

// Material data in XMaterial format.
@property(nonatomic, readonly, nullable) NSData *materialData;

// Type of indices.
@property(nonatomic, readonly) NSUInteger indexType;

// Counts of objects in data buffers.
@property(nonatomic, readonly) NSUInteger vertexCount;
@property(nonatomic, readonly) NSUInteger indexCount;
@property(nonatomic, readonly) NSUInteger chunkCount;
@property(nonatomic, readonly) NSUInteger meshCount;
@property(nonatomic, readonly) NSUInteger materialCount;

@property(nonatomic, readonly) NSUInteger opaqueChunkCount;
@property(nonatomic, readonly) NSUInteger opaqueMeshCount;

@property(nonatomic, readonly) NSUInteger alphaMaskedChunkCount;
@property(nonatomic, readonly) NSUInteger alphaMaskedMeshCount;

@property(nonatomic, readonly) NSUInteger transparentChunkCount;
@property(nonatomic, readonly) NSUInteger transparentMeshCount;

// Texture objects stored by use in separate arrays
@property(nonatomic, readonly, nullable) NSArray<XTextureData *> *textures;

// NSCoding protocol initialization.
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder;

// NSCoding protocol serialization.
- (void)encodeWithCoder:(nonnull NSCoder *)coder;

// High level method to create.
+ (nullable XMeshData *)meshWithFilename:(nonnull NSString *)filename;

@end
