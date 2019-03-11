//
//  MonsterSelectionDelegate.h
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/12/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

@class DetailViewController;
@protocol DetailSelectionDelegate <NSObject>

@required
-(void)selectedSong:(id)newSong;
@end
