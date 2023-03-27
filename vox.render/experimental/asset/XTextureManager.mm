//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "XTextureManager.h"

#import "XAsset.h"

#import <unordered_map>
#import <vector>
#import <atomic>

#define USE_SEPARATE_COMMAND_QUEUE  (1)
#define MAX_BLIT_CMD_BUFFERS        (4)

#define TRACK_STREAMING_STATS       (1 && USE_TEXTURE_STREAMING)

#if TRACK_STREAMING_STATS

#import <mach/mach_time.h>

#endif

NSUInteger calculateMinMip(const XTextureData *texture, NSUInteger maxTextureSize) {
    NSUInteger textureSize = MAX(texture.width, texture.height);
    NSUInteger minMip = (NSUInteger) log2(MAX(textureSize / maxTextureSize, 1));

    if (minMip > texture.mipmapLevelCount)
        minMip = texture.mipmapLevelCount - 1;

    return minMip;
}

MTLRegion calculateMipRegion(const XTextureData *texture, NSUInteger mip) {
    return MTLRegionMake2D(0, 0, MAX(texture.width >> mip, 1), MAX(texture.height >> mip, 1));
}

NSUInteger calculateMipSizeInBlocks(NSUInteger size, NSUInteger blockSize, NSUInteger mip) {
    NSUInteger blocksWide = MAX(size / blockSize, 1U);

    return MAX(blocksWide >> mip, 1U);
}

//----------------------------------------------------

enum class RequestState {
    NONE,
    IN_QUEUE,
    PROCESSING
};

struct TextureRequest {
    NSUInteger mip;
    NSLock *lock;
    RequestState state;

#if TRACK_STREAMING_STATS
    uint64_t time;
#endif
};

struct TextureEntry {
    const XTextureData *desc;
    id <MTLTexture> texture;
    NSData *data;
    NSUInteger currentMip;
    NSUInteger requiredMip;

#if SUPPORT_SPARSE_TEXTURES
    std::vector<int> mipLastAccess;
#endif

#if SUPPORT_PAGE_ACCESS_COUNTERS
    id <MTLBuffer> accessCounters;
    NSUInteger accessCountersSize;
    std::vector<NSUInteger> accessCountersMipOffsets;
    std::vector<NSUInteger> accessCountersMipCount;
#endif

    TextureRequest request;
};

struct TextureUpdate {
    unsigned int hash;
    id <MTLTexture> texture;
    NSUInteger mip;
};

#if TRACK_STREAMING_STATS
struct StatsEntry {
    double sumLatency;
    unsigned int count;
    double maxLatency;
};
#endif

struct PendingBlit {
    id <MTLTexture> texture;
    id <MTLBuffer> tempBuffer;
    id <MTLTexture> originalTexture;
    const XTextureData *desc;
    NSUInteger baseMip;
    NSUInteger mipCount;
    NSUInteger mipOffset;
};

//----------------------------------------------------

@implementation XTextureManager {
    id <MTLDevice> _device;
    id <MTLCommandQueue> _blitQueue;
    id <MTLHeap> _heap;

    NSUInteger _permanentTextureSize;
    NSUInteger _maxTextureSize;

    std::unordered_map<unsigned int, TextureEntry> _textures;

#if USE_TEXTURE_STREAMING || !SUPPORT_MATERIAL_UPDATES
    NSCondition *_blitCondition;

    std::vector<PendingBlit> _pendingBlits;

    dispatch_semaphore_t _blitSemaphore;

    NSLock *_lockCompletedRequests;

    std::vector<TextureUpdate> _texturesUpdates;
#endif

#if USE_TEXTURE_STREAMING
    std::vector<id <MTLTexture>> _textureToDelete[MAX_FRAMES_IN_FLIGHT];

    dispatch_queue_t _loadingQueue;

    NSThread *_blitThread;

    std::atomic_uint _numRequests;
    std::atomic_uint _numFailedRequests;
#endif

#if SUPPORT_SPARSE_TEXTURES
    bool _useSparseTextures;
    bool _usePageAccessCounters;
#endif

#if TRACK_STREAMING_STATS
    StatsEntry _statsEntries[100];
    int _statsIndex;
    float _statsTimeAccum;
    float _averageLatency;
    float _maxLatency;
#endif
}

