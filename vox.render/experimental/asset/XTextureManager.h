//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "Config.h"

#import <Metal/Metal.h>
#import <Foundation/Foundation.h>

@class XTextureData;

//----------------------------------------------------

NSUInteger calculateMinMip(const XTextureData *_Nonnull textureAsset, NSUInteger maxTextureSize);

//----------------------------------------------------

@interface XTextureManager : NSObject

- (nonnull instancetype)initWithDevice:(nonnull id <MTLDevice>)device
                          commandQueue:(nonnull id <MTLCommandQueue>)commandQueue
                              heapSize:(NSUInteger)heapSize
                  permanentTextureSize:(NSUInteger)permanentTextureSize
                        maxTextureSize:(NSUInteger)maxTextureSize
                     useSparseTextures:(BOOL)useSparseTextures;

- (void)update:(NSUInteger)frameIndex deltaTime:(float)deltaTime forceTextureSize:(NSUInteger)forceTextureSize;

- (nullable id <MTLTexture>)getTexture:(unsigned int)hash
                         outCurrentMip:(nullable NSUInteger *)outCurrentMip;

- (void)addTextures:(nonnull NSArray<XTextureData *> *)textures data:(nonnull NSData *)data maxTextureSize:(NSUInteger)maxTextureSize;

- (void)makeResidentForEncoder:(nonnull id <MTLRenderCommandEncoder>)encoder;

#if USE_TEXTURE_STREAMING

- (void)setRequiredMip:(unsigned int)hash mipLevel:(NSUInteger)mipLevel;

- (void)setRequiredMip:(unsigned int)hash screenArea:(float)screenArea;

#endif

#if SUPPORT_PAGE_ACCESS_COUNTERS

- (void)updateAccessCounters:(NSUInteger)frameIndex cmdBuffer:(nonnull id <MTLCommandBuffer>)cmdBuffer;

#endif

@property(readonly, nonnull) NSString *info;

#if SUPPORT_PAGE_ACCESS_COUNTERS
@property(readonly) bool usePageAccessCounters;
#endif

@end
