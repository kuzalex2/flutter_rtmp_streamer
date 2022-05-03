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

    func _send(eventType: String, args: [String:Any]) {
        guard let eventSink = _eventSink else {
            return
        }
        var data:[String:Any] = args
        data["eventType"] = eventType

        eventSink(data)

    }


}

public class SwiftFlutterRtmpStreamerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_rtmp_streamer", binaryMessenger: registrar.messenger())
    let outputChannel = DartMessenger(messenger: registrar.messenger(), name: "flutter_rtmp_streamer/events")

    let instance = SwiftFlutterRtmpStreamerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
        case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
          break;
      
        default:
          result(FlutterMethodNotImplemented);
      }
  }
}
