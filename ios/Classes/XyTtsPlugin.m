#import "XyTtsPlugin.h"
#import <AVFoundation/AVFoundation.h>

@interface XyTtsPlugin ()<AVSpeechSynthesizerDelegate>

@property(nonatomic,strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation XyTtsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"xy_tts"
                                     binaryMessenger:[registrar messenger]];
    XyTtsPlugin* instance = [[XyTtsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    instance.synthesizer = [[AVSpeechSynthesizer alloc]init];
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
    }else {
        result(FlutterMethodNotImplemented);
    }
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


#pragma mark AVSpeechSynthesizerDelegate
/************ 开始播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didStartSpeechUtterance:(AVSpeechUtterance*)utterance {
    
}
 
/************ 完成播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
    NSLog(@"tts finish");
}
 
/************ 播放中止 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance*)utterance {
    
}
 
/************ 恢复播放 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance*)utterance {
    
}
 
/************ 播放取消 *****************************/
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance*)utterance {
    
}

@end
