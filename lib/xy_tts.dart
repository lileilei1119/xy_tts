import 'dart:io';
import 'package:flutter/services.dart';

class XyTts {

  static const MethodChannel _channel =
      const MethodChannel('xy_tts');

  static double rate = 1.0;
  static double pitch = 1.0;
  static String language = "zh-CN";

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> startTTS(String content) async {
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
    await _channel.invokeMethod('startTTS',params);
  }

  static Future<void> stopTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await _channel.invokeMethod('stopTTS',params);
  }

  static Future<void> pauseTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await _channel.invokeMethod('pauseTTS',params);
  }

  static Future<void> continueTTS() async {
    final Map<String,dynamic> params = <String,dynamic>{
    };
    await _channel.invokeMethod('continueTTS',params);
  }

}
