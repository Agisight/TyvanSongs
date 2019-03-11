//
//  ViewController.m
//  TyvanSongs
//
//  Created by Ali Kuzhuget on 02.03.16.
//  Copyright © 2016 Ali Kuzhuget. All rights reserved.
//

#import "ViewController.h"
#import "AFSoundManager.h"
#import "AppDelegate.h"
@interface ViewController ()
@property NSURL *audioUrl;
@property AVAudioSession *session;
@property NSTimer* progressTimer;
@property UIImage *imgLogo;
@property UIImage *trackArt;
@property NSFileManager *fm;
@property DetailViewController *cdetail, *current_dvc;
@end

@implementation ViewController
@synthesize ezFile, ezPlayer, PlayBtn, PlayerView, progress, toInit, clock, thread, session, progressTimer, loadings, imgLogo, cdetail, trackArt, fm, current_dvc;


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fm = [NSFileManager defaultManager];
    imgLogo = [UIImage imageNamed:@"logo"];
    toInit = YES;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //Grab a reference to the UISplitViewController
        UISplitViewController *splitViewController = (UISplitViewController *)self.childViewControllers[0];
        
        //Grab a reference to the LeftViewController and get the first monster in the list.
        UINavigationController *leftNavController = [splitViewController.viewControllers objectAtIndex:0];
        MasterViewController *leftViewController = (MasterViewController *)[leftNavController topViewController];
        
        //Grab a reference to the RightViewController and set it as the SVC's delegate.
        DetailViewController *rightViewController = [splitViewController.viewControllers lastObject];
        leftViewController.delegate = rightViewController;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    session = [AVAudioSession sharedInstance];
    NSError *error;
    AVAudioSessionCategory cat = AVAudioSessionCategoryPlayAndRecord;
    if (@available(iOS 11.0, *)) {
        BOOL success = [session setCategory:cat withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        
        if (!success) {
            NSLog(@"AVAudioSession error setting category:%@",error);
        }
        
        // Set the audioSession override
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                             error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
        }
        
        // Activate the audio session
        success = [session setActive:YES error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error activating: %@",error);
        }
        else {
            NSLog(@"AudioSession active");
        }
    } else {
        // Fallback on earlier versions
    }
    if (error) NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    
    //    [self RouteChanged:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    ezPlayer = [EZAudioPlayer audioPlayerWithDelegate:self];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).vc = self;
    ezPlayer.shouldLoop = YES;
    
    [self setupNotifications];
    UIImage *img =[UIImage imageNamed:@"endlessKnot.png"];
    img = [self imageWithImage:img scaledToSize:CGSizeMake(32, 32)];
    [progress setThumbImage:img forState:UIControlStateNormal];
    
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [self registerMediaPlayerNotifications];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    loadings = [NSMutableDictionary new];
    
    
//    if (ezPlayer.output.mixerAudioUnit) {
//        UInt32 maxFPS = 4096;
//        AudioUnitSetProperty(ezPlayer.output.outputAudioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPS, sizeof(maxFPS));
//    }
}

- (void)audioHardwareRouteChanged:(NSNotification *)notification {
    
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    NSLog(@"audioHardwareRouteChanged %ld", (long)routeChangeReason);
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // The old device is unavailable == headphones have been unplugged
    }
}

- (void) updateTimer {
    [self timer:nil];
}

