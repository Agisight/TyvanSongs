//
//  MasterViewController.h
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 06.02.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TyvanSongsConstant.h"
#import "TyvanSongsUtil.h"
#import "DetailSelectionDelegate.h"
@class DetailViewController;

@interface MasterViewController : UITableViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate> {
}

@property BOOL isTest;
@property (nonatomic, assign) id<DetailSelectionDelegate> delegate;

@property NSAttributedString *as;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashBtn;
@property bool isEdit;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (strong, nonatomic) IBOutlet UISearchBar *searcher;

@end

