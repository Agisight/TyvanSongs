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


@interface DetailViewController () {
NSString *label;
    NSUInteger per;
    BOOL inConnect;
}
@end


@implementation DetailViewController
@synthesize detailItem, detailText, fontSizeDiff, firstSize, audioUrl, localUrl, receivedBytes, totalBytes, audioData;
#pragma mark - Managing the detail item

- (void) configure: (id) item With:  (UIBarButtonItem *) displayModeButtonItem {
    [self setDetailItem:item];
    self.navigationItem.leftBarButtonItem = displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    [self viewDidLoad];
    [[self tyvangirl] setHidden:YES];
}

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

- (void) initPage {
    [_tyvangirl setHidden:YES];
    [_webV setHidden:NO];
}
- (void) setContentInWebView {
     NSMutableData *d = [detailItem valueForKey:@"data"];
    NSString *html = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSString * re = @"=\"http://tyvan.ru/TyvanSongs/";
    NSString * im = @"=\"";
    html = [html stringByReplacingOccurrencesOfString:re withString:im];
    
    re = @"=\"http://tyvan.ru/TyvanSongs/"; // clear old styles
    html = [html stringByReplacingOccurrencesOfString:re withString:im];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.webV loadHTMLString:html
                      baseURL:[NSURL fileURLWithPath: [NSString stringWithFormat:@"%@/htdocs/", [[NSBundle mainBundle] bundlePath]]]];
    });
    
//    <link rel="stylesheet" href="css/bootstrap.min.css">
//    <script src="js/jquery.min.js"></script>
//    <script src="js/bootstrap.min.js"></script>
}

- (NSString *) localPath: (NSURL *) streamURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Audio/%@", streamURL.lastPathComponent]];
}

- (void) myThreadMainMethod: (NSThread *) th {
    [self setContentInWebView];
    NSString *dd = [detailItem valueForKey:@"audioUrl"];
    audioUrl = [NSURL URLWithString:dd];
    
    if (audioUrl) {
        localUrl = [NSURL fileURLWithPath:[self localPath:audioUrl]];
        if ([[NSFileManager defaultManager] fileExistsAtPath: [localUrl path]])
            [self loaderImage];
        
        [_vc openFileFromDVC:self];
        }
}

- (void) loaderImage {
    [_loader setImage:[UIImage imageNamed:@"audioReload"]];
//    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
//        [_loader setImageInsets:UIEdgeInsetsMake(16, 32, 16, 0)];
//    } else
//        [_loader setImageInsets:UIEdgeInsetsMake(32, 64, 32, 0)];
}

- (void) loaderImageInit {
    [_loader setImage:[UIImage imageNamed:@"audioLoad"]];
}

- (void)configureView {
    if (detailItem) {
        [self initPage];
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(myThreadMainMethod:) object:nil];
        [myThread start];  // На самом деле создает поток
    }
}

- (void) viewDidAppear:(BOOL)animated {
    detailText.scrollEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    inConnect = 0;
    per = 0;
    fontSizeDiff = 1;
    label = self.title;
    _vc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).vc;
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goLoad:(id)sender {
    [[[NSThread alloc] initWithTarget:self
                             selector:@selector(initLoader) object:self] start];
}

- (void) initLoader {
    if (audioUrl && receivedBytes == 0) {
        [_vc.loadings addEntriesFromDictionary:@{audioUrl: @1}];
        NSURLRequest *request = [NSURLRequest requestWithURL:audioUrl];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [connection start];
    }
}

// for Data Loader
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    totalBytes = length.unsignedIntegerValue;
    if (totalBytes>10240) {
    receivedBytes = 0;
    audioData = [[NSMutableData alloc] initWithCapacity:totalBytes];
    }
    else {
        self.title = @"No audio to load";
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [audioData appendData:data];
    receivedBytes += data.length;
    per =receivedBytes *100 / totalBytes;
    self.title = [NSString stringWithFormat:@"Loading %lu%%", per];
 }

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * path = [localUrl path];
    [audioData writeToFile:path atomically:YES];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path.stringByDeletingLastPathComponent]) {
        [fm createDirectoryAtPath:path.stringByDeletingLastPathComponent withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (audioData.length>10240) {
        self.title = @"Loaded";
        [fm createFileAtPath:path contents:audioData attributes:NULL];
        [self loaderImage];
        if (self.view.window)
            [_vc toPlayer:self];
    }
    
    receivedBytes =0;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.title = @"Failed to load";
    receivedBytes = 0;
    //handle error
}


#pragma mark - Monster Selection Delegate
-(void)selectedSong:(id) newSong
{
    [self setDetailItem:newSong];
    
    //Dismisses the popover if it's showing.
    if (_popover != nil)
        [_popover dismissalTransitionDidEnd:true];
}

#pragma mark - UISplitViewDelegate methods

- (void)collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController {
    //Grab a reference to the popover

    secondaryViewController.title = @"Lyrics";
    secondaryViewController.navigationItem.title = @"Lyrics";
    secondaryViewController.title = @"Lyrics";
    secondaryViewController.navigationController.navigationItem.leftBarButtonItem.title = @"Lyrics";
    //    self.popover = pc;
    
    //Set the title of the bar button item
//    barButtonItem.title = @"Lyrics";
    
    //Set the bar button item as the Nav Bar's leftBarButtonItem
//    [_navBarItem setLeftBarButtonItem:barButtonItem animated:YES];
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //Remove the barButtonItem.
    [_navBarItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    //Nil out the pointer to the popover.
    _popover = nil;
}
@end
