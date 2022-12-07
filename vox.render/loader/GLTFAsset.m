//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "GLTFAsset.h"
#import "GLTFAssetReader.h"
#import <ImageIO/ImageIO.h>

const float LumensPerCandela = 1.0 / (4.0 * M_PI);

static NSString *g_dracoDecompressorClassName = nil;

GLTFAttributeSemantic GLTFAttributeSemanticPosition = @"POSITION";
GLTFAttributeSemantic GLTFAttributeSemanticNormal = @"NORMAL";
GLTFAttributeSemantic GLTFAttributeSemanticTangent = @"TANGENT";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord0 = @"TEXCOORD_0";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord1 = @"TEXCOORD_1";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord2 = @"TEXCOORD_2";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord3 = @"TEXCOORD_3";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord4 = @"TEXCOORD_4";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord5 = @"TEXCOORD_5";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord6 = @"TEXCOORD_6";
GLTFAttributeSemantic GLTFAttributeSemanticTexcoord7 = @"TEXCOORD_7";
GLTFAttributeSemantic GLTFAttributeSemanticColor0 = @"COLOR_0";
GLTFAttributeSemantic GLTFAttributeSemanticJoints0 = @"JOINTS_0";
GLTFAttributeSemantic GLTFAttributeSemanticJoints1 = @"JOINTS_1";
GLTFAttributeSemantic GLTFAttributeSemanticWeights0 = @"WEIGHTS_0";
GLTFAttributeSemantic GLTFAttributeSemanticWeights1 = @"WEIGHTS_1";

GLTFAnimationPath GLTFAnimationPathTranslation = @"translation";
GLTFAnimationPath GLTFAnimationPathRotation = @"rotation";
GLTFAnimationPath GLTFAnimationPathScale = @"scale";
GLTFAnimationPath GLTFAnimationPathWeights = @"weights";

float GLTFDegFromRad(float rad) {
    return rad * (180.0 / M_PI);
}

int GLTFBytesPerComponentForComponentType(GLTFComponentType type) {
    switch (type) {
        case GLTFComponentTypeByte:
        case GLTFComponentTypeUnsignedByte:
            return sizeof(UInt8);
        case GLTFComponentTypeShort:
        case GLTFComponentTypeUnsignedShort:
            return sizeof(UInt16);
        case GLTFComponentTypeUnsignedInt:
        case GLTFComponentTypeFloat:
            return sizeof(UInt32);
        default:
            break;
    }
    return 0;
}

int GLTFComponentCountForDimension(GLTFValueDimension dim) {
    switch (dim) {
        case GLTFValueDimensionScalar:
            return 1;
        case GLTFValueDimensionVector2:
            return 2;
        case GLTFValueDimensionVector3:
            return 3;
        case GLTFValueDimensionVector4:
            return 4;
        case GLTFValueDimensionMatrix2:
            return 4;
        case GLTFValueDimensionMatrix3:
            return 9;
        case GLTFValueDimensionMatrix4:
            return 16;
        default:
            break;
    }
    return 0;
}

NSData *GLTFCreateImageDataFromDataURI(NSString *uriData) {
    NSString *prefix = @"data:";
    if ([uriData hasPrefix:prefix]) {
        NSInteger prefixEnd = prefix.length;
        NSInteger firstComma = [uriData rangeOfString:@","].location;
        if (firstComma != NSNotFound) {
            NSString *mediaTypeAndTokenString = [uriData substringWithRange:NSMakeRange(prefixEnd, firstComma - prefixEnd)];
            NSArray *mediaTypeAndToken = [mediaTypeAndTokenString componentsSeparatedByString:@";"];
            if (mediaTypeAndToken.count > 0) {
                NSString *encodedImageData = [uriData substringFromIndex:firstComma + 1];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:encodedImageData
                                                                        options:NSDataBase64DecodingIgnoreUnknownCharacters];
                return imageData;
            }
        }
    }
    return nil;
}

@implementation GLTFObject

- (instancetype)init {
    if (self = [super init]) {
        _name = @"";
        _identifier = [NSUUID UUID];
        _extensions = @{};
    }
    return self;
}

@end

@implementation GLTFAsset