- (nonnull instancetype)initWithDevice:(nonnull id <MTLDevice>)device
                          commandQueue:(nonnull id <MTLCommandQueue>)commandQueue
                              heapSize:(NSUInteger)heapSize
                  permanentTextureSize:(NSUInteger)permanentTextureSize
                        maxTextureSize:(NSUInteger)maxTextureSize
                     useSparseTextures:(BOOL)useSparseTextures {
    self = [super init];
    if (self) {
        _device = device;

#if USE_SEPARATE_COMMAND_QUEUE
        _blitQueue = [_device newCommandQueue];
#else
        _blitQueue = commandQueue;
#endif

#if SUPPORT_SPARSE_TEXTURES
        _useSparseTextures = useSparseTextures;
        _usePageAccessCounters = false;

        if (_useSparseTextures) {
            _usePageAccessCounters = true;
        }
#endif // SUPPORT_SPARSE_TEXTURES

        // limit heap size to device limits
        {
            heapSize = MIN(heapSize, _device.maxBufferLength);
#if !TARGET_OS_IPHONE
            heapSize = MIN(heapSize, _device.recommendedMaxWorkingSetSize);
#endif // !TARGET_OS_IPHONE
        }

        MTLHeapDescriptor *heapDescriptor = [MTLHeapDescriptor new];
#if SUPPORT_SPARSE_TEXTURES
        if (_useSparseTextures) {
            heapDescriptor.type = MTLHeapTypeSparse;
        }
#endif
        heapDescriptor.cpuCacheMode = MTLCPUCacheModeDefaultCache;
        heapDescriptor.storageMode = MTLStorageModePrivate;
        heapDescriptor.size = heapSize;

        _heap = [_device newHeapWithDescriptor:heapDescriptor];
        _heap.label = @"Texture Heap";

        NSAssert(_heap, @"Failed to create texture heap.");

        _permanentTextureSize = permanentTextureSize;
        _maxTextureSize = maxTextureSize;

#if USE_TEXTURE_STREAMING
        dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_BACKGROUND, 0);
        _loadingQueue = dispatch_queue_create("com.apple.texture-loading", queueAttributes);

        _lockCompletedRequests = [NSLock new];

        _blitThread = [[NSThread alloc] initWithTarget:self selector:@selector(blitThreadLoop) object:nil];
        _blitCondition = [NSCondition new];
        _blitSemaphore = dispatch_semaphore_create(MAX_BLIT_CMD_BUFFERS);

        _blitThread.qualityOfService = NSQualityOfServiceBackground;
        [_blitThread start];
#endif
    }

    return self;
}

- (void)update:(NSUInteger)frameIndex deltaTime:(float)deltaTime forceTextureSize:(NSUInteger)forceTextureSize {
#if SUPPORT_PAGE_ACCESS_COUNTERS
    // Page access counters rely on sparse textures.
    if (_usePageAccessCounters)
        assert(_useSparseTextures);
#endif

#if USE_TEXTURE_STREAMING
    // Release reference to old textures
    _textureToDelete[frameIndex].clear();

#if SUPPORT_PAGE_ACCESS_COUNTERS
    if (_usePageAccessCounters)
        [self proccessPageAccessCounters:frameIndex];
#endif

#if SUPPORT_SPARSE_TEXTURES
    if (_useSparseTextures) {
        // Update mip access counters.
        for (auto &kv: _textures) {
            TextureEntry &te = kv.second;

            for (NSUInteger i = te.currentMip; i < te.requiredMip; ++i) {
                --te.mipLastAccess[i];
            }

            for (NSUInteger i = te.requiredMip; i < te.texture.firstMipmapInTail; ++i) {
                // Take into account changes due to TAA jitter.
                te.mipLastAccess[i] = MAX(MAX_FRAMES_IN_FLIGHT, TAA_JITTER_COUNT);
            }
        }

        [self dropMipsSparse];
    }
#endif // SUPPORT_SPARSE_TEXTURES

    [_lockCompletedRequests lock];

    // Process sucessfull texture updates
    if (_texturesUpdates.size() > 0) {
        _numRequests -= (uint) _texturesUpdates.size();

#if TRACK_STREAMING_STATS
        double tbConversionFactor = 0;

        mach_timebase_info_data_t timeInfo;
        if (mach_timebase_info(&timeInfo) == KERN_SUCCESS) {
            tbConversionFactor = timeInfo.numer / (1e6 * timeInfo.denom); // ns->ms
        }

        uint64_t currentTime = mach_absolute_time();
#endif

        for (const auto &update: _texturesUpdates) {
            assert(_textures.find(update.hash) != _textures.end());

            TextureEntry &te = _textures[update.hash];

            assert(te.request.state == RequestState::PROCESSING);

            // Need to keep reference to textures since GPU might still read them
            _textureToDelete[frameIndex].push_back(te.texture);

            te.texture = update.texture;
            te.currentMip = update.mip;
            te.request.state = RequestState::NONE;

#if TRACK_STREAMING_STATS
            double latency = (currentTime - te.request.time) * tbConversionFactor;

            _statsEntries[_statsIndex].sumLatency += latency;
            _statsEntries[_statsIndex].count++;
            _statsEntries[_statsIndex].maxLatency = MAX(_statsEntries[_statsIndex].maxLatency, latency);
#endif
        }

        _texturesUpdates.clear();
    }

    [_lockCompletedRequests unlock];

#if TRACK_STREAMING_STATS
    _statsTimeAccum += deltaTime;

    if (_statsTimeAccum > 1.0f) {
        if (_statsEntries[_statsIndex].count > 0)
            _averageLatency = _statsEntries[_statsIndex].sumLatency / _statsEntries[_statsIndex].count;
        else
            _averageLatency = 0.0f;

        _maxLatency = _statsEntries[_statsIndex].maxLatency;

        _statsTimeAccum = 0.0f;
        _statsIndex = (_statsIndex + 1) % 100;

        _statsEntries[_statsIndex].sumLatency = 0.0;
        _statsEntries[_statsIndex].count = 0;
        _statsEntries[_statsIndex].maxLatency = 0.0;
    }
#endif

    // Submit new streaming requests
    for (auto &kv: _textures) {
        TextureEntry &te = kv.second;

        if (forceTextureSize)
            te.requiredMip = calculateMinMip(te.desc, forceTextureSize);

#if SUPPORT_SPARSE_TEXTURES
        if (_useSparseTextures) {
            // Force tail to be permanent.
            te.requiredMip = MIN(te.requiredMip, te.texture.firstMipmapInTail);
        }
#endif
        if (te.currentMip != te.requiredMip && te.request.mip != te.requiredMip) {
            [self request:kv.first];
        }
    }

#if 0
    if(_numFailedRequests > 0)
        printf("Skipped %u requests because allocations failed.\n", (int)_numFailedRequests);
#endif

    _numFailedRequests = 0;

    // clear required mips for next frame
    for (auto &kv: _textures)
        kv.second.requiredMip = calculateMinMip(kv.second.desc, _permanentTextureSize);

#endif //USE_TEXTURE_STREAMING
}

