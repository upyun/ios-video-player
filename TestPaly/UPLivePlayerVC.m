//
//  UPLivePlayerVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLivePlayerVC.h"
#import <UPLiveSDK/UPAVPlayer.h>
#import "AppDelegate.h"



@interface UPLivePlayerVC () <UPAVPlayerDelegate>
{
    UPAVPlayer *_player;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_bufferingProgressLabel;
    BOOL _sliding;
    UIView *_rtcContainerView;
    BOOL _landscape;//横竖屏切换
}


@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UISlider *playProgressSlider;


@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *bufferingProgressLabel;
@property (weak, nonatomic) IBOutlet UITextView *dashboardView;


@end

@implementation UPLivePlayerVC

- (void)viewDidLoad {
    [UPLiveSDKConfig setLogLevel:UP_Level_debug];
    [UPLiveSDKConfig setStatistcsOn:YES];

    self.view.backgroundColor = [UIColor blackColor];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    _activityIndicatorView.hidesWhenStopped = YES;
    
    [_playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    [_stopBtn addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [_pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    [_stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [_infoBtn addTarget:self action:@selector(info) forControlEvents:UIControlEventTouchUpInside];
    [_infoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_infoBtn setTitle:@"streamInfo" forState:UIControlStateNormal];
    
    
    _bufferingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _bufferingProgressLabel.backgroundColor = [UIColor clearColor];
    _bufferingProgressLabel.textColor = [UIColor lightTextColor];
    
    _playProgressSlider.minimumValue = 0;
    _playProgressSlider.maximumValue = 0;
    _playProgressSlider.value = 0;
    _playProgressSlider.continuous = YES;
    [_playProgressSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpInside)];
    [_playProgressSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpOutside)];
    [_playProgressSlider addTarget:self action:@selector(progressSliderTouchDown:) forControlEvents:(UIControlEventTouchDown)];
    [_playProgressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];

    [self.view addSubview:_activityIndicatorView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_stopBtn];
    [self.view addSubview:_infoBtn];
    [self.view addSubview:_bufferingProgressLabel];

    self.dashboardView.hidden = YES;
    [self updateDashboard];
    
    
    
    
    
    
    
    _player = [[UPAVPlayer alloc] initWithURL:self.url];
    _player.bufferingTime = self.bufferingTime;
    _player.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {

    [_player setFrame:[UIScreen mainScreen].bounds];

    [self.view insertSubview:_player.playView atIndex:0];
    _player.playView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    
    
    _activityIndicatorView.center = self.view.center;
    _bufferingProgressLabel.center = self.view.center;
    
    [_player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stop];
}

- (void)play {
    [_player play];
}

- (void)stop {
    [_player stop];
}

- (void)pause {
    [_player pause];
}

- (void)info {
    self.dashboardView.hidden =  !self.dashboardView.hidden;
}

- (IBAction)muteBtnTap:(UIButton *)sender {
    _player.mute = !_player.mute;
}

- (IBAction)fullScreenBtnTap:(id)sender {
    _landscape = !_landscape;

    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    if (_landscape) {
        value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    }
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)updateDashboard{
    
    
NSMutableString *string = [NSMutableString new];
    [string appendString:[NSString stringWithFormat:@"url: %@ \n", _player.dashboard.url]];
    [string appendString:[NSString stringWithFormat:@"serverName: %@ \n", _player.dashboard.serverName]];
    [string appendString:[NSString stringWithFormat:@"serverIp: %@ \n", _player.dashboard.serverIp]];
    [string appendString:[NSString stringWithFormat:@"cid: %d \n", _player.dashboard.cid]];
    [string appendString:[NSString stringWithFormat:@"pid: %d \n", _player.dashboard.pid]];
    [string appendString:[NSString stringWithFormat:@"fps: %.0f \n", _player.dashboard.fps]];
    [string appendString:[NSString stringWithFormat:@"bps: %.0f \n", _player.dashboard.bps]];
    [string appendString:[NSString stringWithFormat:@"vCachedFrames: %d \n", _player.dashboard.vCachedFrames]];
    [string appendString:[NSString stringWithFormat:@"aCachedFrames: %d \n", _player.dashboard.aCachedFrames]];
    [string appendString:[NSString stringWithFormat:@"vDecodedFrames: %d  key:%d\n", _player.dashboard.decodedVFrameNum,  _player.dashboard.decodedVKeyFrameNum]];
    [string appendString:[NSString stringWithFormat:@"aDecodedFrames: %d \n", _player.dashboard.decodedAFrameNum]];

    
    for (NSString *key in _player.streamInfo.descriptionInfo.allKeys) {
        [string appendString:[NSString stringWithFormat:@"%@: %@ \n", key, _player.streamInfo.descriptionInfo[key]]];
    }

    self.dashboardView.text = string;
    self.dashboardView.textColor = [UIColor whiteColor];
    
    double delayInSeconds = 1.0;
    __weak UPLivePlayerVC *weakself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakself updateDashboard];
    });
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (IBAction)close:(id)sender {
    [self stop];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)progressSliderTouchDown:(UISlider *)slider{
    _sliding = YES;
}

-(void)progressSliderValueChanged:(UISlider *)slider{
    self.timelabel.text = [NSString stringWithFormat:@"%.0f / %.0f", slider.value, _player.streamInfo.duration];
}

-(void)progressSliderSeekTime:(UISlider *)slider_{
    NSLog(@"progressSliderSeekTime slider value : %.2f", slider_.value);
    if (_player) {
        [_player seekToTime:slider_.value];
        _sliding = NO;
    }
}

#pragma mark UPAVPlayerDelegate

- (void)player:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus {
    switch (streamStatus) {
        case UPAVStreamStatusIdle:
            NSLog(@"连接断开－－－－－");
            break;
        case UPAVStreamStatusConnecting:{
            NSLog(@"建立连接－－－－－");
        }
            break;
        case UPAVStreamStatusReady:{
            NSLog(@"连接成功－－－－－");
        }
            break;
        default:
            break;
    }
}

- (void)player:(id)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus {
    
    switch (playerStatus) {
        case UPAVPlayerStatusIdle:{
            NSLog(@"播放停止－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
            self.stopBtn.enabled = NO;
            [self.stopBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPause:{
            NSLog(@"播放暂停－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPlaying_buffering:{
            NSLog(@"播放缓冲－－－－－");
            [self.activityIndicatorView startAnimating];
            self.bufferingProgressLabel.hidden = NO;
            self.playBtn.enabled = NO;
            [self.playBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
        }
            break;
        case UPAVPlayerStatusPlaying:{
            NSLog(@"播放中－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
            break;
        case UPAVPlayerStatusFailed:{
            NSLog(@"播放失败－－－－－");

        }
            break;
        default:
            break;
    }
}

- (void)player:(id)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo {
    if (streamInfo.canPause && streamInfo.canSeek) {
        _playProgressSlider.enabled = YES;
        _playProgressSlider.maximumValue = streamInfo.duration;
        NSLog(@"streamInfo.duration %f", streamInfo.duration);
    } else {
        _playProgressSlider.enabled = NO;
    }
}

- (void)player:(id)player displayPositionDidChange:(float)position {
    if (_sliding) {
        return;
    }
    _playProgressSlider.value = position;
    self.timelabel.text = [NSString stringWithFormat:@"%.0f / %.0f", position, _player.streamInfo.duration];
}

- (void)player:(id)player playerError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    self.bufferingProgressLabel.hidden = YES;
    
    NSLog(@"player===%p",player);
    
    NSString *msg = @"请重新尝试播放.";
    if (error) {
        NSLog(@"%@", error.description);
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败!"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)player:(id)player bufferingProgressDidChange:(float)progress {
    self.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];
}

//横竖屏切换
- (BOOL)shouldAutorotate {
    return YES;// return NO 可以
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (_landscape) {
        return UIInterfaceOrientationLandscapeRight;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}


@end
