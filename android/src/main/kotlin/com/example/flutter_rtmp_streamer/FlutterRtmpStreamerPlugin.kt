package com.example.flutter_rtmp_streamer

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


internal class CameraViewFactory(private val messenger: BinaryMessenger): PlatformViewFactory(
  StandardMessageCodec.INSTANCE)  {

  override fun create(context: Context, id: Int, args: Any?): PlatformView {
    val creationParams = args as Map<String?, Any?>?
//    return CameraView(context, id, messenger, creationParams, this)
    return CameraView(context, id, creationParams)
  }
}

/** FlutterRtmpStreamerPlugin */
class FlutterRtmpStreamerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_rtmp_streamer")
    channel.setMethodCallHandler(this)

    RtpService.init(flutterPluginBinding.applicationContext)

    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory("flutter_rtmp_streamer_camera_view", CameraViewFactory(flutterPluginBinding.binaryMessenger))

  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