- (id <MTLTexture>)getTexture:(unsigned int)hash outCurrentMip:(NSUInteger *)outCurrentMip {
    const auto it = _textures.find(hash);
    if (it != _textures.end()) {
        if (outCurrentMip)
            *outCurrentMip = it->second.currentMip;

        return it->second.texture;
    }

    return nil;
}

// Adds textures to a preallocated heap, decompressing the data from the data block.
- (void)addTextures:(NSArray<XTextureData *> *)textures data:(NSData *)data maxTextureSize:(NSUInteger)maxTextureSize {
    maxTextureSize = MIN(maxTextureSize, _maxTextureSize);

#if SUPPORT_SPARSE_TEXTURES
    id <MTLCommandBuffer> cmdBuffer;
    id <MTLResourceStateCommandEncoder> encoder;

    if (_useSparseTextures) {
        cmdBuffer = [_blitQueue commandBuffer];
        cmdBuffer.label = @"Initial Sparse Texture Cmd Buffer";

        encoder = [cmdBuffer resourceStateCommandEncoder];
        encoder.label = @"Map Sparse Texture Tail Encoder";
    }
#endif //SUPPORT_SPARSE_TEXTURES

    for (XTextureData *textureAsset in textures) {
        @autoreleasepool {
            // NOTE: It is generally not a good idea to cast a 64-bit hash key to 32-bits which
            // clips out half the key since it increases the chance of hash aliasing.  However,
            // since these are hash keys for relatively short strings, it is unlikely to
            // produce such hash aliasing.
            unsigned int textureHash = (uint32_t) textureAsset.path.hash;

            NSUInteger minMip = calculateMinMip(textureAsset, maxTextureSize);

#if USE_TEXTURE_STREAMING
#   if SUPPORT_SPARSE_TEXTURES
            if (!_useSparseTextures)
#   endif // SUPPORT_SPARSE_TEXTURES
                minMip = calculateMinMip(textureAsset, _permanentTextureSize);
#endif // USE_TEXTURE_STREAMING

            id <MTLTexture> texture = [self createTexture:textureAsset baseMip:minMip];
            assert(texture != nil);

            texture.label = [[NSString alloc] initWithFormat:@"%@ in Heap", textureAsset.path];

#if SUPPORT_SPARSE_TEXTURES
            if (_useSparseTextures) {
                // Map tail tiles
                [self updateTextureMappings:texture
                                       desc:textureAsset
                                    baseMip:texture.firstMipmapInTail
                                   mipCount:1
                                mappingMode:MTLSparseTextureMappingModeMap
                                  onEncoder:encoder];

                minMip = texture.firstMipmapInTail;
            }

#endif // SUPPORT_SPARSE_TEXTURES

            TextureEntry te;
            te.texture = texture;
            te.desc = textureAsset;
            te.data = data;
            te.currentMip = minMip;
            te.requiredMip = minMip;

#if SUPPORT_SPARSE_TEXTURES
            if (_useSparseTextures) {
                te.mipLastAccess.assign(texture.firstMipmapInTail, 0);

#if SUPPORT_PAGE_ACCESS_COUNTERS
                if (_usePageAccessCounters) {
                    [self initPageAccessCountersBuffer:te];
                }
#endif // SUPPORT_PAGE_ACCESS_COUNTERS
            }
#endif // SUPPORT_SPARSE_TEXTURES

            te.request.mip = minMip;
            te.request.lock = [NSLock new];
            te.request.state = RequestState::NONE;

            _textures[textureHash] = te;
        }
    }

#if SUPPORT_SPARSE_TEXTURES
    if (_useSparseTextures) {
        [encoder endEncoding];
        [cmdBuffer commit];
    }
#endif // SUPPORT_SPARSE_TEXTURES

    // Load permanent data into textures
    for (XTextureData *textureAsset in textures) {
        @autoreleasepool {
            TextureEntry &te = _textures[(unsigned int) textureAsset.path.hash];

            NSData *textureData = [NSData dataWithBytesNoCopy:(uint8_t *) te.data.bytes + te.desc.pixelDataOffset
                                                       length:te.desc.pixelDataLength freeWhenDone:NO];

            NSUInteger mipCount = te.desc.mipmapLevelCount - te.currentMip;
            NSUInteger mipOffset = te.currentMip;

#if SUPPORT_SPARSE_TEXTURES
            // Texture manager creates sparse textures with full
            // mip chain so blit doesn't require offset.
            if (_useSparseTextures) {
                mipOffset = 0;
            }
#endif

            const PendingBlit pendingBlit = [self loadMipsToTexture:te.texture desc:te.desc textureData:textureData
                                                            baseMip:te.currentMip mipCount:mipCount mipOffset:mipOffset];

            id <MTLCommandBuffer> cmdBuffer = [_blitQueue commandBuffer];
            cmdBuffer.label = @"Initial Texture Blit Cmd Buffer";

            [self encodePendingBlits:&pendingBlit count:1
#if SUPPORT_SPARSE_TEXTURES
               updateTextureMappings:false
#endif
                         onCmdBuffer:cmdBuffer];

            [cmdBuffer commit];
        }
    }
}

