#UPYUN 播放器 iOS 开发文档
* 支持播放网络视频，支持播放本地视频文件。

* 支持视频格式：`FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 支持自定义窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整

## 1.配置环境

### 1.1 基本介绍

`UPYUN` 播放器 `SDK`。功能完备接口简练，可以快速安装使用, 灵活性强可以满足复杂定制需求。

## 2.SDK使用说明

### 2.1 运行环境和兼容性

`UPLiveSDK.framework` 支持 `iOS 8` 及以上系统版本；     
支持 `ARMv7`，`ARM64` 架构。请使用真机进行开发和测试。     


### 2.2 安装使用说明

	
#### 手动安装：

直接将示例工程源码中 `UPLiveSDK.framework`文件夹拖拽到目标工程目录。

#### 工程设置：     
打开项目 app target，查看 **Build Settings** 中 **Enable bitcode** ,  设置为 `NO`  			

***注: 如果需要 app 退出后台仍然不间断推流直播，需要设置 ```TARGET -> Capabilities -> Backgroud Modes:ON    √ Audio, AirPlay,and Picture in Picture```***	



#### 需要添加工程依赖：

在项目的 app target 中，查看 **Build Phases** 中的 **Linking** - **Link Binary With Libraries** 选项中，手动添加 

`VideoToolbox.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`

`libc++.tbd`



***注: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***   

## 3.播放器使用
### 3.1 播放器简单调用

使用 ```UPAVPlayer``` 需要引入头文件 ```#import <UPLiveSDKDll/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer` 。

```
    //1. 初始化播放器
    _player = [[UPAVPlayer alloc] initWithURL:@"http://uprocess.b0.upaiyun.com/demo/short_video/UPYUN_0.mp4"];
    
    //2. 设置代理，接收状态回调信息
    _player.delegate = self;
    
    //3. 设置播放器 playView Frame
    [_player setFrame:self.view.bounds];
    
    //4. 添加播放器 playView
    [self.view insertSubview:_player.playView atIndex:0];
    
    //5. 开始播放
    [_player play];

    //6. 停止播放
    [_player stop];

```

### 3.2 播放器配置

* 设置播放缓冲区大小, 单位 秒, 设置为 0 的话, 会缓冲完整视频。

```
	_player.bufferingTime = 5; 

```

* 播放器画面的View

```
	_player.playView;

```

* 缓冲区大小 (0.1s -- 10s) 设置为 0 的话, 会缓冲完整视频
```
	_player.bufferingTime = 5; 
```

* 音量大小 0.0f - 1.0f

```
	_player.volume = 0.5; 
	
```

* 屏幕明亮度 0.0f - 1.0f

```
	_player. bright = 0.5; 

``` 

* 静音控制 默认为 NO

```
	// 静音
	_player.mute = YES; 

``` 

* 视频缓冲超时，单位 秒,  默认 60, 一段时间内未能缓冲到可播放的数据

```
	_player.timeoutForBuffering = 60; 

``` 

* 连接超时，默认 10s  一段时间内无数据传输

```
	_player.timeoutForOpenFile = 10; 

``` 

* 打开视频失败后的重试次数限制，默认 1 次，最大 10 次

```
	_player.maxNumForReopenFile = 1; 

``` 

* 播放器的 delegate
```
	_player.delegate = self; 
```
* 音画同步，默认值 YES

```
	_player.lipSynchOn = YES; 
``` 
* 音视频同步方式, 0:音频向视频同步,视频向标准时间轴同步；1:视频向音频同步，音频按照原采样率连续播放。默认值 为 1。

```
	_player.lipSynchMode = 1; 
``` 

### 3.3 播放器方法

* 设置画面的frame

	- (void)setFrame:(CGRect)frame;

* 连接方法
	- (void)connect;
* 开始播放
	- (void)play;
* 暂停
	- (void)pause;
* 停止, 会清除播放信息
	- (void)stop;
* 拖拽功能 秒为单位
	- (void)seekToTime:(CGFloat)position;