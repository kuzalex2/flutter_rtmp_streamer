import Flutter
import UIKit


class CameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private var _rtpService:RtpService

    init(registrar: FlutterPluginRegistrar, rtpService: RtpService) {
        self._rtpService = rtpService
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
            rtpService: _rtpService
           )
    }
}



public class SwiftFlutterRtmpStreamerPlugin: NSObject, FlutterPlugin {
    
 
    private var _rtpService:RtpService
    
    
    init(rtpService: RtpService) {
        logger.info("init")
        _rtpService = rtpService

        super.init()
    }
    
      
    public static func register(with registrar: FlutterPluginRegistrar) {

        

        let channel = FlutterMethodChannel(name: "flutter_rtmp_streamer", binaryMessenger: registrar.messenger())

          
        let instance = SwiftFlutterRtmpStreamerPlugin(rtpService: RtpService(dartMessenger: DartMessenger(messenger: registrar.messenger(), name: "flutter_rtmp_streamer/events")))
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let nativeViewFactory = CameraViewFactory( registrar: registrar, rtpService: instance._rtpService)
        registrar.register(nativeViewFactory, withId: "flutter_rtmp_streamer_camera_view")
    }
    
  
    

    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
      
      
      
      switch call.method {
       /*
        *
        *
        */
        case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
          break;
          
        /*
         *
         *
         */
        case "init":
          
          guard let args0 = call.arguments else {
              result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
              return
          }
          
          guard let args = args0 as? [String: Any] else {
              result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
              return
          }
          
          if let streamingSettings = args["streamingSettings"] as? String {
                            
              do {
                  
                
                  _rtpService.setStreamingSettings( newValue: try JSONDecoder().decode(StreamingSettings.self, from: streamingSettings.data(using: .utf8)!))
                
                  result(true)
                  
                  _rtpService.sendCameraStatusToDart()
                  

              } catch {
                  result(FlutterError.init(code: "init", message: "\(error)", details: nil))

                  
              }
          } else {
              result(FlutterError.init(code: "init", message: "initialParams empty", details: nil))
          }

          break;
          
          
          /*
           *
           *
           */
          case "getResolutions":
          
              let resolutions = BackAndFrontResolutions(back: _rtpService.getSupportedResolutions(), front: _rtpService.getSupportedResolutions())
              
              do {
                  result(String(decoding: try JSONEncoder().encode(resolutions), as: UTF8.self))
              } catch {
                  result(FlutterError.init(code: "getResolutions", message: "\(error)", details: nil))
              }
          break;
          
          
          
          /*
           *
           *
           */
          case "changeStreamingSettings":
            
            guard let args0 = call.arguments else {
                result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
                return
            }
            
            guard let args = args0 as? [String: Any] else {
                result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
                return
            }
            
            if let streamingSettings = args["streamingSettings"] as? String {
                              
                do {
                    
                  
                    _rtpService.setStreamingSettings( newValue: try JSONDecoder().decode(StreamingSettings.self, from: streamingSettings.data(using: .utf8)!))
                  
                    result(true)
                    
                    _rtpService.sendCameraStatusToDart()
                    

                } catch {
                    result(FlutterError.init(code: "changeStreamingSettings", message: "\(error)", details: nil))

                    
                }
            } else {
                result(FlutterError.init(code: "changeStreamingSettings", message: "initialParams empty", details: nil))
            }

            break;
         
          

      
        default:
          result(FlutterMethodNotImplemented);
      }
  }
}