- (void)timer:(NSTimer *)timer {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MPNowPlayingInfoCenter") && weakSelf && weakSelf.cdetail) {
            
            if ([weakSelf.cdetail.detailItem valueForKey:@"songName"]) {
                NSMutableDictionary *mInfo = [[NSMutableDictionary alloc]init];
                
                [mInfo setObject:@"Tyvan Songs" forKey:MPMediaItemPropertyAlbumTitle];
                [mInfo setObject:[[weakSelf.cdetail.detailItem valueForKey:@"songName"] description] forKey:MPMediaItemPropertyTitle];
                //[mediaInfo setObject:@"Artist" forKey:MPMediaItemPropertyArtist];
                
                [mInfo setObject:[NSNumber numberWithDouble: weakSelf.ezPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
                MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:weakSelf.trackArt.size requestHandler:^UIImage * _Nonnull(CGSize size) {
                    return weakSelf.trackArt;
                }];
                
                NSNumber *durationTrack= [NSNumber numberWithDouble:[weakSelf.ezPlayer duration]];
                NSNumber *elapsedTime= [NSNumber numberWithDouble:[weakSelf.ezPlayer currentTime]];
                NSNumber *rate= [NSNumber numberWithInt:1];
                
                [mInfo setObject:elapsedTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
                [mInfo setObject:durationTrack forKey:MPMediaItemPropertyPlaybackDuration];
                [mInfo setObject:rate forKey:MPNowPlayingInfoPropertyPlaybackRate];
                
                [mInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mInfo];
            }
        }
    });
}
- (void) registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (RouteChanged:)
                               name: AVAudioSessionRouteChangeNotification
                             object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_NowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: musicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
}

- (void) RouteChanged: (id) notification
{
    NSArray * inputs = [[AVAudioSession sharedInstance] currentRoute].inputs;
    AVAudioSessionPortDescription *input = inputs.lastObject;
    
    NSLog(@"PORT INPUT %@", input.portType);
    NSArray * outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    AVAudioSessionPortDescription *output = outputs.lastObject;
    if ([output.portType isEqual: @"BluetoothHFP"]) {
        
        NSError *error;
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        if (error) NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        [session setPreferredInput:output error:&error];
        
        __weak typeof (self) welf = self;
        int i = 0;
        NSLog(@"A %d", i);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            // do your db stuff here...
            NSLog(@"B %d", i);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"C %d", i);
            });
        });
        
        NSLog(@"D %d", i);
        if (error) NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        return;
    }
    
    // otherwise
    
    NSLog(@"PORT OUTPUT %@", input.portType);
    if ([[output portType] isEqualToString:AVAudioSessionPortBluetoothA2DP] || [[output portType] isEqualToString:AVAudioSessionPortHeadphones] || [[output portType] isEqualToString:AVAudioSessionPortAirPlay] || [[output portType] isEqualToString:AVAudioSessionPortCarAudio]) {
        
        NSError *error;
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        if (error) NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        [session setPreferredInput:output error:&error];
        if (error) NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    else {
        if ([output.portType isEqual: @"Receiver"]) {
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        } else {
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
}

- (void) handle_PlaybackStateChanged: (id) notification
{
    switch ([musicPlayer playbackState]) {
        case MPMusicPlaybackStatePaused:
            break;
        case MPMusicPlaybackStatePlaying:
            break;
        case MPMusicPlaybackStateStopped:
            [musicPlayer stop];
            break;
        default:
            break;
    }
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    UIImage *artworkImage = imgLogo;
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    if (artwork) {
        artworkImage = [artwork imageWithSize: CGSizeMake (200, 200)];
    }
    
    
    //[artworkImageView setImage:artworkImage];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        //    titleLabel.text = [NSString stringWithFormat:@"Title: %@",titleString];
    } else {
        //    titleLabel.text = @"Title: Unknown title";
    }
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        //    artistLabel.text = [NSString stringWithFormat:@"Artist: %@",artistString];
    } else {
        //    artistLabel.text = @"Artist: Unknown artist";
    }
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    if (albumString) {
        //    albumLabel.text = [NSString stringWithFormat:@"Album: %@",albumString];
    } else {
        //    albumLabel.text = @"Album: Unknown album";
    }
}


- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:ezPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:ezPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:ezPlayer];
}

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    NSLog(@"Player changed audio file: %@", [ezPlayer audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    NSLog(@"Player changed output device: %@", [ezPlayer device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    NSLog(@"Player change play state, isPlaying: %i", [ezPlayer isPlaying]);
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event {
    
    NSLog(@"AudioPlayerViewController ... remoteControlReceivedWithEvent ....subtype: %ld", (long)event.subtype);
    
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self goPlay:PlayBtn];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self goPlay:PlayBtn];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [self goPlay:PlayBtn];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self goPlay:PlayBtn];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self goPlay:PlayBtn];
                break;
            default:
                break;
        }
    }
}

