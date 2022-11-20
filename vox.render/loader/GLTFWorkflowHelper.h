//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "GLTFAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLTFWorkflowHelper : NSObject

- (instancetype)initWithSpecularGlossiness:(GLTFPBRSpecularGlossinessParams *)specularGlossiness;

@property(nonatomic, readonly) simd_float4 baseColorFactor;
@property(nonatomic, nullable, readonly) GLTFTextureParams *baseColorTexture;
@property(nonatomic, readonly) float metallicFactor;
@property(nonatomic, readonly) float roughnessFactor;
@property(nonatomic, nullable, readonly) GLTFTextureParams *metallicRoughnessTexture;

@end

NS_ASSUME_NONNULL_END
