package com.xeeyao.xy_tts;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** XyTtsPlugin */
public class XyTtsPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private Context mContext;

  private EventChannel.EventSink events;

  private final static String route = "route";

  Handler mainHandler = new Handler(Looper.getMainLooper());

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "xy_tts");
    channel.setMethodCallHandler(this);
    mContext = flutterPluginBinding.getApplicationContext();

    new EventChannel(flutterPluginBinding.getBinaryMessenger(),"xy_tts_event").setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        XyTtsPlugin.this.events = events;
      }

      @Override
      public void onCancel(Object arguments) {

      }
    });

    speech = new TextToSpeech(mContext, new TextToSpeech.OnInitListener() {
      @Override
      public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
          int result = speech.setLanguage(Locale.CHINA);
          if (result != TextToSpeech.LANG_COUNTRY_AVAILABLE && result != TextToSpeech.LANG_AVAILABLE) {
            Toast.makeText(mContext, "TTS不支持中文", Toast.LENGTH_SHORT).show();
          }
        }
      }
    });

    speech.setOnUtteranceProgressListener(new UtteranceProgressListener() {
      @Override
      public void onStart(String utteranceId) {
        //utteranceId是speak方法中最后一个参数：唯一标识码
        Map<String,Object> map = new HashMap<String,Object>();
        map.put(route,"onStart");
        map.put("utteranceId",utteranceId);
        sendMsg(map);
      }

      @Override
      public void onDone(final String utteranceId) {
        Map<String,Object> map = new HashMap<String,Object>();
        map.put(route,"onFinish");
        map.put("utteranceId",utteranceId);
        sendMsg(map);
      }

      @Override
      public void onError(String utteranceId) {
        //这个onError方法已过时，用下面这个方法代替
      }

      @Override
      public void onError(String utteranceId,int errorCode) {
        //这个方法代替上面那个过时方法
        Map<String,Object> map = new HashMap<String,Object>();
        map.put(route,"onError");
        sendMsg(map);
      }

    });
  }

  private void sendMsg(final Map map){
    mainHandler.post(new Runnable() {
      @Override
      public void run() {
        XyTtsPlugin.this.events.success(map);
      }
    });
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "xy_tts");
    channel.setMethodCallHandler(new XyTtsPlugin());
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("startTTS")) {
      startTTS((Map<String, Object>) call.arguments);
    } else if (call.method.equals("stopTTS")) {
      stopTTS((Map<String, Object>) call.arguments);
    } else {
      result.notImplemented();
    }
  }

  private TextToSpeech speech;

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void startTTS(Map<String,Object> arguments) {
    float rate = ((Double)arguments.get("rate")).floatValue();
    speech.setSpeechRate(rate);
    //设置语调
    float pitch = ((Double)arguments.get("pitch")).floatValue();
    speech.setPitch(pitch);
    //开始朗读
    String content = (String)arguments.get("content");
    speech.speak(content,TextToSpeech.QUEUE_FLUSH,null,"xy_tts");
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void stopTTS(Map<String,Object> arguments) {
    speech.stop();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void pauseTTS(Map<String,Object> arguments) {
//    speech.stop();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void continueTTS(Map<String,Object> arguments) {
//    speech.stop();
  }

}
