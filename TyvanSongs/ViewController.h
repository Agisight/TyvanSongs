//
//  ViewController.h
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 02.03.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DetailViewController.h"
@class DetailViewController;
@interface ViewController : UIViewController  <EZAudioPlayerDelegate, EZAudioFileDelegate> {
MPMusicPlayerController *musicPlayer;
}

@property (strong, nonatomic) IBOutlet UIView *PlayerView;
@property (strong, nonatomic) IBOutlet UISlider *progress;
@property (strong, nonatomic) IBOutlet UIButton *PlayBtn;
@property (strong, nonatomic) IBOutlet UILabel *clock;
@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) NSMutableDictionary *loadings;

@property BOOL toInit;
@property (nonatomic, strong) EZAudioFile *ezFile;
@property (nonatomic, strong) EZAudioPlayer *ezPlayer;


- (void)openFileFromDVC: (DetailViewController *) dvc;
- (void) toPlayer: (DetailViewController *) dvc;
@end