- (void) toPlayer: (DetailViewController *) dvc {
    NSLog(@"audio %@", dvc.audioUrl.lastPathComponent);
    if ([fm fileExistsAtPath: dvc.localUrl.path])
    {
        trackArt = imgLogo;
        EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:dvc.localUrl];
        if (audioFile) {
            [ezPlayer pause];
            [ezPlayer setAudioFile:audioFile];
            
            cdetail = dvc;
            __weak typeof (self) welf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                welf.progress.maximumValue = [welf.ezPlayer totalFrames];
            });
            
            [self updateTimer];
            
            
            if (dvc) dvc.title = @"Lyrics";
        }
        else {
            NSLog(@"ERROR WITH FILE CREATION");
            if (dvc) dvc.title = @"No audio to load";
        }
        
    }
    else {
        if (dvc) dvc.title = @"No audio to load";
    }
}

- (void) myThreadMainMethod: (DetailViewController *) dvc {
    if (dvc.audioUrl) {
        current_dvc = dvc;
        NSString * path = [dvc.localUrl path];
        if (!loadings[dvc.audioUrl]) {
            if ([fm fileExistsAtPath: path]) {
                [loadings addEntriesFromDictionary:@{dvc.audioUrl: @2}];
                [dvc loaderImage];
                
                __weak typeof (self) welf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [welf goPlay:welf.PlayBtn];
                    dvc.title = @"Lyrics";
                });
            }
            else {
                [dvc loaderImageInit];
                [dvc initLoader];
            }
        }
        else {
            [self toPlayer:dvc];
        }
    }
}

- (void)openFileFromDVC: (DetailViewController *) dvc
{
    if (![ezPlayer.url isEqual: dvc.audioUrl]) {
        _audioUrl = dvc.audioUrl;
        [ezPlayer pause];
        __weak typeof (self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            welf.progress.value = 0;
            [welf.PlayBtn setSelected:welf.ezPlayer.isPlaying];
        });
        thread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(myThreadMainMethod:) object:dvc];
        [thread start];
    }
}

- (IBAction)goPlay:(id)sender {
    clock.text = [NSString stringWithFormat:@"00:00\n00:00"];
    if (!_audioUrl) return;
    if (ezPlayer.audioFile.url != current_dvc.localUrl)
        [self toPlayer:current_dvc];
    
    if ([ezPlayer state] == EZAudioPlayerStatePlaying)
        [ezPlayer pause];
    else
    {
        if (ezPlayer.audioFile)
            [ezPlayer play];
    }
    
    [PlayBtn setSelected:ezPlayer.isPlaying];
    
    clock.text = [NSString stringWithFormat:@"%.2ld:%.2ld\n%.2ld:%.2ld", (NSInteger)ezPlayer.currentTime/60, (NSInteger) ezPlayer.currentTime%60, (NSInteger)[ezPlayer duration]/60, (NSInteger)ezPlayer.duration%60];
    [self updateTimer];
}

- (IBAction)goSeek:(id)sender {
    [ezPlayer seekToFrame:[(UISlider *)sender value]];
    clock.text = [NSString stringWithFormat:@"%.2ld:%.2ld\n%.2ld:%.2ld", (NSInteger)ezPlayer.currentTime/60, (NSInteger) ezPlayer.currentTime%60, (NSInteger)[ezPlayer duration]/60, (NSInteger)ezPlayer.duration%60];
    [self updateTimer];
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void) audioPlayer:(EZAudioPlayer *)audioPlayer reachedEndOfAudioFile:(EZAudioFile *)audioFile {
    [self updateTimer];
}

- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.ezPlayer.currentTime < 2) [weakSelf updateTimer];
        if (!weakSelf.progress.touchInside)
        {
            weakSelf.progress.value = (float)framePosition;
            weakSelf.clock.text = [NSString stringWithFormat:@"%.2ld:%.2ld\n%.2ld:%.2ld", (NSInteger)weakSelf.ezPlayer.currentTime/60, (NSInteger) weakSelf.ezPlayer.currentTime%60, (NSInteger)[weakSelf.ezPlayer duration]/60, (NSInteger)weakSelf.ezPlayer.duration%60];
        }
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

