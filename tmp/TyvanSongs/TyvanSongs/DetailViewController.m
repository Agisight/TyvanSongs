//
//  DetailViewController.m
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 06.02.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "sys/utsname.h"
@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize detailItem, detailText, fontSizeDiff, firstSize;
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
    }
}

-(BOOL)iPhone6PlusDevice{
    if ([UIScreen mainScreen].scale > 2.9) return YES;   // Scale is only 3 when not in scaled mode for iPhone 6 Plus
    return NO;
}

- (float) fontScale
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",      // (6th Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        // (GSM)
                              @"iPhone3,3" :@"iPhone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",   //
                              @"iPhone7,2" :@"iPhone 6",        //
                              @"iPhone8,1" :@"iPhone 6S",       //
                              @"iPhone8,2" :@"iPhone 6S Plus",  //
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",       // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini"        // (3rd Generation iPad Mini - Wifi (model A1599))
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPhone5"].location != NSNotFound || [code rangeOfString:@"iPhone4"].location != NSNotFound || [code rangeOfString:@"iPhone3"].location != NSNotFound || [code rangeOfString:@"iPhone6"].location != NSNotFound)
            return 0.75;
        
        if([code rangeOfString:@"iPad"].location != NSNotFound)
            return 1;

        if([code  isEqual: @"iPhone7,1"] ||[code  isEqual: @"iPhone8,2"])
            return 0.9;
        if([code  isEqual: @"iPhone7,2"] ||[code  isEqual: @"iPhone8,1"])
            return 0.8;
    }
    return 1;
}

- (void)configureView {
    if (detailItem) {
      NSMutableData *d = [detailItem valueForKey:@"data"];
        NSDictionary *attrs = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
        NSAttributedString *as = [[NSAttributedString alloc] initWithData:d options:attrs documentAttributes:nil error:nil];
        
        detailText.scrollEnabled = NO;
        
        if ([self iPhone6PlusDevice])
        {
            firstSize = 16;
            detailText.attributedText = as;
            return;
        }

        fontSizeDiff = [self fontScale];
        firstSize = 16*fontSizeDiff;
        NSMutableAttributedString *res = [as mutableCopy];
        
        [res beginEditing];
        __block BOOL found = NO;
        [res enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, res.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                UIFont *oldFont = (UIFont *)value;
                UIFont *newFont = [oldFont fontWithSize:oldFont.pointSize*fontSizeDiff];
                [res removeAttribute:NSFontAttributeName range:range];
                [res addAttribute:NSFontAttributeName value:newFont range:range];
                found = YES;
            }
        }];
        if (!found) {
            // No font was found - do something else?
        }
        [res endEditing];
        detailText.attributedText = res;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    detailText.scrollEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fontSizeDiff = 1;
    [self configureView];
    
    UIPinchGestureRecognizer *gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleTextView:)];
    [detailText addGestureRecognizer:gestureRecognizer];
}

- (void)scaleTextView:(UIPinchGestureRecognizer *)pinchGestRecognizer{
    CGFloat scale = pinchGestRecognizer.scale;
    firstSize = MIN(MAX(firstSize * sqrtf(ABS(scale)), 12), 28);
    
    NSLog(@"%f", scale);
    NSMutableAttributedString *res = [detailText.attributedText mutableCopy];
    
    [res beginEditing];
    __block BOOL found = NO;
    [res enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, res.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            UIFont *newFont = [(UIFont *)value fontWithSize:firstSize];
            [res removeAttribute:NSFontAttributeName range:range];
            [res addAttribute:NSFontAttributeName value:newFont range:range];
            found = YES;
        }
    }];
    if (!found) {
        // No font was found - do something else?
    }
    [res endEditing];
    detailText.attributedText = res;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
