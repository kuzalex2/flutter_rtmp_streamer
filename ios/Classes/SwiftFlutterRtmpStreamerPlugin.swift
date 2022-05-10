import Flutter
import UIKit


class CameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private var _registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self._registrar = registrar
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return CameraView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            registrar: _registrar
           )
    }
}



public class SwiftFlutterRtmpStreamerPlugin: NSObject, FlutterPlugin {
    
 
    private var _rtpService:RtpService?
    
    
    init(rtpService: RtpService) {
        logger.info("init")
        _rtpService = rtpService

        super.init()
    }
    
      
    public static func register(with registrar: FlutterPluginRegistrar) {

        let channel = FlutterMethodChannel(name: "flutter_rtmp_streamer", binaryMessenger: registrar.messenger())

          
        let instance = SwiftFlutterRtmpStreamerPlugin(rtpService: RtpService(dartMessenger: DartMessenger(messenger: registrar.messenger(), name: "flutter_rtmp_streamer/events")))
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
      guard let args0 = call.arguments else {
          result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
          return
      }
      
      guard let args = args0 as? [String: Any] else {
          result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
          return
      }
      
      
      switch call.method {
        case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
          break;
          
        case "init":
          if let streamingSettings = args["streamingSettings"] as? String {
              
              let decoder = JSONDecoder()
//              let encoder = JSONEncoder()
              
              do {
                  
                
                  _rtpService?.setStreamingSettings( streamingSettings: try decoder.decode(StreamingSettings.self, from: streamingSettings.data(using: .utf8)!))
                
                  result(true)
                  _rtpService?.sendCameraStatusToDart()
                  

                     
                  
//                  var cameraValue = try getCameraValue()
//
//                  let resolutionsBack = getSupportedResolutions();
//
//                  let supportedResolutions = SupportedResolutions(back: resolutionsBack,front: resolutionsBack)
//                  let supportedResolutionsData = try encoder.encode(supportedResolutions)
//
//                  cameraValue["supportedResolutions"] = String(decoding: supportedResolutionsData, as: UTF8.self)
//
//                  result(cameraValue);
//
//                  outputChannelsSendUpdateStatus()
                  
              } catch {
                  result(FlutterError.init(code: "init", message: "\(error)", details: nil))

                  
              }
          } else {
              result(FlutterError.init(code: "init", message: "initialParams empty", details: nil))
          }

          break;
          
//                "init" -> {
//                  try {
//                    val streamingSettingsString: String = call.argument("streamingSettings")!!
//
//                    RtpService.setStreamingSettings( Json.decodeFromString(StreamingSettings.serializer(), streamingSettingsString) )
//                    RtpService.sendCameraStatusToDart()
//                  } catch (e: Exception) {
//                    result.error("init", e.toString(), null)
//                    return;
//                  }
//
//                  result.success( true )
//                  return
//                }
      
        default:
          result(FlutterMethodNotImplemented);
      }
  }
}
