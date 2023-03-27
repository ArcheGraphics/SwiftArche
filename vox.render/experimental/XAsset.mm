//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "XAsset.h"

#import <compression.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <unistd.h>
#import <sys/mman.h>

#import <Foundation/NSKeyedArchiver.h>

#define MESH_MAGIC   0x4853454D
#define MESH_VERSION 16

#define LOG_UNCOMPRESS_TIME (0)

#if LOG_UNCOMPRESS_TIME
#import <mach/mach_time.h>
#endif

// Header for the file.
struct XFileHeader {
    // Marker to indicate file type - should be `MESH_MAGIC`.
    uint32_t magic;
    // Marker to indicate file version  - should be `MESH_VERSION`.
    uint32_t version;
    // Offset to mesh data in the file.
    uint32_t dataOffset;
};

// Header for compressed blocks.
struct XCompressionHeader {
    // Compression mode in block - of type compression_algorithm.
    uint32_t compressionMode;
    // Size of uncompressed data.
    uint64_t uncompressedSize;
    // Size of compressed data.
    uint64_t compressedSize;
};

XCompressionHeader *getCompressionHeader(NSData *data) {
    assert(data != nullptr);

    if (data.length < sizeof(XCompressionHeader)) {
        NSLog(@"Data is too small");
        exit(1);
    }

    XCompressionHeader *header = ((XCompressionHeader *) data.bytes);

    if (data.length != sizeof(XCompressionHeader) + header->compressedSize) {
        NSLog(@"Data is too small");
        exit(1);
    }

    return header;
}

size_t uncompressedDataSize(NSData *data) {
    return getCompressionHeader(data)->uncompressedSize;
}

void uncompressData(const XCompressionHeader &header, const void *data, void *dstBuffer) {
#if LOG_UNCOMPRESS_TIME
    double tbConversionFactor = 0;

    mach_timebase_info_data_t timeInfo;
    if(mach_timebase_info(&timeInfo) == KERN_SUCCESS)
    {
        tbConversionFactor = timeInfo.numer / (1e6*timeInfo.denom); // ns->ms
    }

    uint64_t beginTime = mach_absolute_time();
#endif // LOG_UNCOMPRESS_TIME

    size_t a = compression_decode_buffer((uint8_t *) dstBuffer, header.uncompressedSize,
            (const uint8_t *) data, header.compressedSize,
            NULL, (compression_algorithm) header.compressionMode);

#if LOG_UNCOMPRESS_TIME
    uint64_t endTime = mach_absolute_time();

    double diff = (endTime - beginTime) * tbConversionFactor;

    printf("uncompress (%llu kb): %.3f ms\n", header.compressedSize/1024, diff);
#endif

    if (a != header.uncompressedSize) {
        NSCAssert(a == header.uncompressedSize, @"Error decompressing data");
    }
}

NSData *uncompressData(NSData *data) {
    XCompressionHeader *header = getCompressionHeader(data);

    NSMutableData *decompressedData = [NSMutableData dataWithLength:header->uncompressedSize];

    uncompressData(*header, (header + 1), decompressedData.mutableBytes);

    return decompressedData;
}

void uncompressDataWithAllocator(NSData *data, uint8_t *(^allocatorCallback)(size_t)) {
    XCompressionHeader *header = getCompressionHeader(data);

    uint8_t *dstBuffer = allocatorCallback(header->uncompressedSize);

    uncompressData(*header, (header + 1), dstBuffer);
}

//------------------------------------------------------------------------------

#if !TARGET_OS_IPHONE

// Helper to get the properties of block compressed pixel formats used by this sample.
void getBCProperties(MTLPixelFormat pixelFormat, NSUInteger *blockSize, NSUInteger *bytesPerBlock, NSUInteger *channels, int *alpha) {
    if (pixelFormat == MTLPixelFormatBC5_RGUnorm || pixelFormat == MTLPixelFormatBC5_RGSnorm) {
        *blockSize = 4;
        *bytesPerBlock = 16;
        *channels = 2;
        *alpha = 0;
    } else if (pixelFormat == MTLPixelFormatBC4_RUnorm) {
        *blockSize = 4;
        *bytesPerBlock = 8;
        *channels = 1;
        *alpha = 0;
    } else if (pixelFormat == MTLPixelFormatBC1_RGBA_sRGB || pixelFormat == MTLPixelFormatBC1_RGBA) {
        *blockSize = 4;
        *bytesPerBlock = 8;
        *channels = 4;
        *alpha = 0;
    } else if (pixelFormat == MTLPixelFormatBC3_RGBA_sRGB || pixelFormat == MTLPixelFormatBC3_RGBA) {
        *blockSize = 4;
        *bytesPerBlock = 16;
        *channels = 4;
        *alpha = 1;
    }
}