+ (nullable instancetype)assetWithURL:(NSURL *)url
                              options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                                error:(NSError **)error {
    __block NSError *internalError = nil;
    __block GLTFAsset *maybeAsset = nil;
    dispatch_semaphore_t loadSemaphore = dispatch_semaphore_create(0);
    [self loadAssetWithURL:url options:options handler:^(float progress,
            GLTFAssetStatus status,
            GLTFAsset *asset,
            NSError *error,
            BOOL *stop) {
        if (status == GLTFAssetStatusError || status == GLTFAssetStatusComplete) {
            internalError = error;
            maybeAsset = asset;
            dispatch_semaphore_signal(loadSemaphore);
        }
    }];
    dispatch_semaphore_wait(loadSemaphore, DISPATCH_TIME_FOREVER);
    if (error) {
        *error = internalError;
    }
    return maybeAsset;
}

+ (nullable instancetype)assetWithData:(NSData *)data
                               options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                                 error:(NSError **)error {
    __block NSError *internalError = nil;
    __block GLTFAsset *maybeAsset = nil;
    dispatch_semaphore_t loadSemaphore = dispatch_semaphore_create(1);
    [self loadAssetWithData:data options:options handler:^(float progress,
            GLTFAssetStatus status,
            GLTFAsset *asset,
            NSError *error,
            BOOL *stop) {
        if (status == GLTFAssetStatusError || status == GLTFAssetStatusComplete) {
            internalError = error;
            maybeAsset = asset;
            dispatch_semaphore_signal(loadSemaphore);
        }
    }];
    dispatch_semaphore_wait(loadSemaphore, DISPATCH_TIME_FOREVER);
    if (error) {
        *error = internalError;
    }
    return maybeAsset;
}

+ (void)loadAssetWithURL:(NSURL *)url
                 options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                 handler:(nullable GLTFAssetLoadingHandler)handler {
    [GLTFAssetReader loadAssetWithURL:url options:options handler:handler];
}

+ (void)loadAssetWithData:(NSData *)data
                  options:(NSDictionary<GLTFAssetLoadingOption, id> *)options
                  handler:(nullable GLTFAssetLoadingHandler)handler {
    [GLTFAssetReader loadAssetWithData:data options:options handler:handler];
}

+ (NSString *)dracoDecompressorClassName {
    return g_dracoDecompressorClassName;
}

+ (void)setDracoDecompressorClassName:(NSString *)dracoDecompressorClassName {
    g_dracoDecompressorClassName = dracoDecompressorClassName;
}

- (instancetype)init {
    if (self = [super init]) {
        _version = @"2.0";
        _extensionsUsed = @[];
        _extensionsRequired = @[];
        _accessors = @[];
        _animations = @[];
        _buffers = @[];
        _bufferViews = @[];
        _cameras = @[];
        _images = @[];
        _materials = @[];
        _meshes = @[];
        _nodes = @[];
        _samplers = @[];
        _scenes = @[];
        _skins = @[];
        _textures = @[];
    }
    return self;
}

@end

@implementation GLTFAccessor

- (instancetype)initWithBufferView:(GLTFBufferView *_Nullable)bufferView
                            offset:(NSInteger)offset
                     componentType:(GLTFComponentType)componentType
                         dimension:(GLTFValueDimension)dimension
                             count:(NSInteger)count
                        normalized:(BOOL)normalized {
    if (self = [super init]) {
        _bufferView = bufferView;
        _offset = offset;
        _componentType = componentType;
        _dimension = dimension;
        _count = count;
        _normalized = normalized;
        _minValues = @[];
        _maxValues = @[];
    }
    return self;
}

@end

@implementation GLTFAnimation

- (instancetype)initWithChannels:(NSArray<GLTFAnimationChannel *> *)channels
                        samplers:(NSArray<GLTFAnimationSampler *> *)samplers {
    if (self = [super init]) {
        _channels = [channels copy];
        _samplers = [samplers copy];
    }
    return self;
}

@end

@implementation GLTFAnimationTarget : GLTFObject

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _path = [path copy];
    }
    return self;
}

@end

@implementation GLTFAnimationChannel

- (instancetype)initWithTarget:(GLTFAnimationTarget *)target
                       sampler:(GLTFAnimationSampler *)sampler {
    if (self = [super init]) {
        _target = target;
        _sampler = sampler;
    }
    return self;
}