#if USE_TEXTURE_STREAMING

- (void)request:(unsigned int)hash {
    const auto it = _textures.find(hash);
    if (it == _textures.end())
        return;

    TextureEntry &te = it->second;

#if SUPPORT_SPARSE_TEXTURES
    if (_useSparseTextures && te.requiredMip > te.currentMip) {
        // Dropping mips of sparse textures happens on main update.
        return;
    }
#endif //SUPPORT_SPARSE_TEXTURES

    [te.request.lock lock];

    assert(te.requiredMip != te.currentMip);

    bool newRequest = (te.request.state == RequestState::NONE);

    if (te.request.state != RequestState::PROCESSING) {
        te.request.mip = te.requiredMip;
        te.request.state = RequestState::IN_QUEUE;
    }

    assert(te.request.mip != te.currentMip);

#if TRACK_STREAMING_STATS
    if (newRequest)
        te.request.time = mach_absolute_time();
#endif

    [te.request.lock unlock];

    if (!newRequest)
        return;

    ++_numRequests;

    dispatch_async(_loadingQueue, ^{
        [te.request.lock lock];

        assert(te.request.state == RequestState::IN_QUEUE);

        te.request.state = RequestState::PROCESSING;

        NSUInteger mipLevel = te.request.mip;

        assert(mipLevel != te.currentMip);

        [te.request.lock unlock];

#if SUPPORT_SPARSE_TEXTURES
        const bool dropMips = te.currentMip < mipLevel;
#else
        const bool dropMips = te.texture.mipmapLevelCount > te.desc.mipmapLevelCount - mipLevel;
#endif

        id <MTLTexture> newTexture;

#if SUPPORT_SPARSE_TEXTURES
        // Dropping mips of sparse textures happens on main thread.
        assert(!(self->_useSparseTextures && dropMips));

        if (self->_useSparseTextures) {
            newTexture = te.texture;
        } else
#endif
        {
            newTexture = [self createTexture:te.desc baseMip:mipLevel];

            if (newTexture == nil) {
                [te.request.lock lock];

                te.request.mip = te.currentMip; // reset request so we try again later
                te.request.state = RequestState::NONE;

                [te.request.lock unlock];

                --self->_numRequests;
                ++self->_numFailedRequests;

                return;
            }
        }

        newTexture.label = te.desc.path;

        if (!newTexture.label) {
            newTexture.label = @"Unnamed Material";
        }

        if (dropMips) {
            id <MTLCommandBuffer> cmdBuffer = [self->_blitQueue commandBuffer];
            cmdBuffer.label = @"Drop Mips Cmd Buffer";
            [self dropMips:hash desc:te.desc texture:newTexture originalTexture:te.texture minMip:mipLevel currentMip:te.currentMip
                 cmdBuffer:cmdBuffer];

            [cmdBuffer addCompletedHandler:^(id <MTLCommandBuffer> _Nonnull) {
                TextureUpdate update;
                update.hash = hash;
                update.texture = newTexture;
                update.mip = mipLevel;

                [self->_lockCompletedRequests lock];

                self->_texturesUpdates.push_back(update);

                [self->_lockCompletedRequests unlock];
            }];

            [cmdBuffer commit];
        } else {
            [self addMips:hash desc:te.desc texture:newTexture originalTexture:te.texture data:te.data minMip:mipLevel currentMip:te.currentMip];
        }
    });
}

- (void)setRequiredMip:(unsigned int)hash mipLevel:(NSUInteger)mipLevel {
    const auto it = _textures.find(hash);
    if (it == _textures.end())
        return;

    NSUInteger topMip = calculateMinMip(it->second.desc, _maxTextureSize);
    NSUInteger botMip = calculateMinMip(it->second.desc, _permanentTextureSize);

    mipLevel = MAX(topMip, MIN(botMip, mipLevel));

    it->second.requiredMip = MIN(mipLevel, it->second.requiredMip);
}

- (void)setRequiredMip:(unsigned int)hash screenArea:(float)screenArea {
    const auto it = _textures.find(hash);
    if (it == _textures.end())
        return;

    NSUInteger topMipmapTexelArea = it->second.desc.width * it->second.desc.height;

    NSUInteger mipLevel = (0.5f * log2(topMipmapTexelArea / screenArea));

    [self setRequiredMip:hash mipLevel:mipLevel];
}

