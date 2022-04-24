

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
      prepareStreamRtp()
      startStreamRtp(endpoint!!)
    }
    return START_STICKY
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
      camera2Base?.startPreview()
      sendCameraStatus()

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
        sendCameraStatus()
      }
    }

    fun stopPreview() {
      if (camera2Base != null) {
        if (camera2Base!!.isOnPreview) camera2Base!!.stopPreview()
        sendCameraStatus()

      }
    }

    ///
    ///
    ///

    fun getStreamingState():MutableMap<String, String>
    {
      val reply: MutableMap<String, String> = HashMap()


      reply["isStreaming"] = camera2Base!!.isStreaming.toString()
      reply["isOnPreview"] = camera2Base!!.isOnPreview.toString()
      reply["isAudioMuted"] = camera2Base!!.isAudioMuted.toString()
      reply["isRtmpConnected"] = isRtmpConnected.toString()


      return reply
    }

    fun sendCameraStatus() {
      dartMessenger?.send(
        "StreamingState",
        getStreamingState()
      )
    }

    fun sendError(error: String) {
      dartMessenger?.send(
        "StreamingError",
        mapOf("description" to error)
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
        sendCameraStatus()
      }

      override fun onNewBitrateRtp(bitrate: Long) {

      }

      override fun onConnectionFailedRtp(reason: String) {
        showNotification("Stream connection failed")
        Log.e(TAG, "RTP service destroy")
        sendCameraStatus()

      }

      override fun onDisconnectRtp() {
        isRtmpConnected = false
        showNotification("Stream stopped")
        sendCameraStatus()

      }

      override fun onAuthErrorRtp() {
        showNotification("Stream auth error")
      }

      override fun onAuthSuccessRtp() {
        showNotification("Stream auth success")
      }
    }

    private fun showNotification(text: String) {
      contextApp?.let {
        val notification = NotificationCompat.Builder(it, channelId)
            .setSmallIcon(android.R.drawable.presence_video_online)
            .setContentTitle("RTP Stream")
            .setContentText(text).build()
        notificationManager?.notify(notifyId, notification)
      }
    }
  }

  override fun onDestroy() {
    super.onDestroy()
    Log.e(TAG, "RTP service destroy")
    stopStream()
  }

  private fun prepareStreamRtp() {
    stopStream()
    stopPreview()
    if (endpoint!!.startsWith("rtmp")) {
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

  private fun startStreamRtp(endpoint: String) {
    if (!camera2Base!!.isStreaming) {
      if (camera2Base!!.prepareVideo() && camera2Base!!.prepareAudio()) {
        camera2Base!!.startStream(endpoint)
      }
    } else {
      showNotification("You are already streaming :(")
    }
    sendCameraStatus()

  }




}
