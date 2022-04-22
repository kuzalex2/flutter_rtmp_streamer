package com.example.flutter_rtmp_streamer


import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.TextView
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import com.pedro.rtplibrary.view.OpenGlView



internal class CameraView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
  private val _surfaceView: TextView
//  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
//  private  val _surfaceView: OpenGlView = OpenGlView(context)
  private val TAG = "CameraView"

//  private lateinit var binding: ActivityBackgroundBinding

  override fun getView(): View {
    return _surfaceView
  }

  override fun dispose() {
    Log.e(TAG, "dispose" )
  }

  init {
    _surfaceView = TextView(context)
    _surfaceView.textSize = 12f
    _surfaceView.setBackgroundColor(Color.rgb(255, 255, 255))
    _surfaceView.text = "Rendered on a native Android view (id: $id)"


  }
}


//
//import android.app.ActivityManager
//import android.content.Context
//import android.content.Intent
//import android.os.Build
//import android.util.Log
//import android.view.Surface
//import android.view.SurfaceHolder
//import android.view.View
////import com.pedro.rtplibrary.view.OpenGlView
//import io.flutter.plugin.common.BinaryMessenger
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugin.common.MethodChannel.MethodCallHandler
//import io.flutter.plugin.common.MethodChannel.Result
//import io.flutter.plugin.platform.PlatformView
////import kotlinx.serialization.Serializable
////import kotlinx.serialization.decodeFromString
////import kotlinx.serialization.encodeToString
////import kotlinx.serialization.json.Json
////import kotlinx.serialization.serializer
//import java.util.*
//
//
//
////@Keep
////@Serializable
////internal class SurfaceParams(val id: Int, val width: Int, val height: Int)
////
////
////@Keep
////@Serializable
////internal class SupportedResolutions(val back: List<Resolution>, val front: List<Resolution>)
//
//
//
//internal class CameraView(
//  private val context: Context,
//  private val id: Int,
//  messenger: BinaryMessenger,
//  creationParams: Map<String?, Any?>?,
//  private val _factory: CameraViewFactory) : PlatformView, SurfaceHolder.Callback
//{
//
//  private val TAG = "CameraView"
//
//
//  /////
//  //      PlatformView
//  //
//  //
//
////  private  val _surfaceView: OpenGlView = OpenGlView(context)
//  override fun getView(): View {
//    return View(context);
//  }
//
//
//
//
//
////  private var inputChannel : MethodChannel
////  private var orientation: Orientation? = null
////
////  private var _lastPreviewWidth : Int? = null
////  private var _lastPreviewHeight : Int? = null
////  private var _lastSurface : Surface? = null
//
//
//
//  init {
//
////    Log.i(TAG, "create $id")
//    Log.e(TAG, "create $id")
//
////    try {
////      CameraService.init(context, id, messenger)
////    } catch (e: Exception){
////      Log.e(TAG, "StorkRtmpCameraService.init failed: $e")
////    }
////
//////    rtmpCamera.setCameraCallbacks(this)
////
////
////    inputChannel = MethodChannel(messenger, "stork_rtmp_camera_$id")
////    inputChannel.setMethodCallHandler(this)
////
////
////    _surfaceView.holder.addCallback(this)
//
//
//
//  }
//
//
//
//
//
//
//  /////
//  //      METHOD CALL
//  //
//  //
//
//
//
//
//
//
//  override fun dispose() {
//    Log.e(TAG, "dispose $id")
////    orientation?.dispose()
////
////    try {
////
////      stopIfNotServiceLocked()
////
////    } catch (e: Exception) {
////    }
//  }
//
//
//
//
//  override fun surfaceCreated(holder: SurfaceHolder) {
////    Log.i(TAG, "surfaceCreated $p0 $id")
//    Log.e(TAG, "surfaceCreated $holder $id")
//
//  }
//
//
//
//  override fun surfaceChanged(holder: SurfaceHolder, p1: Int, p2: Int, p3: Int) {
////    Log.i(TAG, "surfaceChanged $p0 $id $p1 $p2 $p3")
//    Log.e(TAG, "surfaceChanged $holder $id $p1 $p2 $p3")
//
//
//
//
//
//
//  }
//
//  override fun surfaceDestroyed(holder: SurfaceHolder) {
//    Log.e(TAG, "surfaceDestroyed $holder $id")
//
//  }
//
//
//
//
//}
//
//
//
//
//
//
//
//
//
