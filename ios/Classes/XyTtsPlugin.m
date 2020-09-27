#import "XyTtsPlugin.h"
#import <AVFoundation/AVFoundation.h>

@interface XyTtsPlugin ()

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
    }else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)startTTS:(NSDictionary*)arguments{
    //语音播报
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:arguments[@"content"]];
    
    utterance.pitchMultiplier=0.8;
    
    //中式发音
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    //英式发音
    //    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    utterance.voice = voice;
    
    NSLog(@"%@",[AVSpeechSynthesisVoice speechVoices]);
    
    if([self.synthesizer isSpeaking]){
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    [self.synthesizer speakUtterance:utterance];
}

@end
