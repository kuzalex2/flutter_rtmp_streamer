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
//  private var fgService: Boolean = true

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_rtmp_streamer")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext

    RtpService.init(
      flutterPluginBinding.applicationContext,
      DartMessenger(flutterPluginBinding.binaryMessenger, "flutter_rtmp_streamer/events")
    )

//    RtpService.sendCameraStatusToDart();

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
      "init" -> {
        try {
          val streamingSettingsString: String = call.argument("streamingSettings")!!

          RtpService.changeStreamingSettings( Json.decodeFromString(StreamingSettings.serializer(), streamingSettingsString) )
          RtpService.sendCameraStatusToDart()
        } catch (e: Exception) {
          result.error("init", e.toString(), null)
          return;
        }

        result.success( true )
        return
      }

      /**
       *
       *
       */
      "startStream" -> {


        RtpService.getStreamingSettings()?.let {

          try {

            val uri: String = call.argument("uri")!!
            val streamName: String = call.argument("streamName")!!
            val endpoint = "$uri/$streamName"



            if (it.serviceInBackground) {
              if (!isMyServiceRunning(RtpService::class.java)) {

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

          result.success(true)
          return
        } ?: run {
          result.error("startStream", "not initialized", null)
        }

      }

      /**
       *
       *
       */
      "stopStream" -> {

        RtpService.getStreamingSettings()?.let {

          try {

            if (it.serviceInBackground){

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



        } ?: run {
          result.error("stopStream", "not initialized", null)
        }

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
          result.error("getResolutions", e.toString(), null)
          return;
        }

        return
      }


      /**
       *
       *
       */
      "changeStreamingSettings" -> {
        try {
          val streamingSettingsString: String = call.argument("streamingSettings")!!

          RtpService.changeStreamingSettings( Json.decodeFromString(StreamingSettings.serializer(), streamingSettingsString) )
          RtpService.sendCameraStatusToDart()
        } catch (e: Exception) {
          result.error("changeStreamingSettings", e.toString(), null)
          return;
        }

        result.success( true )
        return
      }

      else -> result.notImplemented()

    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)


    RtpService.getStreamingSettings()?.let {
      if (it.serviceInBackground){
        RtpService.stopStream();
      }
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
