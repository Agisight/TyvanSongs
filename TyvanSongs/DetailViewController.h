//
//  DetailViewController.h
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 06.02.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
#import "DetailSelectionDelegate.h"
@interface DetailViewController : UIViewController <NSURLConnectionDataDelegate, DetailSelectionDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSURL *audioUrl;
@property (strong, nonatomic) NSURL *localUrl;
@property BOOL isLoading;
@property (strong, nonatomic) IBOutlet UITextView *detailText;
@property float fontSizeDiff;
@property float firstSize;
@property (strong, nonatomic) IBOutlet UIImageView *tyvangirl;
@property (strong, nonatomic) IBOutlet UIWebView *webV;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loader;
@property ViewController *vc;

// for Loaders
@property (nonatomic) NSMutableData *audioData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;


@property (nonatomic, strong) UIPopoverPresentationController *popover;
@property (nonatomic, weak) IBOutlet UINavigationItem *navBarItem;


- (void) loaderImage;
- (void) loaderImageInit;
    
- (void) initPage;
- (IBAction)goLoad:(id)sender;
- (void) initLoader;
- (void) configure: (id) item With:  (UIBarButtonItem *) displayModeButtonItem;
@end

