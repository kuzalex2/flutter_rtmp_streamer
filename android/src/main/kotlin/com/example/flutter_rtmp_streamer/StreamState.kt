/*
 * Copyright (C) 2022 kuzalex.
 *
 */
package com.example.flutter_rtmp_streamer


import androidx.annotation.Keep
import com.pedro.encoder.input.video.CameraHelper
import kotlinx.serialization.Serializable


@Keep
@Serializable
class Resolution(val width: Int, val height: Int){
  override fun toString(): String {
    return "${width}x${height}"
  }
  val max: Int
    get() = Math.max(width, height)
  val min: Int
    get() = Math.min(width, height)
}

@Keep
@Serializable
internal class BackAndFrontResolutions(val back: List<Resolution>, val front: List<Resolution>)

@Keep
@Serializable
class StreamState(
  val isStreaming: Boolean,
  val isOnPreview: Boolean,
  val isAudioMuted: Boolean,
  val isRtmpConnected: Boolean,
  val streamResolution: Resolution,
  val cameraOrientation: Int,
  val streamingSettings: StreamingSettings,
  ){
  override fun toString(): String {
    return ""
  }
}


@Keep
@Serializable
class StreamingSettings(
  var serviceInBackground: Boolean,
  val resolutionFront: Resolution,
  val resolutionBack: Resolution,
  val videoFps: Int,
  var videoBitrate: Int,
  val h264profile: String,
  val stabilizationMode: String,
  val audioBitrate: Int,
  val audioSampleRate: Int,
  val audioChannelCount: Int,
  val cameraFacing: CameraHelper.Facing,
){
  override fun toString(): String {
    return ""
  }
}