@end

@implementation GLTFAnimationSampler

- (instancetype)initWithInput:(GLTFAccessor *)input output:(GLTFAccessor *)output {
    if (self = [super init]) {
        _input = input;
        _output = output;
        _interpolationMode = GLTFInterpolationModeLinear;
    }
    return self;
}

@end

@implementation GLTFBuffer

- (instancetype)initWithLength:(NSInteger)length {
    if (self = [super init]) {
        _length = length;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        _length = data.length;
        _data = data;
    }
    return self;
}

@end

@implementation GLTFBufferView

- (instancetype)initWithBuffer:(GLTFBuffer *)buffer
                        length:(NSInteger)length
                        offset:(NSInteger)offset
                        stride:(NSInteger)stride {
    if (self = [super init]) {
        _buffer = buffer;
        _length = length;
        _offset = offset;
        _stride = stride;
    }
    return self;
}

@end

@implementation GLTFOrthographicProjectionParams

- (instancetype)init {
    if (self = [super init]) {
        _xMag = 1.0;
        _yMag = 1.0;
    }
    return self;
}

@end

@implementation GLTFPerspectiveProjectionParams

- (instancetype)init {
    if (self = [super init]) {
        _yFOV = M_PI_2;
        _aspectRatio = 1.0f;
    }
    return self;
}

@end

@implementation GLTFCamera

- (instancetype)initWithOrthographicProjection:(GLTFOrthographicProjectionParams *)orthographic {
    if (self = [super init]) {
        _orthographic = orthographic;
        _zNear = 1.0f;
        _zFar = 100.0f;
    }
    return self;
}

- (instancetype)initWithPerspectiveProjection:(GLTFPerspectiveProjectionParams *)perspective {
    if (self = [super init]) {
        _perspective = perspective;
        _zNear = 1.0f;
        _zFar = 100.0f; //  TODO: Handle infinite far projection
    }
    return self;
}

@end

@interface GLTFImage ()
@property(nonatomic, nullable) CGImageRef cachedImage;
@end

@implementation GLTFImage

- (instancetype)initWithURI:(NSURL *)uri {
    if (self = [super init]) {
        _uri = uri;
    }
    return self;
}

- (instancetype)initWithBufferView:(GLTFBufferView *)bufferView mimeType:(NSString *)mimeType {
    if (self = [super init]) {
        _bufferView = bufferView;
        _mimeType = mimeType;
    }
    return self;
}

- (instancetype)initWithCGImage:(CGImageRef)cgImage {
    if (self = [super init]) {
        _cachedImage = CGImageRetain(cgImage);
    }
    return self;
}

- (void)dealloc {
    CGImageRelease(_cachedImage);
}

- (CGImageRef)newCGImage {
    if (self.cachedImage) {
        return CGImageRetain(_cachedImage);
    }
    CGImageSourceRef imageSource = NULL;
    if (self.bufferView) {
        NSData *imageData = self.bufferView.buffer.data;
        const UInt8 *imageBytes = imageData.bytes + self.bufferView.offset;
        CFDataRef sourceData = CFDataCreate(NULL, imageBytes, self.bufferView.length);
        imageSource = CGImageSourceCreateWithData(sourceData, NULL);
        CFRelease(sourceData);
    } else if (self.uri) {
        if ([self.uri.scheme isEqual:@"data"]) {
            NSData *imageData = GLTFCreateImageDataFromDataURI(self.uri.absoluteString);
            imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
        } else {
            imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef) _uri, NULL);
        }
    }
    if (imageSource) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        CFRelease(imageSource);
        return image;
    }
    return NULL;
}

@end

@implementation GLTFLight

- (instancetype)init {
    return [self initWithType:GLTFLightTypeDirectional];
}

- (instancetype)initWithType:(GLTFLightType)type {
    if (self = [super init]) {
        _type = type;
        _color = (simd_float3) {1.0f, 1.0f, 1.0f};
        _intensity = 1.0f;
        _range = -1.0f;
        _innerConeAngle = 0.0f;
        _outerConeAngle = M_PI_4;
    }
    return self;
}

@end

@implementation GLTFPBRMetallicRoughnessParams

