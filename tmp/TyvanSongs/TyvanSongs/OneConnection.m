#import "OneConnection.h"
#import "AppDelegate.h"
@implementation OneConnection
@synthesize url, index;


- (void) setup: (NSString *) urlpath {
    url = urlpath;
    self.mvc = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mvc;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlpath]];
    self.appListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

    NSAssert(self.appListFeedConnection != nil, @"Интернет четкизинге коштунмаан");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - NSURLConnectionDelegate methods

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.appListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.appListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NETWORK_CONNECTIVITY_FAILURE
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
    }
    
//    self.appListFeedConnection = nil;
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSDictionary *attrs = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString *as = [[NSAttributedString alloc] initWithData:_appListData options:attrs documentAttributes:nil error:nil];

    NSUInteger length = [as.string length];
    NSRange range = NSMakeRange(0, length);

    range = [as.string rangeOfString: @"Опросы Министерства по делам молодежи и спорта Республики Тыва" options:0 range:range];
    
    if (as !=nil && range.location == NSNotFound) {
        [self insertNewObject:as];
    }
    self.appListData = nil;
}

- (void)insertNewObject:(NSAttributedString *) string {
    NSRange rng = NSMakeRange(0, [string.string componentsSeparatedByString:@"\n"][0].length);
    NSAttributedString *ats = [string attributedSubstringFromRange:rng];
    
    if (![[self hozakTrim:ats.string] hasPrefix:@"Warning"]) {
        NSManagedObjectContext *context = [_mvc.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[_mvc.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        [newManagedObject setValue:ats.string forKey:@"songName"];
        NSLog(@"NAME %@", ats.string);
        [newManagedObject setValue:_appListData forKey:@"data"];
        [newManagedObject setValue:string.string forKey:@"songContent"];
        [newManagedObject setValue:url forKey:@"url"];

        //audio
        NSRange range = [url rangeOfString:@"Tyvansong"];
        NSRange htmlRange = [url rangeOfString:@".html"];
        NSRange twingRange = NSMakeRange(range.location+range.length, htmlRange.location-(range.location+range.length));
        NSString *twinString = [url substringWithRange:twingRange];
        index = twinString;
        if (twinString!=nil) {
            NSString *audio_url = [NSString stringWithFormat:@"http://forquiz.esy.es/mp3/audio_%@.mp3", twinString];
            [newManagedObject setValue:audio_url forKey:@"audioUrl"];
        }
        

        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSString*) hozakTrim:(NSString *) string {
    return [string stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]];
}

@end
