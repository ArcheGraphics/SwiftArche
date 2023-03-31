//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import "GLTFAsset.h"
#import <ModelIO/ModelIO.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDLAsset (GLTFKit2)
+ (instancetype)assetWithGLTFAsset:(GLTFAsset *)asset;

+ (instancetype)assetWithGLTFAsset:(GLTFAsset *)asset
                   bufferAllocator:(nullable id <MDLMeshBufferAllocator>)bufferAllocator;
@end

NS_ASSUME_NONNULL_END
