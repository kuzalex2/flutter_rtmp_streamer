package com.example.flutter_rtmp_streamer


import android.app.ActivityManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.SurfaceHolder
import android.view.View
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import com.pedro.rtplibrary.view.OpenGlView



internal class CameraView(private val context: Context, private val id: Int, creationParams: Map<String?, Any?>?) : PlatformView, SurfaceHolder.Callback {

  private val TAG = "CameraView"

  private  val _surfaceView: OpenGlView = OpenGlView(context)



  override fun getView(): View {
    return _surfaceView
  }

  override fun dispose() {
    Log.e(TAG, "dispose" )
  }



  override fun surfaceCreated(holder: SurfaceHolder) {
    Log.e(TAG, "surfaceCreated $holder $id")
  }

  override fun surfaceChanged(holder: SurfaceHolder, p1: Int, p2: Int, p3: Int) {
    Log.e(TAG, "surfaceChanged $holder $id $p1 $p2 $p3")
    RtpService.setView(_surfaceView)
    RtpService.startPreview()
  }

  override fun surfaceDestroyed(holder: SurfaceHolder) {
    Log.e(TAG, "surfaceDestroyed $holder $id")
    RtpService.setView(context)
    RtpService.stopPreview()
  }

//  private fun isMyServiceRunning(serviceClass: Class<*>): Boolean {
//    val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
//    for (service in manager.getRunningServices(Integer.MAX_VALUE)) {
//      if (serviceClass.name == service.service.className) {
//        return true
//      }
//    }
//    return false
//  }


  init {



    _surfaceView.holder.addCallback(this)
  }


}
