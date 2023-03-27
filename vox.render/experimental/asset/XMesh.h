//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import <Foundation/Foundation.h>

@class XTextureManager;
@class XMeshData;

struct XMeshChunk;
struct XSubMesh;
struct XMaterial;

@protocol MTLTexture;
@protocol MTLBuffer;
@protocol MTLDevice;
@protocol MTLHeap;

// Stores runtime mesh information extracted from the source assets.
@interface XMesh : NSObject <NSCopying>

// Geometry buffers for GPU access.
@property(nonatomic, readonly) id <MTLBuffer> vertices;
@property(nonatomic, readonly) id <MTLBuffer> normals;
@property(nonatomic, readonly) id <MTLBuffer> tangents;
@property(nonatomic, readonly) id <MTLBuffer> uvs;
@property(nonatomic, readonly) id <MTLBuffer> indices;
@property(nonatomic, readonly) id <MTLBuffer> chunks;

// Typed access for mesh data.
@property(nonatomic, readonly) const struct XMeshChunk *chunkData;
@property(nonatomic, readonly) const struct XSubMesh *meshes;
@property(nonatomic, readonly) const struct XMaterial *materials;

// Counts of mesh subobjects.
@property(nonatomic, readonly) NSUInteger vertexCount;
@property(nonatomic, readonly) NSUInteger indexCount;

@property(nonatomic, readonly) NSUInteger chunkCount;
@property(nonatomic, readonly) NSUInteger meshCount;

@property(nonatomic, readonly) NSUInteger opaqueChunkCount;
@property(nonatomic, readonly) NSUInteger opaqueMeshCount;

@property(nonatomic, readonly) NSUInteger alphaMaskedChunkCount;
@property(nonatomic, readonly) NSUInteger alphaMaskedMeshCount;

@property(nonatomic, readonly) NSUInteger transparentChunkCount;
@property(nonatomic, readonly) NSUInteger transparentMeshCount;

@property(nonatomic, readonly) NSUInteger materialCount;

// Initialization from an XMeshData asset.
- (instancetype)initWithMesh:(XMeshData *)mesh device:(id <MTLDevice>)device textureManager:(XTextureManager *)textureManager;

@end
