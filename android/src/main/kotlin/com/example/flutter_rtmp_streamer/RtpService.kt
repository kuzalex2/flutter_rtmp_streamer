/*
 * Copyright (C) 2021 pedroSG94.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.flutter_rtmp_streamer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.pedro.encoder.input.video.CameraHelper
import com.pedro.rtplibrary.base.Camera2Base
import com.pedro.rtplibrary.rtmp.RtmpCamera2
import com.pedro.rtplibrary.rtsp.RtspCamera2
import com.pedro.rtplibrary.view.OpenGlView
import kotlinx.serialization.json.Json


/**
 * Basic RTMP/RTSP service streaming implementation with camera2
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
class RtpService : Service() {

  private var endpoint: String? = null

  override fun onCreate() {
    super.onCreate()
    Log.e(TAG, "RTP service create")
    notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(channelId, channelId, NotificationManager.IMPORTANCE_HIGH)
      notificationManager?.createNotificationChannel(channel)
    }
    keepAliveTrick()
  }

  private fun keepAliveTrick() {
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O) {
      val notification = NotificationCompat.Builder(this, channelId)
          .setOngoing(true)
          .setContentTitle("")
          .setContentText("").build()
      startForeground(1, notification)
    } else {
      startForeground(1, Notification())
    }
  }

  override fun onBind(p0: Intent?): IBinder? {
    return null
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    Log.e(TAG, "RTP service started")
    endpoint = intent?.extras?.getString("endpoint")
    if (endpoint != null) {
      prepareStreamRtp(baseContext, endpoint!!)
      startStreamRtp(endpoint!!)
    }
    return START_STICKY
  }

  override fun onDestroy() {
    super.onDestroy()
    Log.e(TAG, "RTP service destroy")
    stopStream()
  }










  companion object {
    private const val TAG = "RtpService"
    private const val channelId = "rtpStreamChannel"
    private const val notifyId = 123456
    private var notificationManager: NotificationManager? = null
    private var camera2Base: Camera2Base? = null
    private var openGlView: OpenGlView? = null
    private var contextApp: Context? = null
    private var isRtmpConnected: Boolean = false
    private var dartMessenger:DartMessenger? = null
    private var streamingSettings: StreamingSettings? = null;

//    fun setStreamingSettings(value: StreamingSettings) {
//      if (streamingSettings == null)
//        streamingSettings = value
//    }

    fun getStreamingSettings(): StreamingSettings? {
      return streamingSettings;
    }



    fun setView(openGlView: OpenGlView) {
      this.openGlView = openGlView
      camera2Base?.replaceView(openGlView)
    }

    fun setView(context: Context) {
      contextApp = context
      this.openGlView = null
      camera2Base?.replaceView(context)
    }

    fun startPreview() {
      streamingSettings?.let {

        when(it.cameraFacing) {
          CameraHelper.Facing.BACK ->
            camera2Base?.startPreview(it.cameraFacing, it.resolutionBack.width, it.resolutionBack.height)

          CameraHelper.Facing.FRONT ->
            camera2Base?.startPreview(it.cameraFacing, it.resolutionFront.width, it.resolutionFront.height);

        }


      }
      sendCameraStatusToDart()

    }



    fun init(context: Context, dartMessenger: DartMessenger) {
      contextApp = context
      this.dartMessenger = dartMessenger
      if (camera2Base == null) {
        camera2Base = RtmpCamera2(context, true, connectCheckerRtp)
        isRtmpConnected = false
      }
    }

    fun stopStream() {
      if (camera2Base != null) {
        if (camera2Base!!.isStreaming) camera2Base!!.stopStream()
        isRtmpConnected = false
        sendCameraStatusToDart()
      }
    }

    fun stopPreview() {
      if (camera2Base != null) {
        if (camera2Base!!.isOnPreview) camera2Base!!.stopPreview()
        sendCameraStatusToDart()

      }
    }

    private fun prepareStreamRtp(baseContext: Context, endpoint: String) {
      stopStream()
      stopPreview()
      if (camera2Base == null) {
        if (endpoint.startsWith("rtmp")) {
          camera2Base = if (openGlView == null) {
            RtmpCamera2(baseContext, true, connectCheckerRtp)
          } else {
            RtmpCamera2(openGlView, connectCheckerRtp)
          }
        } else {
          camera2Base = if (openGlView == null) {
            RtspCamera2(baseContext, true, connectCheckerRtp)
          } else {
            RtspCamera2(openGlView, connectCheckerRtp)
          }
        }
      }
    }

    private fun prepareVideo(it: StreamingSettings): Boolean{
      return camera2Base!!.prepareVideo(
        it.resolutionBack.width,
        it.resolutionBack.height,
        it.videoFps,
        it.videoBitrate,
        CameraHelper.getCameraOrientation(contextApp)
      );
    }

    private fun prepareAudio(it: StreamingSettings): Boolean{
      assert(it.audioChannelCount == -1 || it.audioChannelCount == 1 || it.audioChannelCount == 2);

      return camera2Base!!.prepareAudio(
        if (it.audioBitrate == -1) 65536 else it.audioBitrate,
        if (it.audioSampleRate == -1) 32000 else it.audioSampleRate,
        it.audioChannelCount != 1,
        false, false
      );
    }


    private fun startStreamRtp(endpoint: String) {

      streamingSettings?.let {

        if (!camera2Base!!.isStreaming) {



          if (prepareVideo(it) && prepareAudio(it)) {
            camera2Base!!.startStream(endpoint)
          }
        } else {
          showNotification("You are already streaming :(")
        }
        sendCameraStatusToDart()
      }

    }


    fun startInForeground(baseContext: Context, endpoint: String) {
      if (!camera2Base!!.isStreaming) {
        prepareStreamRtp(baseContext, endpoint)
        startStreamRtp(endpoint)
      }
    }

    fun resolutionsBack():List<Resolution> {

      return if (camera2Base!=null) {
        camera2Base!!.resolutionsBack.filter { it.width >= it.height }.map { Resolution(it.width, it.height) }
      } else {
        ArrayList(0)
      }
    }

    fun resolutionsFront():List<Resolution> {

      return if (camera2Base!=null) {
        camera2Base!!.resolutionsFront.filter { it.width >= it.height }.map { Resolution(it.width, it.height) }
      } else {
        ArrayList(0)
      }
    }

    ///
    ///
    ///

    private fun getStreamingState(streamingSettings: StreamingSettings):MutableMap<String, String>
    {
      val reply: MutableMap<String, String> = HashMap()

      reply["streamState"] = Json.encodeToString(StreamState.serializer(), StreamState(
        isStreaming = camera2Base!!.isStreaming,
        isOnPreview = camera2Base!!.isOnPreview,
        isAudioMuted = camera2Base!!.isAudioMuted,
        isRtmpConnected = isRtmpConnected,
        streamResolution = Resolution(width = camera2Base!!.streamWidth, height = camera2Base!!.streamHeight),
        cameraOrientation = CameraHelper.getCameraOrientation(contextApp),
        streamingSettings = streamingSettings,
      ));

      return reply
    }

    fun sendCameraStatusToDart() {
      streamingSettings?.let {
        dartMessenger?.send(
          "StreamingState",
          getStreamingState( it )
        )
      }

    }

    private fun sendNotificationToDart(description: String) {
      dartMessenger?.send(
        "Notification",
        mapOf("description" to description)
      )
    }


    private val connectCheckerRtp = object : ConnectCheckerRtp {
      override fun onConnectionStartedRtp(rtpUrl: String) {
        showNotification("Stream connection started")
      }

      override fun onConnectionSuccessRtp() {
        isRtmpConnected = true
        showNotification("Stream started")
        Log.e(TAG, "RTP service destroy")
        sendCameraStatusToDart()
      }

      override fun onNewBitrateRtp(bitrate: Long) {

      }

      override fun onConnectionFailedRtp(reason: String) {
        isRtmpConnected = false
        showNotification("Stream connection failed")
        Log.e(TAG, "RTP service destroy")
        sendCameraStatusToDart()

      }

      override fun onDisconnectRtp() {
        isRtmpConnected = false
        showNotification("Stream stopped")
        sendCameraStatusToDart()

      }

      override fun onAuthErrorRtp() {
        showNotification("Stream auth error")
      }

      override fun onAuthSuccessRtp() {
        showNotification("Stream auth success")
      }
    }

    private fun showNotification(text: String) {
      streamingSettings?.let {
        if (it.serviceInBackground) {
          contextApp?.let {
            val notification = NotificationCompat.Builder(it, channelId)
              .setSmallIcon(android.R.drawable.presence_video_online)
              .setContentTitle("RTP Stream")
              .setContentText(text).build()
            notificationManager?.notify(notifyId, notification)
          }
        }
      }

      this.sendNotificationToDart(text);
    }


    fun setStreamingSettings(newValue: StreamingSettings) {

      if (streamingSettings == null)
        streamingSettings = newValue
    }


    fun changeStreamingSettings(newValue: StreamingSettings) {

      if (streamingSettings == null)
        streamingSettings = newValue
      else {

        streamingSettings?.let {





          if (newValue.cameraFacing != streamingSettings!!.cameraFacing){
            camera2Base?.switchCamera()
            streamingSettings!!.cameraFacing = camera2Base!!.cameraFacing
          }


          if (!camera2Base!!.isStreaming ) {

            if (newValue.serviceInBackground!=it.serviceInBackground)
              it.serviceInBackground = newValue.serviceInBackground

            if (newValue.videoBitrate!=it.videoBitrate)
              it.videoBitrate = newValue.videoBitrate

            if (newValue.videoFps!=it.videoFps)
              it.videoFps = newValue.videoFps

            if (newValue.audioBitrate!=it.audioBitrate)
              it.audioBitrate = newValue.audioBitrate

            if (newValue.audioSampleRate!=it.audioSampleRate)
              it.audioSampleRate = newValue.audioSampleRate

            if (newValue.audioChannelCount!=it.audioChannelCount)
              it.audioChannelCount = newValue.audioChannelCount


            if (
              (newValue.resolutionBack!=it.resolutionBack && newValue.cameraFacing == CameraHelper.Facing.BACK)||
              (newValue.resolutionFront!=it.resolutionFront && newValue.cameraFacing == CameraHelper.Facing.FRONT)
            ){
              it.resolutionBack = newValue.resolutionBack
              it.resolutionFront = newValue.resolutionFront
              if (camera2Base!!.isOnPreview) {
                stopPreview()
                startPreview()
              }

            }

          }


        }



//
        //  val resolutionFront: Resolution,
        //  val resolutionBack: Resolution,




      }
    }


//    fun changeVideoBitrate(value: Int){
//      if (!camera2Base!!.isStreaming && streamingSettings!=null) {
//        streamingSettings!!.videoBitrate = value;
//      }
//    }




  }






}