#endif

void getPixelFormatBlockDesc(MTLPixelFormat pixelFormat, NSUInteger *blockSize, NSUInteger *bytesPerBlock) {
    *blockSize = 4;
    *bytesPerBlock = 16;

#if !TARGET_OS_IPHONE
    __unused NSUInteger channels_UNUSED = 0;
    __unused int alpha_UNUSED = 1;
    getBCProperties(pixelFormat, blockSize, bytesPerBlock, &channels_UNUSED, &alpha_UNUSED);
#endif
}

//MARK: - XTextureData

@implementation XTextureData

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];

    if (self) {
        _path = (NSString *) [coder decodeObjectForKey:@"path"];
        _width = (uint64_t) [coder decodeInt64ForKey:@"width"];
        _height = (uint64_t) [coder decodeInt64ForKey:@"height"];
        _mipmapLevelCount = (uint64_t) [coder decodeInt64ForKey:@"mipmapLevelCount"];
        _pixelFormat = (MTLPixelFormat) [coder decodeInt64ForKey:@"pixelFormat"];
        _pixelDataOffset = (uint64_t) [coder decodeInt64ForKey:@"pixelDataOffset"];
        _pixelDataLength = (uint64_t) [coder decodeInt64ForKey:@"pixelDataLength"];
        _mipOffsets = (NSArray *) [coder decodeObjectForKey:@"mipOffsets"];
        _mipLengths = (NSArray *) [coder decodeObjectForKey:@"mipLengths"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_path forKey:@"path"];
    [coder encodeInt64:(int64_t) _width forKey:@"width"];
    [coder encodeInt64:(int64_t) _height forKey:@"height"];
    [coder encodeInt64:(int64_t) _mipmapLevelCount forKey:@"mipmapLevelCount"];
    [coder encodeInt64:(int64_t) _pixelFormat forKey:@"pixelFormat"];
    [coder encodeInt64:(int64_t) _pixelDataOffset forKey:@"pixelDataOffset"];
    [coder encodeInt64:(int64_t) _pixelDataLength forKey:@"pixelDataLength"];
    [coder encodeObject:_mipOffsets forKey:@"mipOffsets"];
    [coder encodeObject:_mipLengths forKey:@"mipLengths"];
}

@end

//MARK: - XMeshData

@implementation XMeshData

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];

    if (self) {
        _vertexCount = (uint64_t) [coder decodeInt64ForKey:@"vertexCount"];
        _indexCount = (uint64_t) [coder decodeInt64ForKey:@"indexCount"];
        _indexType = (uint64_t) [coder decodeInt64ForKey:@"indexType"];

        _chunkCount = (uint64_t) [coder decodeInt64ForKey:@"chunkCount"];
        _meshCount = (uint64_t) [coder decodeInt64ForKey:@"meshCount"];

        _opaqueChunkCount = (uint64_t) [coder decodeInt64ForKey:@"opaqueChunkCount"];
        _opaqueMeshCount = (uint64_t) [coder decodeInt64ForKey:@"opaqueMeshCount"];

        _alphaMaskedChunkCount = (uint64_t) [coder decodeInt64ForKey:@"alphaMaskedChunkCount"];
        _alphaMaskedMeshCount = (uint64_t) [coder decodeInt64ForKey:@"alphaMaskedMeshCount"];

        _transparentChunkCount = (uint64_t) [coder decodeInt64ForKey:@"transparentChunkCount"];
        _transparentMeshCount = (uint64_t) [coder decodeInt64ForKey:@"transparentMeshCount"];

        _materialCount = (uint64_t) [coder decodeInt64ForKey:@"materialCount"];

        _vertexData = (NSData *) [coder decodeObjectForKey:@"vertexData"];
        _normalData = (NSData *) [coder decodeObjectForKey:@"normalData"];
        _tangentData = (NSData *) [coder decodeObjectForKey:@"tangentData"];
        _uvData = (NSData *) [coder decodeObjectForKey:@"uvData"];

        _indexData = (NSData *) [coder decodeObjectForKey:@"indexData"];
        _chunkData = (NSData *) [coder decodeObjectForKey:@"chunkData"];
        _meshData = (NSData *) [coder decodeObjectForKey:@"meshData"];
        _materialData = (NSData *) [coder decodeObjectForKey:@"materialData"];

        _textures = (NSArray<XTextureData *> *) [coder decodeObjectForKey:@"textures"];
        _textureData = (NSData *) [coder decodeObjectForKey:@"textureData"];
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeInt64:(int64_t) _vertexCount forKey:@"vertexCount"];
    [coder encodeInt64:(int64_t) _indexCount forKey:@"indexCount"];
    [coder encodeInt64:(int64_t) _indexType forKey:@"indexType"];

    [coder encodeInt64:(int64_t) _chunkCount forKey:@"chunkCount"];
    [coder encodeInt64:(int64_t) _meshCount forKey:@"meshCount"];

    [coder encodeInt64:(int64_t) _opaqueChunkCount forKey:@"opaqueChunkCount"];
    [coder encodeInt64:(int64_t) _opaqueMeshCount forKey:@"opaqueMeshCount"];

    [coder encodeInt64:(int64_t) _alphaMaskedChunkCount forKey:@"alphaMaskedChunkCount"];
    [coder encodeInt64:(int64_t) _alphaMaskedMeshCount forKey:@"alphaMaskedMeshCount"];

    [coder encodeInt64:(int64_t) _transparentChunkCount forKey:@"transparentChunkCount"];
    [coder encodeInt64:(int64_t) _transparentMeshCount forKey:@"transparentMeshCount"];

    [coder encodeInt64:(int64_t) _materialCount forKey:@"materialCount"];

    [coder encodeObject:_vertexData forKey:@"vertexData"];
    [coder encodeObject:_normalData forKey:@"normalData"];
    [coder encodeObject:_tangentData forKey:@"tangentData"];
    [coder encodeObject:_uvData forKey:@"uvData"];

    [coder encodeObject:_indexData forKey:@"indexData"];
    [coder encodeObject:_chunkData forKey:@"chunkData"];
    [coder encodeObject:_meshData forKey:@"meshData"];
    [coder encodeObject:_materialData forKey:@"materialData"];

    [coder encodeObject:_textures forKey:@"textures"];
    [coder encodeObject:_textureData forKey:@"textureData"];
}

