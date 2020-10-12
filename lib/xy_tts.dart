import 'dart:io';
import 'package:flutter/services.dart';

class XyTts {

  static const MethodChannel channel =
      const MethodChannel('xy_tts');
  static const EventChannel eventChannel =
  const EventChannel('xy_tts_event');

  static double rate = 1.0;
  static double pitch = 1.0;
  static String language = "zh-CN";

  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map<String,dynamic>> startTTS(String content) async {
    double normalRate = 1.0;
    if(Platform.isIOS){
      normalRate = 0.5;
    }else{

    }
    final Map<String,dynamic> params = <String,dynamic>{
      "content":content,
      "rate":rate * normalRate,
      "pitch":pitch,
      "language":language
    };
    return await channel.invokeMethod('startTTS',params);
  }

  static Future<void> stopTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await channel.invokeMethod('stopTTS',params);
  }

  static Future<void> pauseTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await channel.invokeMethod('pauseTTS',params);
  }

  static Future<void> continueTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await channel.invokeMethod('continueTTS',params);
  }

}