#endif

- (PendingBlit)loadMipsToTexture:(id <MTLTexture>)texture desc:(const XTextureData *)desc textureData:(NSData *)textureData
                         baseMip:(NSUInteger)baseMip mipCount:(NSUInteger)mipCount mipOffset:(NSUInteger)mipOffset {
    NSUInteger blockSize, bytesPerBlock;
    getPixelFormatBlockDesc(texture.pixelFormat, &blockSize, &bytesPerBlock);

    NSUInteger blocksWide = calculateMipSizeInBlocks(desc.width, blockSize, baseMip);
    NSUInteger blocksHigh = calculateMipSizeInBlocks(desc.height, blockSize, baseMip);

    NSUInteger tempBufferSize = 0;

    for (NSUInteger i = 0; i < mipCount; ++i) {
        NSUInteger bytesPerRow = MAX(blocksWide >> i, 1U) * bytesPerBlock;
        NSUInteger bytesPerImage = MAX(blocksHigh >> i, 1U) * bytesPerRow;

        tempBufferSize += bytesPerImage;
    }

    id <MTLBuffer> tempBuffer = [_device newBufferWithLength:tempBufferSize options:0];
    NSUInteger tempBufferOffset = 0;

    for (NSUInteger mip = baseMip; mip < baseMip + mipCount; ++mip) {
        NSUInteger bytesPerRow = blocksWide * bytesPerBlock;

        NSUInteger mipDataOffset = [desc.mipOffsets[mip] unsignedIntegerValue];
        NSUInteger mipDataSize = [desc.mipLengths[mip] unsignedIntegerValue];

        NSData *compressedMipData = [NSData dataWithBytesNoCopy:((uint8_t *) textureData.bytes + mipDataOffset)
                                                         length:mipDataSize freeWhenDone:NO];

        NSData *mipData = uncompressData(compressedMipData);

        NSUInteger bytesPerImage = bytesPerRow * blocksHigh;

        memcpy((uint8_t *) tempBuffer.contents + tempBufferOffset, mipData.bytes, bytesPerImage);

        tempBufferOffset += bytesPerImage;

        blocksWide = MAX(blocksWide >> 1U, 1U);
        blocksHigh = MAX(blocksHigh >> 1U, 1U);
    }

    PendingBlit pendingBlit;
    pendingBlit.texture = texture;
    pendingBlit.tempBuffer = tempBuffer;
    pendingBlit.originalTexture = nil;
    pendingBlit.desc = desc;
    pendingBlit.baseMip = baseMip;
    pendingBlit.mipCount = mipCount;
    pendingBlit.mipOffset = mipOffset;

    return pendingBlit;
}

- (void)addMips:(unsigned int)hash desc:(const XTextureData *)desc
        texture:(id <MTLTexture>)texture originalTexture:(id <MTLTexture>)originalTexture
           data:(NSData *)data
         minMip:(NSUInteger)minMip currentMip:(NSUInteger)currentMip {
    assert(minMip < desc.mipmapLevelCount);

    NSData *textureData = [NSData dataWithBytesNoCopy:(uint8_t *) data.bytes + desc.pixelDataOffset
                                               length:desc.pixelDataLength freeWhenDone:NO];

    NSUInteger mipCount = currentMip - minMip;
    NSUInteger mipOffset = minMip;

#if SUPPORT_SPARSE_TEXTURES
    // Texture manager creates sparse textures with full mip chain so blit doesn't require offset.
    if (_useSparseTextures) {
        mipOffset = 0;
    }
#endif

    PendingBlit pendingBlit = [self loadMipsToTexture:texture desc:desc textureData:textureData
                                              baseMip:minMip mipCount:mipCount mipOffset:mipOffset];

#if SUPPORT_SPARSE_TEXTURES
    if (!_useSparseTextures)
#endif
    {
        pendingBlit.originalTexture = originalTexture;
    }

    [_blitCondition lock];

    _pendingBlits.push_back(pendingBlit);

    [_blitCondition signal];
    [_blitCondition unlock];
}

- (void)dropMips:(unsigned int)hash desc:(const XTextureData *)desc
         texture:(id <MTLTexture>)texture originalTexture:(id <MTLTexture>)originalTexture
          minMip:(NSUInteger)minMip currentMip:(NSUInteger)currentMip
       cmdBuffer:(id <MTLCommandBuffer>)cmdBuffer {
    assert(texture != nil);
    assert(minMip < desc.mipmapLevelCount);
    assert(minMip > currentMip);

#if SUPPORT_SPARSE_TEXTURES
    if (_useSparseTextures) {
        assert(minMip <= texture.firstMipmapInTail);

        id <MTLResourceStateCommandEncoder> encoder = [cmdBuffer resourceStateCommandEncoder];
        encoder.label = @"Sparse Texture Unmapping Encoder";

        [self updateTextureMappings:texture
                               desc:desc
                            baseMip:currentMip
                           mipCount:minMip - currentMip
                        mappingMode:MTLSparseTextureMappingModeUnmap
                          onEncoder:encoder];

        [encoder endEncoding];
    } else
#endif // SUPPORT_SPARSE_TEXTURES
    {
        // blit temp texture to heap
        id <MTLBlitCommandEncoder> blitEncoder = [cmdBuffer blitCommandEncoder];
        blitEncoder.label = @"Texture Blit Encoder";

        [blitEncoder copyFromTexture:originalTexture
                         sourceSlice:0
                         sourceLevel:originalTexture.mipmapLevelCount - texture.mipmapLevelCount
                           toTexture:texture
                    destinationSlice:0
                    destinationLevel:0
                          sliceCount:1
                          levelCount:texture.mipmapLevelCount];

        [blitEncoder endEncoding];
    }
}

