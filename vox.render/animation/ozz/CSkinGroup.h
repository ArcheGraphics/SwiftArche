//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <Foundation/Foundation.h>

@interface CSkinGroup : NSObject

-(void)loadSkin:(NSString*_Nonnull)filename;

-(uint32_t)count;

@end
