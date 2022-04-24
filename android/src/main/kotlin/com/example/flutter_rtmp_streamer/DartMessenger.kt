/*
 * Copyright (C) 2022 kuzalex.
 *
 */

package com.example.flutter_rtmp_streamer


import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


//
// This EventChannel is used to stream data from plugin to flutter.
//

class DartMessenger(messenger: BinaryMessenger, name: String) {
    private var eventSink: EventSink? = null

    public val handler: Handler by lazy {
        Handler(Looper.getMainLooper())
    }

    fun send(eventType: String, args: Map<String, String>) {
        handler.post {_send(eventType, args)}
    }

    private fun _send(eventType: String, args: Map<String, String>) {
        if (eventSink == null) {
            return
        }
        var data: MutableMap<String, String> = args.toMutableMap()
        data["eventType"] = eventType

        eventSink!!.success(data)
    }

    init {
        assert(messenger != null);
        EventChannel(messenger, name)
                .setStreamHandler(
                        object : EventChannel.StreamHandler {
                            override fun onListen(arguments: Any?, sink: EventSink) {
                                eventSink = sink
                            }

                            override fun onCancel(arguments: Any?) {
                                eventSink = null
                            }
                        })
    }
}