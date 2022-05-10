//
//  DartMessenger.swift
//  flutter_rtmp_streamer
//
//  Created by kuzalex on 5/10/22.
//

import Foundation
import Flutter
import UIKit

class DartMessenger : NSObject, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?

    init(messenger: FlutterBinaryMessenger, name: String) {
        super.init()

        let eventCnannel = FlutterEventChannel.init(name: name, binaryMessenger: messenger)


        eventCnannel.setStreamHandler(self)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }

    func send(eventType: String, args: [String:Any]) {
        guard let eventSink = _eventSink else {
            return
        }
        var data:[String:Any] = args
        data["eventType"] = eventType

        eventSink(data)

    }
}