- (instancetype)init {
    if (self = [super init]) {
        _baseColorFactor = (simd_float4) {1.0f, 1.0f, 1.0f, 1.0f};
        _metallicFactor = 1.0f;
        _roughnessFactor = 1.0;
    }
    return self;
}

@end

@implementation GLTFPBRSpecularGlossinessParams

- (instancetype)init {
    if (self = [super init]) {
        _diffuseFactor = (simd_float4) {1.0f, 1.0f, 1.0f, 1.0f};
        _specularFactor = (simd_float3) {1.0f, 1.0f, 1.0f};
        _glossinessFactor = 1.0;
    }
    return self;
}

@end

@implementation GLTFClearcoatParams
@end

@implementation GLTFMaterial

- (instancetype)init {
    if (self = [super init]) {
        _emissiveFactor = (simd_float3) {0.0f, 0.0f, 0.0f};
        _alphaMode = GLTFAlphaModeOpaque;
        _alphaCutoff = 0.5f;
        _doubleSided = NO;
    }
    return self;
}

@end

@implementation GLTFMesh

- (instancetype)init {
    return [self initWithPrimitives:@[]];
}

- (instancetype)initWithPrimitives:(NSArray<GLTFPrimitive *> *)primitives {
    if (self = [super init]) {
        _primitives = [primitives copy];
    }
    return self;
}

@end

@implementation GLTFPrimitive

- (instancetype)initWithPrimitiveType:(GLTFPrimitiveType)primitiveType
                           attributes:(NSDictionary<NSString *, GLTFAccessor *> *)attributes {
    return [self initWithPrimitiveType:primitiveType attributes:attributes indices:nil];
}

- (instancetype)initWithPrimitiveType:(GLTFPrimitiveType)primitiveType
                           attributes:(NSDictionary<NSString *, GLTFAccessor *> *)attributes
                              indices:(GLTFAccessor *)indices {
    if (self = [super init]) {
        _primitiveType = primitiveType;
        _attributes = [attributes copy];
        _indices = indices;
    }
    return self;
}

@end

@implementation GLTFNode

@synthesize childNodes = _childNodes;

- (instancetype)init {
    if (self = [super init]) {
        _matrix = matrix_identity_float4x4;
        _rotation = simd_quaternion(0.0f, 0.0f, 0.0f, 1.0f);
        _scale = simd_make_float3(1.0f, 1.0f, 1.0f);
        _translation = simd_make_float3(0.0f, 0.0f, 0.0f);
        _childNodes = @[];
    }
    return self;
}

- (void)setChildNodes:(NSArray<GLTFNode *> *)childNodes {
    _childNodes = [childNodes copy];
    for (GLTFNode *child in _childNodes) {
        child.parentNode = self;
    }
}

@end

@implementation GLTFTextureSampler

- (instancetype)init {
    if (self = [super init]) {
        _magFilter = GLTFMagFilterLinear;
        _minMipFilter = GLTFMinMipFilterLinearNearest;
        _wrapS = GLTFAddressModeRepeat;
        _wrapT = GLTFAddressModeRepeat;
    }
    return self;
}

@end

@implementation GLTFScene
@end

@implementation GLTFSkin

- (instancetype)initWithJoints:(NSArray<GLTFNode *> *)joints {
    if (self = [super init]) {
        _joints = [joints copy];
    }
    return self;
}

@end

@implementation GLTFSparseStorage : GLTFObject

- (instancetype)initWithValues:(GLTFBufferView *)values
                   valueOffset:(NSInteger)valueOffset
                       indices:(GLTFBufferView *)indices
                   indexOffset:(NSInteger)indexOffset
            indexComponentType:(GLTFComponentType)indexComponentType
                         count:(NSInteger)count {
    if (self = [super init]) {
        _values = values;
        _valueOffset = valueOffset;
        _indices = indices;
        _indexOffset = indexOffset;
        _indexComponentType = indexComponentType;
        _count = count;
    }
    return self;
}

@end

@implementation GLTFTextureTransform

- (instancetype)init {
    if (self = [super init]) {
        _scale = (simd_float2) {1.0f, 1.0f};
    }
    return self;
}

