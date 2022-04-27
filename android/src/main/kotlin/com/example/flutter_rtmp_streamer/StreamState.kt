/*
 * Copyright (C) 2022 kuzalex.
 *
 */
package com.example.flutter_rtmp_streamer


import androidx.annotation.Keep
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
class StreamState(
  val isStreaming: Boolean,
  val isOnPreview: Boolean,
  val isAudioMuted: Boolean,
  val isRtmpConnected: Boolean,
  val streamResolution: Resolution,
  val cameraOrientation: Int,
  ){
  override fun toString(): String {
    return ""
  }
}