- (void)encodePendingBlits:(const PendingBlit *)blits count:(NSUInteger)numBlits
#if SUPPORT_SPARSE_TEXTURES
     updateTextureMappings:(bool)updateTextureMappings
#endif
               onCmdBuffer:(id <MTLCommandBuffer>)cmdBuffer {
#if SUPPORT_SPARSE_TEXTURES
    if (updateTextureMappings) {
        id <MTLResourceStateCommandEncoder> encoder = [cmdBuffer resourceStateCommandEncoder];
        encoder.label = @"Sparse Texture Mapping Encoder";

        for (NSUInteger i = 0; i < numBlits; ++i) {
            [self updateTextureMappings:blits[i].texture
                                   desc:blits[i].desc
                                baseMip:blits[i].baseMip
                               mipCount:blits[i].mipCount
                            mappingMode:MTLSparseTextureMappingModeMap
                              onEncoder:encoder];
        }

        [encoder endEncoding];
    }
#endif

    id <MTLBlitCommandEncoder> blitEncoder = [cmdBuffer blitCommandEncoder];
    blitEncoder.label = @"Texture Blit Encoder";

    for (NSUInteger i = 0; i < numBlits; ++i) {
        if (blits[i].originalTexture) {
            // copy mips in the original texture
            [blitEncoder copyFromTexture:blits[i].originalTexture
                             sourceSlice:0
                             sourceLevel:0
                               toTexture:blits[i].texture
                        destinationSlice:0
                        destinationLevel:blits[i].texture.mipmapLevelCount - blits[i].originalTexture.mipmapLevelCount
                              sliceCount:1
                              levelCount:blits[i].originalTexture.mipmapLevelCount];
        }

        NSUInteger blockSize, bytesPerBlock;
        getPixelFormatBlockDesc(blits[i].texture.pixelFormat, &blockSize, &bytesPerBlock);

        const NSUInteger blocksWide = calculateMipSizeInBlocks(blits[i].desc.width, blockSize, 0);
        const NSUInteger blocksHigh = calculateMipSizeInBlocks(blits[i].desc.height, blockSize, 0);

        NSUInteger tempBufferOffset = 0;

        for (NSUInteger mip = blits[i].baseMip; mip < blits[i].baseMip + blits[i].mipCount; ++mip) {
            NSUInteger bytesPerRow = MAX(blocksWide >> mip, 1U) * bytesPerBlock;
            NSUInteger bytesPerImage = MAX(blocksHigh >> mip, 1U) * bytesPerRow;

            MTLRegion region = calculateMipRegion(blits[i].desc, mip);

            [blitEncoder copyFromBuffer:blits[i].tempBuffer sourceOffset:tempBufferOffset
                      sourceBytesPerRow:bytesPerRow sourceBytesPerImage:bytesPerImage sourceSize:region.size
                              toTexture:blits[i].texture destinationSlice:0 destinationLevel:mip - blits[i].mipOffset destinationOrigin:region.origin];

            tempBufferOffset += bytesPerImage;
        }
    }

    [blitEncoder endEncoding];
}

#if SUPPORT_SPARSE_TEXTURES

- (void)dropMipsSparse {
    assert(_useSparseTextures);

    id <MTLCommandBuffer> cmdBuffer = [_blitQueue commandBuffer];
    cmdBuffer.label = @"Drop Mips Cmd Buffer";

    id <MTLResourceStateCommandEncoder> encoder = [cmdBuffer resourceStateCommandEncoder];
    encoder.label = @"Sparse Texture Unmapping Encoder";

    for (auto &kv: _textures) {
        TextureEntry &te = kv.second;

        NSUInteger firstGPUMip = te.currentMip;

        // calculate whats the first mip that the GPU is accessing
        while (firstGPUMip < te.requiredMip && te.mipLastAccess[firstGPUMip] <= 0)
            ++firstGPUMip;

        if (firstGPUMip - te.currentMip > 0) {
            [te.request.lock lock];

            if (te.request.state != RequestState::NONE) {
                [te.request.lock unlock];
                continue;
            }
            te.request.mip = firstGPUMip;
            te.request.state = RequestState::PROCESSING;

#if TRACK_STREAMING_STATS
            te.request.time = mach_absolute_time();
#endif

            [te.request.lock unlock];

            ++_numRequests;

            // drop mips
            [self updateTextureMappings:te.texture
                                   desc:te.desc
                                baseMip:te.currentMip
                               mipCount:firstGPUMip - te.currentMip
                            mappingMode:MTLSparseTextureMappingModeUnmap
                              onEncoder:encoder];

            [cmdBuffer addCompletedHandler:^(id <MTLCommandBuffer> _Nonnull) {
                TextureUpdate update;
                update.hash = kv.first;
                update.texture = te.texture;
                update.mip = firstGPUMip;

                [self->_lockCompletedRequests lock];

                self->_texturesUpdates.push_back(update);

                [self->_lockCompletedRequests unlock];
            }];
        }
    }

    [encoder endEncoding];
    [cmdBuffer commit];
}