- (simd_float4x4)matrix {
    float c = cosf(_rotation);
    float s = sinf(_rotation);
    simd_float4x4 S = {{
            {_scale.x, 0.0f, 0.0f, 0.0f},
            {0.0f, _scale.y, 0.0f, 0.0f},
            {0.0f, 0.0f, 1.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 1.0f}
    }};
    simd_float4x4 R = {{
            {c, -s, 0.0f, 0.0f},
            {s, c, 0.0f, 0.0f},
            {0.0f, 0.0f, 1.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 1.0f}
    }};
    simd_float4x4 T = {{
            {1.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 1.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 1.0f, 0.0f},
            {_offset.x, _offset.y, 0.0f, 1.0f}
    }};
    return simd_mul(T, simd_mul(R, S));
}

@end

@implementation GLTFTextureParams

- (instancetype)init {
    if (self = [super init]) {
        _scale = 1.0f;
        _extensions = @{};
    }
    return self;
}

@end

@implementation GLTFTexture

- (instancetype)initWithSource:(GLTFImage *)source {
    if (self = [super init]) {
        _source = source;
    }
    return self;
}

- (instancetype)init {
    return [self initWithSource:nil];
}

@end

// MARK: - Helpers
NSData *GLTFLineIndexDataForLineLoopIndexData(NSData *_Nonnull lineLoopIndexData,
        int lineLoopIndexCount,
        int bytesPerIndex) {
    if (lineLoopIndexCount < 2) {
        return nil;
    }

    int lineIndexCount = 2 * lineLoopIndexCount;
    size_t bufferSize = lineIndexCount * bytesPerIndex;
    unsigned char *lineIndices = malloc(bufferSize);
    unsigned char *lineIndicesCursor = lineIndices;
    unsigned char *lineLoopIndices = (unsigned char *) lineLoopIndexData.bytes;

    // Create a line from the last index element to the first index element.
    int lastLineIndexOffset = (lineIndexCount - 1) * bytesPerIndex;
    memcpy(lineIndicesCursor, lineLoopIndices, bytesPerIndex);
    memcpy(lineIndicesCursor + lastLineIndexOffset, lineLoopIndices, bytesPerIndex);
    lineIndicesCursor += bytesPerIndex;

    // Duplicate indices in-between to fill in the loop.
    for (int i = 1; i < lineLoopIndexCount; ++i) {
        memcpy(lineIndicesCursor, lineLoopIndices + (i * bytesPerIndex), bytesPerIndex);
        lineIndicesCursor += bytesPerIndex;
        memcpy(lineIndicesCursor, lineLoopIndices + (i * bytesPerIndex), bytesPerIndex);
        lineIndicesCursor += bytesPerIndex;
    }

    return [NSData dataWithBytesNoCopy:lineIndices
                                length:bufferSize
                          freeWhenDone:YES];
}

NSData *GLTFLineIndexDataForLineStripIndexData(NSData *_Nonnull lineStripIndexData,
        int lineStripIndexCount,
        int bytesPerIndex) {
    if (lineStripIndexCount < 2) {
        return nil;
    }

    int lineIndexCount = 2 * (lineStripIndexCount - 1);
    size_t bufferSize = lineIndexCount * bytesPerIndex;
    unsigned char *lineIndices = malloc(bufferSize);
    unsigned char *lineIndicesCursor = lineIndices;
    unsigned char *lineStripIndices = (unsigned char *) lineStripIndexData.bytes;

    // Place the first and last indices.
    int lastLineIndexOffset = (lineIndexCount - 1) * bytesPerIndex;
    int lastLineStripIndexOffset = (lineStripIndexCount - 1) * bytesPerIndex;
    memcpy(lineIndicesCursor, lineStripIndices, bytesPerIndex);
    memcpy(lineIndicesCursor + lastLineIndexOffset,
            lineStripIndices + lastLineStripIndexOffset,
            bytesPerIndex);
    lineIndicesCursor += bytesPerIndex;

    // Duplicate all indices in-between.
    for (int i = 1; i < lineStripIndexCount; ++i) {
        memcpy(lineIndicesCursor, lineStripIndices + (i * bytesPerIndex), bytesPerIndex);
        lineIndicesCursor += bytesPerIndex;
        memcpy(lineIndicesCursor, lineStripIndices + (i * bytesPerIndex), bytesPerIndex);
        lineIndicesCursor += bytesPerIndex;
    }

    return [NSData dataWithBytesNoCopy:lineIndices
                                length:bufferSize
                          freeWhenDone:YES];
}

