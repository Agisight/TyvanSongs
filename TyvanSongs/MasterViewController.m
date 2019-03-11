//
//  MasterViewController.m
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 06.02.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "OneConnection.h"
#import "AppDelegate.h"
@interface MasterViewController ()
@property (nonatomic, strong) NSURLConnection *appListFeedConnection;
@property (nonatomic, strong) NSMutableData *appListData;
@property AppDelegate* ad;
@end

@implementation MasterViewController
@synthesize isEdit, searcher;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isTest = NO;
    
    UINavigationController *navigationController = [self.splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.splitViewController.delegate = self;
    
    [self setuper];
    
    isEdit = NO;
    
    _ad = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    _ad.mvc = self;
    _ad.mvc.managedObjectContext = _ad.managedObjectContext;

    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"Cancel"];
//    self.navigationItem.hidesBackButton = NO;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)refreshSongs:(id)sender {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self setuper];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete song";
}
- (NSString*) hozakTrim:(NSString *) string {
    return [string stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]];
}

- (IBAction)editSongs:(id)sender {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Шупту ырыларны казыыр бе? \n Delete all songs?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof (self) welf = self;
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Чаа (Yes)"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action)
                                {
                                    [welf handleYesButton];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Чок (No)"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //     [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) handleYesButton {
    NSError *error;
    _fetchedResultsController.delegate = nil;               // turn off delegate callbacks
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    for (NSManagedObject *message in [_fetchedResultsController fetchedObjects]) {
        [context deleteObject:message];
    }
    if (![_managedObjectContext save:&error]) {
        // TODO: Handle the error appropriately.
        NSLog(@"Delete message error %@, %@", error, [error userInfo]);
    }
    _fetchedResultsController.delegate = self;
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    // reconnect after mass delete
    if (![_fetchedResultsController performFetch:&error]) { // resync controller
        // TODO: Handle the error appropriately.
        NSLog(@"fetchMessages error %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
    //[self.tableView setEditing:isEdit animated: YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    //Do some search
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    if ([self hozakTrim:text].length >0)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"songName contains %@", text]];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"songName"
                                ascending:YES
                                selector:@selector(caseInsensitiveCompare:)];
    
    [fetchRequest setSortDescriptors:@[sorter]];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         if (_isTest) abort();
    }
    [self.tableView reloadData];
}

- (void) collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController {
    return;
}

UITableViewCell *last = nil;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (last)
        [last setBackgroundColor:[UIColor clearColor]];
    last = [self.tableView cellForRowAtIndexPath:indexPath];
    [last setBackgroundColor:[UIColor cyanColor]];
}



#pragma mark - Segues
NSString *lastName = @"1234567890";
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *ind = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:ind];
        UINavigationController* navController = (UINavigationController*)[segue destinationViewController];
        DetailViewController* controller = (DetailViewController *)[navController topViewController];
                
        [controller configure:object With:self.splitViewController.displayModeButtonItem];
        lastName = [[object valueForKey:@"songName"] description];
    }
}

DetailViewController *controller;
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    if (cell.textLabel.text != lastName)
        [cell setBackgroundColor:[UIColor clearColor]];
    else
        [cell setBackgroundColor:[UIColor cyanColor]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"1 %lu", [_fetchedResultsController fetchedObjects].count);
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
//        [fetch setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:context]];
        
//        NSArray * result = [context executeFetchRequest:fetch error:nil];
//        for (id basket in result)
//            [context deleteObject:basket];
        
        NSError *error;
        // for delete
        NSString *dd = [self localPath:[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"audioUrl"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dd]) [[NSFileManager defaultManager] removeItemAtPath:dd error:&error];
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSLog(@"2 %lu | %lu | %lu", [context deletedObjects].count, [context updatedObjects].count, [context registeredObjects].count);
        
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            if (_isTest)
                abort();
        }
    }
}

- (NSString *) localPath: (NSString *) path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Audio/%@", path.lastPathComponent]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"songName"] description];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"songName" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    if (_isTest) abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


- (void) setuper {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SongList]];
    self.appListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.appListFeedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
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
        [TyvanSongsUtil alertPopup:noConnectionError];
    }
    else
        [TyvanSongsUtil alertPopup:error];
    
    self.appListFeedConnection = nil;
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
@autoreleasepool {
    NSDictionary *attrs = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    _as = [[NSAttributedString alloc] initWithData:_appListData options:attrs documentAttributes:nil error:nil];
    
    NSArray *ma = [_as.string componentsSeparatedByString:@"\n"];
    for (NSString *s in ma) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"url == %@", s];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSUInteger i = [_managedObjectContext countForFetchRequest:fetchRequest error:nil];
        
        if (i==0 && ![[self hozakTrim:s] isEqual:@""]) {
            [[[OneConnection alloc] init] setup:s];
            NSLog(@"index %lu, SongURL: %@ ", (unsigned long)i, s);
        }
    }
}
    self.appListData = nil;
}
@end
