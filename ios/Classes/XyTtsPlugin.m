#import "XyTtsPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface XyTtsPlugin ()<AVSpeechSynthesizerDelegate,FlutterStreamHandler>

@property(nonatomic,strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation XyTtsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"xy_tts"
                                     binaryMessenger:[registrar messenger]];
    XyTtsPlugin* instance = [[XyTtsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    instance.synthesizer = [[AVSpeechSynthesizer alloc]init];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"xy_tts_event" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    
    [registrar addApplicationDelegate:instance];
}


#pragma --mark 生命周期
- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    [self createRemoteCommandCenter];
    return YES;
}

//锁屏界面开启和监控远程控制事件
- (void)createRemoteCommandCenter{
    /**/
    //远程控制命令中心 iOS 7.1 之后  详情看官方文档：https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

//    commandCenter.togglePlayPauseCommand 耳机线控的暂停/播放

    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSDictionary *dic = @{
            @"route":@"onRemotePause",
        };
        self.eventSink(dic);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSDictionary *dic = @{
            @"route":@"onRemotePlay",
        };
        self.eventSink(dic);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSDictionary *dic = @{
            @"route":@"onRemotePre",
        };
        self.eventSink(dic);
            return MPRemoteCommandHandlerStatusSuccess;
        }];

    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSDictionary *dic = @{
            @"route":@"onRemoteNext",
        };
        self.eventSink(dic);
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([@"startTTS" isEqualToString:call.method]){
        [self startTTS:call.arguments];
    }else if([@"stopTTS" isEqualToString:call.method]){
        [self stopTTS:call.arguments];
    }else if([@"pauseTTS" isEqualToString:call.method]){
        [self pauseTTS:call.arguments];
    }else if([@"continueTTS" isEqualToString:call.method]){
        [self continueTTS:call.arguments];
    }else if([@"setPlayingInfo" isEqualToString:call.method]){
        [self setPlayingInfo:call.arguments];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setPlayingInfo:(NSDictionary*)arguments {
    NSString *title = arguments[@"title"];
//  MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"pushu.jpg"]];
  NSDictionary *dic = @{MPMediaItemPropertyTitle:title,
//             MPMediaItemPropertyArtist:@"朴树",
//             MPMediaItemPropertyArtwork:artWork
             };
  [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

/**
 *  设置播放的声音参数 如果选择默认请传入 -1.0
 *
 *   volume          音量（0.0~1.0）默认为1.0
 *   rate            语速（0.0~1.0）默认为1.0
 *   pitchMultiplier 语调 (0.5-2.0)默认为1.0
 *   languageCode     语言          默认为 中文普通话:@"zh-CN"
 */
-(void)startTTS:(NSDictionary*)arguments{
    
    [self.synthesizer setDelegate:self];
    //语音播报
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:arguments[@"content"]];
    
    //中式发音
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:arguments[@"language"]];
    
    utterance.voice = voice;
    utterance.rate = [arguments[@"rate"] floatValue];
    utterance.pitchMultiplier = [arguments[@"pitch"] floatValue];
    
//    NSLog(@"%@",[AVSpeechSynthesisVoice speechVoices]);
    
    if([self.synthesizer isSpeaking]){
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    [self.synthesizer speakUtterance:utterance];
    
    [self setPlayingInfo:arguments];
}

-(void)stopTTS:(NSDictionary*)arguments{
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

-(void)pauseTTS:(NSDictionary*)arguments{
    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

-(void)continueTTS:(NSDictionary*)arguments{
    [self.synthesizer continueSpeaking];
}


#pragma mark - FlutterStreamHandler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink{
    self.eventSink = eventSink;
    return nil;
}
 
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

#pragma mark AVSpeechSynthesizerDelegate
/************ 开始播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didStartSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSDictionary *dic = @{
        @"route":@"onStart",
        @"utteranceId":utterance.voice.identifier
    };
    self.eventSink(dic);
}
 
/************ 完成播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSLog(@"tts finish");
    NSDictionary *dic = @{
        @"route":@"onFinish",
        @"utteranceId":utterance.voice.identifier
    };
    self.eventSink(dic);
}
 
/************ 播放中止 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSDictionary *dic = @{
        @"route":@"onPause",
        @"utteranceId":utterance.voice.identifier
    };
    self.eventSink(dic);
}
 
/************ 恢复播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSDictionary *dic = @{
        @"route":@"onContinue",
        @"utteranceId":utterance.voice.identifier
    };
    self.eventSink(dic);
}
 
/************ 播放取消 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSDictionary *dic = @{
        @"route":@"onCancel",
        @"utteranceId":utterance.voice.identifier
    };
    self.eventSink(dic);
}

@end