NSData *GLTFTrianglesIndexDataForTriangleFanIndexData(NSData *_Nonnull triangleFanIndexData,
        int triangleFanIndexCount,
        int bytesPerIndex) {
    if (triangleFanIndexCount < 3) {
        return nil;
    }

    int trianglesIndexCount = 3 * (triangleFanIndexCount - 2);
    size_t bufferSize = trianglesIndexCount * bytesPerIndex;
    unsigned char *trianglesIndices = malloc(bufferSize);
    unsigned char *trianglesIndicesCursor = trianglesIndices;
    unsigned char *triangleFanIndices = (unsigned char *) triangleFanIndexData.bytes;

    for (int i = 1; i < triangleFanIndexCount; ++i) {
        memcpy(trianglesIndicesCursor, triangleFanIndices, bytesPerIndex);
        trianglesIndicesCursor += bytesPerIndex;
        memcpy(trianglesIndicesCursor, triangleFanIndices + (i * bytesPerIndex), 2 * bytesPerIndex);
        trianglesIndicesCursor += 2 * bytesPerIndex;
    }

    return [NSData dataWithBytesNoCopy:trianglesIndices
                                length:bufferSize
                          freeWhenDone:YES];
}

NSData *GLTFPackedUInt16DataFromPackedUInt8(UInt8 *bytes, size_t count) {
    size_t bufferSize = sizeof(UInt16) * count;
    UInt16 *shorts = malloc(bufferSize);
    // This is begging to be parallelized. Can this be done with Accelerate?
    for (int i = 0; i < count; ++i) {
        shorts[i] = (UInt16) bytes[i];
    }
    return [NSData dataWithBytesNoCopy:shorts length:bufferSize freeWhenDone:YES];
}

NSData *GLTFSCNPackedDataForAccessor(GLTFAccessor *accessor) {
    GLTFBufferView *bufferView = accessor.bufferView;
    GLTFBuffer *buffer = bufferView.buffer;
    size_t bytesPerComponent = GLTFBytesPerComponentForComponentType(accessor.componentType);
    size_t componentCount = GLTFComponentCountForDimension(accessor.dimension);
    size_t elementSize = bytesPerComponent * componentCount;
    size_t bufferLength = elementSize * accessor.count;
    void *bytes = malloc(bufferLength);
    if (bufferView != nil) {
        void *bufferViewBaseAddr = (void *) buffer.data.bytes + bufferView.offset;
        if (bufferView.stride == 0 || bufferView.stride == elementSize) {
            // Fast path
            memcpy(bytes, bufferViewBaseAddr + accessor.offset, accessor.count * elementSize);
        } else {
            // Slow path, element by element
            size_t sourceStride = bufferView.stride ?: elementSize;
            for (int i = 0; i < accessor.count; ++i) {
                void *src = bufferViewBaseAddr + (i * sourceStride) + accessor.offset;
                void *dest = bytes + (i * elementSize);
                memcpy(dest, src, elementSize);
            }
        }
    } else {
        // 3.6.2.3. Sparse Accessors
        // When accessor.bufferView is undefined, the sparse accessor is initialized as
        // an array of zeros of size (size of the accessor element) * (accessor.count) bytes.
        // https://www.khronos.org/registry/glTF/specs/2.0/glTF-2.0.html#sparse-accessors
        memset(bytes, 0, bufferLength);
    }
    if (accessor.sparse) {
        assert(accessor.sparse.indexComponentType == GLTFComponentTypeUnsignedShort ||
                accessor.sparse.indexComponentType == GLTFComponentTypeUnsignedInt);
        const void *baseSparseIndexBufferViewPtr = accessor.sparse.indices.buffer.data.bytes +
                accessor.sparse.indices.offset;
        const void *baseSparseIndexAccessorPtr = baseSparseIndexBufferViewPtr + accessor.sparse.indexOffset;

        const void *baseValueBufferViewPtr = accessor.sparse.values.buffer.data.bytes + accessor.sparse.values.offset;
        const void *baseSrcPtr = baseValueBufferViewPtr + accessor.sparse.valueOffset;
        const size_t srcValueStride = accessor.sparse.values.stride ?: elementSize;

        void *baseDestPtr = bytes;

        if (accessor.sparse.indexComponentType == GLTFComponentTypeUnsignedShort) {
            const UInt16 *sparseIndices = (UInt16 *) baseSparseIndexAccessorPtr;
            for (int i = 0; i < accessor.sparse.count; ++i) {
                UInt16 sparseIndex = sparseIndices[i];
                memcpy(baseDestPtr + sparseIndex * elementSize, baseSrcPtr + (i * srcValueStride), elementSize);
            }
        } else if (accessor.sparse.indexComponentType == GLTFComponentTypeUnsignedInt) {
            const UInt32 *sparseIndices = (UInt32 *) baseSparseIndexAccessorPtr;
            for (int i = 0; i < accessor.sparse.count; ++i) {
                UInt32 sparseIndex = sparseIndices[i];
                memcpy(baseDestPtr + sparseIndex * elementSize, baseSrcPtr + (i * srcValueStride), elementSize);
            }
        }
    }
    return [NSData dataWithBytesNoCopy:bytes length:bufferLength freeWhenDone:YES];
}

