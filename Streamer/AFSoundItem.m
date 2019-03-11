//
//  AFSoundItem.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 20/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundItem.h"
#import "AFSoundManager.h"

@implementation AFSoundItem

-(id)initWithLocalResource:(NSString *)name atPath:(NSString *)path {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeLocal;
        
        NSString *itemPath;
        
        if (!path) {
            
            NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
            itemPath = [resourcePath stringByAppendingPathComponent:name];
        } else {
            
            itemPath = [path stringByAppendingPathComponent:name];
        }
        
        _URL = [NSURL fileURLWithPath:itemPath];
        
        [self fetchMetadata];
    }
    
    return self;
}

-(id)initWithStreamingURL:(NSURL *)URL {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeStreaming;
        
        _URL = URL;
        
        [self fetchMetadata];
    }
    
    return self;
}

-(void)fetchMetadata {
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_URL];
    
    NSArray *metadata = [playerItem.asset commonMetadata];
    __weak typeof (self) welf = self;
    for (AVMetadataItem *metadataItem in metadata) {
        
        [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
            [welf handle: metadataItem];
        }];
    }
}

-(void) handle : (AVMetadataItem *) item {
    if ([item.commonKey isEqualToString:@"title"]) {
        
        _title = (NSString *)item.value;
    } else if ([item.commonKey isEqualToString:@"albumName"]) {
        
        _album = (NSString *)item.value;
    } else if ([item.commonKey isEqualToString:@"artist"]) {
        
        _artist = (NSString *)item.value;
    } else if ([item.commonKey isEqualToString:@"artwork"]) {
        
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
            
            _artwork = [UIImage imageWithData:[[item.value copyWithZone:nil] objectForKey:@"data"]];
        } else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
            
            _artwork = [UIImage imageWithData:[item.value copyWithZone:nil]];
        }
    }
}

-(void)setInfoFromItem:(AVPlayerItem *)item {
    
    _duration = CMTimeGetSeconds(item.duration);
    _timePlayed = CMTimeGetSeconds(item.currentTime);
}

@end
