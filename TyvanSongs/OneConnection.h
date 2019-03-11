//
//  OneConnection.h
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 07.02.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterViewController.h"
@interface OneConnection : NSObject
@property (nonatomic, strong) NSURLConnection *appListFeedConnection;
@property (nonatomic, strong) NSMutableData *appListData;
@property MasterViewController *mvc;
@property NSString *url;
@property NSString *index;
- (void) setup: (NSString *) urlpath;
@end