NSArray<NSNumber *> *GLTFKeyTimeArrayForAccessor(GLTFAccessor *accessor, NSTimeInterval maxKeyTime) {
    // TODO: This is actually not assured by the spec. We should convert from normalized int types when necessary
    assert(accessor.componentType == GLTFComponentTypeFloat);
    assert(accessor.dimension == GLTFValueDimensionScalar);
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:accessor.count];
    const void *bufferViewBaseAddr = accessor.bufferView.buffer.data.bytes + accessor.bufferView.offset;
    float scale = (maxKeyTime > 0) ? (1.0f / maxKeyTime) : 1.0f;
    for (int i = 0; i < accessor.count; ++i) {
        const float *x = bufferViewBaseAddr + (i * (accessor.bufferView.stride ?: sizeof(float))) + accessor.offset;
        NSNumber *value = @(x[0] * scale);
        [values addObject:value];
    }
    return values;
}

NSArray<NSArray<NSNumber *> *> *GLTFWeightsArraysForAccessor(GLTFAccessor *accessor, NSUInteger targetCount) {
    assert(accessor.componentType == GLTFComponentTypeFloat);
    assert(accessor.dimension == GLTFValueDimensionScalar);
    size_t keyframeCount = accessor.count / targetCount;
    NSMutableArray<NSMutableArray *> *weights = [NSMutableArray arrayWithCapacity:keyframeCount];
    for (int t = 0; t < targetCount; ++t) {
        [weights addObject:[NSMutableArray arrayWithCapacity:targetCount]];
    }
    const void *bufferViewBaseAddr = accessor.bufferView.buffer.data.bytes + accessor.bufferView.offset;
    const float *values = (float *) (bufferViewBaseAddr + accessor.offset);
    for (int k = 0; k < keyframeCount; ++k) {
        for (int t = 0; t < targetCount; ++t) {
            [weights[t] addObject:@(values[k * targetCount + t])];
        }
    }
    return weights;
}

id<MTLTexture> newTextureFromImage(GLTFImage *_Nonnull image, id<MTLDevice> device) {
    CGImageRef cgImage = [image newCGImage];

    int width = (int)CGImageGetWidth(cgImage);
    int height = (int)CGImageGetHeight(cgImage);
    int bytesPerRow = width * 4;
    void *data = malloc(bytesPerRow * height);
    memset(data, 0, bytesPerRow * height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    int bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);

    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm_sRGB
                                                                                                 width:width
                                                                                                height:height
                                                                                             mipmapped:NO];
    textureDescriptor.usage = MTLTextureUsageShaderRead;
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    [texture replaceRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0 withBytes:data bytesPerRow:bytesPerRow];

    CGContextRelease(context);
    CFRelease(colorSpace);
    free(data);

    return texture;
}

CGImageRef newImageFromTexture(id<MTLTexture> texture) {
    int width = (int)texture.width;
    int height = (int)texture.height;
    int bytesPerRow = width * 4;
    void *data = malloc(bytesPerRow * height);
    [texture getBytes:data bytesPerRow:bytesPerRow fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
    int bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CFRelease(colorSpace);
    free(data);
    return image;
}
