
import 'dart:async';

import 'package:flutter/services.dart';

class XyTts {
  static const MethodChannel _channel =
      const MethodChannel('xy_tts');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> startTTS(String content) async {
    final Map<String,dynamic> params = <String,dynamic>{
      "content":content
    };
    await _channel.invokeMethod('startTTS',params);
  }

}
