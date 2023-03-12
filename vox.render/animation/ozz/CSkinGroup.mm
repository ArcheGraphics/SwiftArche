//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "CSkinGroup.h"
#include "Skin.h"
#include <ozz/base/io/archive.h>

@implementation CSkinGroup {
    std::vector<ozz::Skin> skins_pool_;
}

-(void)loadSkin:(NSString*_Nonnull)filename {
    ozz::io::File file([filename cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (!file.opened()) {
//        LOGE("Failed to open mesh file {}.", filename)
    }
    ozz::io::IArchive archive(&file);

    while (archive.TestTag<ozz::Skin>()) {
        ozz::Skin skin;
        archive >> skin;
        skins_pool_.push_back(skin);
    }
}

-(uint32_t)count {
    return static_cast<uint32_t>(skins_pool_.size());
}

@end
