//
//  PlayerVC.m
//  UPLiveSDKDemo
//
//  Copyright © 2017 upyun.com. All rights reserved.

#import "PlayerVC.h"
#import <UPLiveSDK/UPAVPlayer.h>

@interface PlayerVC ()<UPAVPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
{
   UPAVPlayer *_player;
    BOOL _sliding;
}

@property (weak, nonatomic) IBOutlet UISlider *processSlider;

@property (nonatomic, strong) UITableView *videoListView;

@property (nonatomic, strong) NSMutableArray *playList;


@property (nonatomic, strong) NSMutableDictionary *processDic;

@end

@implementation PlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _playList = [NSMutableArray array];
    _processDic = [NSMutableDictionary dictionary];
    
    
    [self setupView];
}

- (void)setupView {
    
    _processSlider.minimumValue = 0;
    _processSlider.maximumValue = 0;
    _processSlider.value = 0;
    _processSlider.continuous = YES;
    [_processSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpInside)];
    [_processSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpOutside)];
    [_processSlider addTarget:self action:@selector(progressSliderTouchDown:) forControlEvents:(UIControlEventTouchDown)];
    [_processSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    
    
    
    
    _videoListView = [[UITableView alloc] initWithFrame:self.view.frame];
    
    _videoListView.dataSource = self;
    _videoListView.delegate = self;
    
    [self.view addSubview:_videoListView];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuserID = @"UPYUN_PLAY";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    
    
    //1. 初始化播放器
    UPAVPlayer *itemPlayer = [[UPAVPlayer alloc] initWithURL:@"http://test86400.b0.upaiyun.com/7937144.mp4"];
    
    //2. 设置代理，接受播放错误，播放进度，播放状态等回调信息
    itemPlayer.delegate = self;
    
    //3. 设置播放器 playView Frame
    [itemPlayer setFrame:CGRectMake(0, 0, 200, 200)];
    
    //4. 添加播放器 playView
    [cell insertSubview:itemPlayer.playView atIndex:0];
    itemPlayer.playView.autoresizingMask = UIViewAutoresizingNone;
    
    
    //5. 开始播放
    [itemPlayer connect];
    
    UISlider *itemProcessSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 190, 200, 10)];
    
    
    itemProcessSlider.minimumValue = 0;
    itemProcessSlider.maximumValue = 0;
    itemProcessSlider.value = 0;
    itemProcessSlider.continuous = YES;
    [itemProcessSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpInside)];
    [itemProcessSlider addTarget:self action:@selector(progressSliderSeekTime:) forControlEvents:(UIControlEventTouchUpOutside)];
    [itemProcessSlider addTarget:self action:@selector(progressSliderTouchDown:) forControlEvents:(UIControlEventTouchDown)];
    [itemProcessSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
    itemProcessSlider.tag = indexPath.row;
    
    
    [cell addSubview:itemProcessSlider];
    
    [_playList addObject:itemPlayer];
    
    
    
    [_processDic setObject:itemProcessSlider forKey:itemPlayer.description];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 220;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    for (UPAVPlayer *itemPlayer in _playList) {
        [itemPlayer pause];
    }
    
    
    UPAVPlayer *itemPlayer = [_playList objectAtIndex:indexPath.row];
    
    [itemPlayer play];
    
    
}


-(void)progressSliderTouchDown:(UISlider *)slider{
    _sliding = YES;
}

-(void)progressSliderValueChanged:(UISlider *)slider{
    NSLog(@"");

}

-(void)progressSliderSeekTime:(UISlider *)slider{
    NSLog(@"progressSliderSeekTime slider value : %.2f", slider.value);
    
    UPAVPlayer *player = [_playList objectAtIndex:slider.tag];
    
    
    if (player) {
        [player seekToTime:slider.value];
        _sliding = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
//    //1. 初始化播放器
//    _player = [[UPAVPlayer alloc] initWithURL:@"http://test654123.b0.upaiyun.com/265_demo.mp4"];
//    
//    //2. 设置代理，接受播放错误，播放进度，播放状态等回调信息
//    _player.delegate = self;
//    
//    //3. 设置播放器 playView Frame
//    [_player setFrame:self.view.bounds];
//    
//    //4. 添加播放器 playView
//    [self.view insertSubview:_player.playView atIndex:0];
//    
//    //5. 开始播放
//    [_player connect];
}

- (void)viewWillDisappear:(BOOL)animated {
    //6. 关闭页面，播放器需要 stop 才会自动释放。
    [_player stop];
}

#pragma mark UPAVPlayerDelegate
- (void)player:(UPAVPlayer *)player playerError:(NSError *)error {
    //7. 监听播放错误。
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败" message:error.description preferredStyle:1];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark 播放，停止按钮
- (IBAction)playBtnTap:(id)sender {
    //8. 播放按钮。
    [_player play];
}

- (IBAction)stopBtnTap:(id)sender {
    //9. 停止按钮。
    [_player stop];
}
#pragma mark--seek

- (void)player:(id)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo {
    UPAVPlayer *itemPlayer = player;

    UISlider *slider = [_processDic objectForKey:itemPlayer.description];
    if (streamInfo.canPause && streamInfo.canSeek) {
        slider.enabled = YES;
        slider.maximumValue = streamInfo.duration;
        NSLog(@"streamInfo.duration %f", streamInfo.duration);
    } else {
        slider.enabled = NO;
    }
}

- (void)player:(id)player displayPositionDidChange:(float)position {
    if (_sliding) {
        return;
    }
    
    UPAVPlayer *itemPlayer = player;
    UISlider *slider = [_processDic objectForKey:itemPlayer.description];
    slider.value = position;
    
}



@end
