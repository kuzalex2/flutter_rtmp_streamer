/*
 * Copyright (C) 2022 kuzalex.
 *
 */
package com.example.flutter_rtmp_streamer

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
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
import kotlinx.serialization.json.Json


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
  private lateinit var applicationContext : Context

//  private var fgService: Boolean = false
  private var fgService: Boolean = true

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_rtmp_streamer")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext

    RtpService.init(
      flutterPluginBinding.applicationContext,
      DartMessenger(flutterPluginBinding.binaryMessenger, "flutter_rtmp_streamer/events")
    )

    RtpService.sendCameraStatusToDart();

    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory("flutter_rtmp_streamer_camera_view", CameraViewFactory(flutterPluginBinding.binaryMessenger))

  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {



    when (call.method) {
      /**
       *
       *
       */
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
        return
      }

      /**
       *
       *
       */
      "sendStreamerState" -> {
        RtpService.sendCameraStatusToDart()
        result.success( true )
        return
      }

      /**
       *
       *
       */
      "startStream" -> {
        try {

          val uri:String = call.argument("uri")!!
          val streamName:String = call.argument("streamName")!!
          val endpoint = "$uri/$streamName"

          if (fgService){
            if (! isMyServiceRunning(RtpService::class.java)) {

              val intent = Intent(applicationContext, RtpService::class.java)
              intent.putExtra("endpoint", endpoint)
              applicationContext.startService(intent)
            }

          } else {
            RtpService.startInForeground(applicationContext, endpoint)

          }

        } catch (e: Exception) {
          result.error("startStream", e.toString(), null)
          return;
        }

        result.success( true )
        return
      }

      /**
       *
       *
       */
      "stopStream" -> {
        try {

          if (fgService){

            if (isMyServiceRunning(RtpService::class.java)) {
              applicationContext.stopService(Intent(applicationContext, RtpService::class.java))
            }

          } else {
            RtpService.stopStream();
          }



        } catch (e: Exception) {
          result.error("stopStream", e.toString(), null)
          return;
        }

        result.success( true )
        return
      }

      /**
       *
       *
       */
      "getResolutions" -> {
        try {

          result.success( Json.encodeToString(
            BackAndFrontResolutions.serializer(),
            BackAndFrontResolutions(back = RtpService.resolutionsBack(), front = RtpService.resolutionsFront())
          ))

        } catch (e: Exception) {
          result.error("getResolutionsBack", e.toString(), null)
          return;
        }

        return
      }

      else -> result.notImplemented()

    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)

    if (!fgService){

      RtpService.stopStream();
    }
  }

  @Suppress("DEPRECATION")
  private fun isMyServiceRunning(serviceClass: Class<*>): Boolean {

    val manager =applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    for (service in manager.getRunningServices(Integer.MAX_VALUE)) {
      if (serviceClass.name == service.service.className || serviceClass.name == service.service.className+"\$Companion") {
        return true
      }
    }
    return false
  }
}
