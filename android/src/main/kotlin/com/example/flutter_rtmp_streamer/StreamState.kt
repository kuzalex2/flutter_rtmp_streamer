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

  override fun equals(other: Any?): Boolean {
    if (other == null || other !is Resolution) return false
    return width == other.width && height == other.height
  }
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
  val resolution: Resolution,
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
  var resolution: Resolution,
  var videoFps: Int,
  var videoBitrate: Int,
  val h264profile: String,
  val stabilizationMode: String,
  var audioBitrate: Int,
  var audioSampleRate: Int,
  var audioChannelCount: Int,
  var cameraFacing: CameraHelper.Facing,
){
  override fun toString(): String {
    return ""
  }

}