#endif // SUPPORT_SPARSE_TEXTURES

- (id <MTLTexture>)createTexture:(const XTextureData *)desc baseMip:(NSUInteger)baseMip {
    MTLTextureDescriptor *texDesc = [[MTLTextureDescriptor alloc] init];
    texDesc.width = MAX(desc.width >> baseMip, 1);
    texDesc.height = MAX(desc.height >> baseMip, 1);
    texDesc.mipmapLevelCount = MAX(desc.mipmapLevelCount - baseMip, 1);
    texDesc.pixelFormat = desc.pixelFormat;
    texDesc.textureType = MTLTextureType2D;
    texDesc.storageMode = MTLStorageModePrivate;

    return [_heap newTextureWithDescriptor:texDesc];
}

- (void)blitThreadLoop {
    while ([[NSThread currentThread] isCancelled] == NO) {
        @autoreleasepool {
            dispatch_semaphore_wait(_blitSemaphore, DISPATCH_TIME_FOREVER);

            id <MTLCommandBuffer> cmdBuffer = [_blitQueue commandBuffer];
            cmdBuffer.label = @"Texture Streaming Cmd Buffer";

            [cmdBuffer addCompletedHandler:^(id <MTLCommandBuffer> buffer) {
                dispatch_semaphore_signal(self->_blitSemaphore);
            }];

            [_blitCondition lock];
            while (_pendingBlits.size() == 0) {
                [_blitCondition wait];
            }

            std::vector<PendingBlit> pendingBlits;

            std::swap(pendingBlits, _pendingBlits);

            [_blitCondition unlock];

            [self encodePendingBlits:&pendingBlits[0] count:pendingBlits.size()
#if SUPPORT_SPARSE_TEXTURES
               updateTextureMappings:_useSparseTextures
#endif
                         onCmdBuffer:cmdBuffer];

            [cmdBuffer addCompletedHandler:^(id <MTLCommandBuffer> _Nonnull) {
                [self->_lockCompletedRequests lock];

                for (auto &blit: pendingBlits) {
                    TextureUpdate update;

                    // NOTE: It is generally not a good idea to cast a 64-bit hash key to 32-bits which
                    // clips out half the key since it increases the chance of hash aliasing.  However,
                    // since these are hash keys for relatively short strings, it is unlikely to
                    // produce such hash aliasing.
                    update.hash = (uint32_t) blit.desc.path.hash;
                    update.texture = blit.texture;
                    update.mip = blit.baseMip;

                    self->_texturesUpdates.push_back(update);
                }

                [self->_lockCompletedRequests unlock];
            }];

            [cmdBuffer commit];
        }
    }
}

#if SUPPORT_SPARSE_TEXTURES

- (void)updateTextureMappings:(id <MTLTexture>)texture
                         desc:(const XTextureData *)desc
                      baseMip:(NSUInteger)baseMip
                     mipCount:(NSUInteger)mipCount
                  mappingMode:(MTLSparseTextureMappingMode)mappingMode
                    onEncoder:(id <MTLResourceStateCommandEncoder>)encoder {
    assert(_useSparseTextures);

    MTLSize tileSize = [_device sparseTileSizeWithTextureType:MTLTextureType2D pixelFormat:desc.pixelFormat sampleCount:1];

    for (NSUInteger i = 0; i < mipCount; ++i) {
        MTLRegion pixelRegion = calculateMipRegion(desc, baseMip + i);
        MTLRegion tileRegion;

        [_device convertSparsePixelRegions:&pixelRegion
                             toTileRegions:&tileRegion
                              withTileSize:tileSize
                             alignmentMode:MTLSparseTextureRegionAlignmentModeOutward
                                numRegions:1];

        [encoder updateTextureMapping:texture mode:mappingMode region:tileRegion mipLevel:(baseMip + i) slice:0];
    }
}

#if SUPPORT_PAGE_ACCESS_COUNTERS

- (void)initPageAccessCountersBuffer:(TextureEntry &)te {
    assert(_usePageAccessCounters);

    te.accessCountersSize = 0;

    if (te.texture.firstMipmapInTail != 0) {
        MTLSize tileSize = [_device sparseTileSizeWithTextureType:MTLTextureType2D pixelFormat:te.desc.pixelFormat sampleCount:1];

        for (int i = 0; i < te.texture.firstMipmapInTail; ++i) {
            te.accessCountersMipOffsets.push_back(te.accessCountersSize);

            MTLRegion pixelRegion = calculateMipRegion(te.desc, i);
            MTLRegion tileRegion;

            [_device convertSparsePixelRegions:&pixelRegion
                                 toTileRegions:&tileRegion
                                  withTileSize:tileSize
                                 alignmentMode:MTLSparseTextureRegionAlignmentModeOutward
                                    numRegions:1];

            NSUInteger numCountersInMip = tileRegion.size.width * tileRegion.size.height;

            te.accessCountersMipCount.push_back(numCountersInMip);

            te.accessCountersSize += numCountersInMip;
        }

        te.accessCounters = [_device newBufferWithLength:(sizeof(uint) * te.accessCountersSize * MAX_FRAMES_IN_FLIGHT) options:0];
        te.accessCounters.label = @"Texture Access Counters";
    }
}