+ (nullable XMeshData *)meshWithFilename:(nonnull NSString *)filename {
    @autoreleasepool {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];

        if (!URL) {
            NSLog(@"Could not find resource '%@'", filename);
            return nil;
        }

        int fd = open(URL.fileSystemRepresentation, O_RDONLY, 0);

        if (fd < 0) {
            NSLog(@"Could not open '%@'", URL);
            return nil;
        }

        struct stat fileInfo;

        if (fstat(fd, &fileInfo)) {
            NSLog(@"Could not get file size for '%@'", URL);
            close(fd);
            return nil;
        }

        if (fileInfo.st_size < sizeof(XFileHeader)) {
            NSLog(@"File '%@' is too small", URL);
            close(fd);
            return nil;
        }

        unsigned char *mappedData = (unsigned char *) mmap(NULL, fileInfo.st_size, PROT_READ, MAP_PRIVATE, fd, 0);

        close(fd);

        if (mappedData == MAP_FAILED) {
            NSLog(@"Could not map '%@': %d", URL, errno);
            return nil;
        }

        unsigned char *fileData = mappedData;

        XFileHeader header = *(XFileHeader *) fileData;
        fileData += sizeof(XFileHeader);

        if (header.magic != MESH_MAGIC) {
            NSLog(@"File is not a mesh file");
            munmap(mappedData, fileInfo.st_size);
            return nil;
        }

        if (header.version != MESH_VERSION) {
            NSLog(@"Unsupported mesh file version");
            munmap(mappedData, fileInfo.st_size);
            return nil;
        }

        NSData *archivedData = [NSData dataWithBytesNoCopy:fileData
                                                    length:header.dataOffset
                                              freeWhenDone:NO];

        NSError *error;

        NSSet *allowedClasses = [NSSet setWithArray:@[
                [XMeshData class],
                [NSMutableArray class],
                [XTextureData class],
                [NSMutableString class],
                [NSData class],
                [NSNumber class],
                [NSString class]
        ]];

        [NSKeyedUnarchiver setClass:[XTextureData class] forClassName:@"Texture"];
        [NSKeyedUnarchiver setClass:[XMeshData class] forClassName:@"Mesh"];

        XMeshData *mesh = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
                                                                 fromData:archivedData
                                                                    error:&error];

        if (!mesh) {
            NSLog(@"Failed to decode mesh: %@", error);
            munmap(mappedData, fileInfo.st_size);
            return nil;
        }

        fileData += header.dataOffset;

        return mesh;
    }
}

@end