- (void)proccessPageAccessCounters:(NSUInteger)frameIndex {
    assert(_usePageAccessCounters);

    for (auto &kv: _textures) {
        TextureEntry &te = kv.second;

        uint *frameAccessCounters = (uint *) (te.accessCounters.contents) + (frameIndex * te.accessCountersSize);

        if (te.texture.firstMipmapInTail == 0)
            continue;

        te.requiredMip = calculateMinMip(te.desc, _permanentTextureSize);

        for (int i = 0; i < te.texture.firstMipmapInTail; ++i) {
            uint *counters = frameAccessCounters + te.accessCountersMipOffsets[i];

            uint counterSum = 0;

            for (NSUInteger j = 0; j < te.accessCountersMipCount[i]; ++j)
                counterSum += counters[j];

            if (counterSum > 0) {
                [self setRequiredMip:kv.first mipLevel:i];
                break;
            }
        }
    }
}

- (void)updateAccessCounters:(NSUInteger)frameIndex cmdBuffer:(nonnull id <MTLCommandBuffer>)cmdBuffer {
    assert(_usePageAccessCounters);

    // Request new access counters
    id <MTLBlitCommandEncoder> encoder = [cmdBuffer blitCommandEncoder];

    for (auto &kv: _textures) {
        if (kv.second.texture.firstMipmapInTail == 0)
            continue;

        MTLSize tileSize = [_device sparseTileSizeWithTextureType:MTLTextureType2D pixelFormat:kv.second.desc.pixelFormat sampleCount:1];

        NSUInteger frameAccessCountersOffset = frameIndex * kv.second.accessCountersSize;

        for (int i = 0; i < kv.second.texture.firstMipmapInTail; ++i) {
            MTLRegion pixelRegion = calculateMipRegion(kv.second.desc, i);
            MTLRegion tileRegion;

            [_device convertSparsePixelRegions:&pixelRegion
                                 toTileRegions:&tileRegion
                                  withTileSize:tileSize
                                 alignmentMode:MTLSparseTextureRegionAlignmentModeOutward
                                    numRegions:1];

            [encoder getTextureAccessCounters:kv.second.texture region:tileRegion mipLevel:i slice:0
                                resetCounters:YES
                               countersBuffer:kv.second.accessCounters
                         countersBufferOffset:sizeof(uint) * (frameAccessCountersOffset + kv.second.accessCountersMipOffsets[i])];
        }
    }

    [encoder endEncoding];
}

#endif // SUPPORT_PAGE_ACCESS_COUNTERS

- (void)makeResidentForEncoder:(nonnull id <MTLRenderCommandEncoder>)encoder {
    [encoder useHeap:_heap stages:MTLRenderStageVertex];
}

#endif //SUPPORT_SPARSE_TEXTURES

- (NSString *)info {
    NSMutableString *output = [NSMutableString new];

    const float mbScale = 1.0f / (1024 * 1024);

    NSString *baseInfo = [NSString stringWithFormat:@"Texture Heap: %05.1f / %.1f MiB\n(%.2f%%)\n",
                                                    _heap.usedSize * mbScale, _heap.size * mbScale,
                                                    100.0f * (double) _heap.usedSize / (double) _heap.size];

    [output appendString:baseInfo];

#if USE_TEXTURE_STREAMING
    NSString *streamingInfo = [NSString stringWithFormat:@"Pending Streaming Requests: %03u\n", (uint) _numRequests];

    [output appendString:streamingInfo];

#if TRACK_STREAMING_STATS
    double averageLatency100 = 0.0f;
    int count = 0;
    double maxLatency100 = 0.0f;

    for (int i = 0; i < 100; ++i) {
        if (i == _statsIndex)
            continue;

        averageLatency100 += _statsEntries[i].sumLatency;
        count += _statsEntries[i].count;
        maxLatency100 = MAX(_statsEntries[i].maxLatency, maxLatency100);
    }

    if (count > 0)
        averageLatency100 /= count;
    else
        averageLatency100 = 0.0f;

    [output appendString:[NSString stringWithFormat:@"Latency:\n"]];
    [output appendString:[NSString stringWithFormat:@"  1s - Mean: %06.2f - Max: %06.2f\n", _averageLatency, _maxLatency]];
    [output appendString:[NSString stringWithFormat:@"100s - Mean: %06.2f - Max: %06.2f\n", averageLatency100, maxLatency100]];
#endif // TRACK_STREAMING_STATS
#endif // USE_TEXTURE_STREAMING

    return output;
}

@end
