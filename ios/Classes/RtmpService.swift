//
//  RtmpService.swift
//  flutter_rtmp_streamer
//
//  Created by kuzalex on 5/10/22.
//

import Foundation
import AVFoundation

import MetalKit
import HaishinKit
import VideoToolbox
import Logboard

let logger = Logboard.with("com.example.flutter_rtmp_streamer")


class RtpService: NSObject {
    

    private var _dartMessenger:DartMessenger?
    private var _streamingSettings: StreamingSettings?

    private var _rtmpConnection: RTMPConnection?
    private var _rtmpStream: RTMPStream?
    
    private func sendErrorToDart(description: String) {
    
        _dartMessenger?._send(eventType: "Notification", args: ["description":description])
    }

    
    init(dartMessenger: DartMessenger) {
        logger.info("init")
        _dartMessenger = dartMessenger
        
//        _cameraValue = CameraValue(isStreaming: false, isOnPreview: false, isRtmpConnected: false, isStopped: false, initialParams: nil)

        
//        let session = AVAudioSession.sharedInstance()
//        do {
//            // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
//            if #available(iOS 10.0, *) {
//                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
//            } else {
//                session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
//                    AVAudioSession.CategoryOptions.allowBluetooth,
//                    AVAudioSession.CategoryOptions.defaultToSpeaker
//                ])
//                try session.setMode(.default)
//            }
//            try session.setActive(true)
//        } catch {
//            logger.error(error)
//            sendErrorToDart(description: "\(error)")
//        }
//
//        _rtmpConnection = RTMPConnection()
//        _rtmpStream = RTMPStream(connection: _rtmpConnection!)
//
//
//        let preset : AVCaptureSession.Preset = _initialParams!.resolution.toPreset()
//
//        var stabilizationMode:AVCaptureVideoStabilizationMode
//
//        switch _initialParams!.stabilizationMode {
//        case "off": stabilizationMode = .off; break;
//        case "standard": stabilizationMode = .standard; break;
//        case "cinematic": stabilizationMode = .cinematic; break;
//        case "auto": stabilizationMode = .auto; break;
//        default:
//            stabilizationMode = .off
//            break;
//        }
//
//
//        _rtmpStream!.captureSettings = [
//            .sessionPreset: preset,
//            .continuousAutofocus: true,
//            .continuousExposure: true,
//             .preferredVideoStabilizationMode: stabilizationMode
//        ]
//
//        var profileLevel:CFString
//
//        switch _initialParams!.h264profile {
//            case "baseline": profileLevel = kVTProfileLevel_H264_Baseline_AutoLevel; break;
//            case "main": profileLevel = kVTProfileLevel_H264_Main_AutoLevel; break;
//            case "high": profileLevel = kVTProfileLevel_H264_High_AutoLevel; break;
//            default:
//                profileLevel = kVTProfileLevel_H264_Baseline_AutoLevel
//            break;
//        }
//
//
//        _rtmpStream!.videoSettings = [
//            .scalingMode: ScalingMode.letterbox,
//            .profileLevel: profileLevel
//        ]
//
//        onOrientationChange()
//
//
//        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
//
//
//        _rtmpStream!.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
//            logger.warn(error.description)
//            self.outputChannelsSendUpdateStatus(errorDescription: "\(error)")
//        }
//
//
//        _rtmpStream!.captureSettings[.isVideoMirrored] = _initialParams!.cameraFacing == "FRONT"
//        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: _initialParams!.cameraFacing == "FRONT" ? .front : .back)) { error in
//            //FIXME: error processing
//            self._cameraValue!.isOnPreview = false
//
//            self.outputChannelsSendUpdateStatus(errorDescription: error.localizedDescription)
//
//        }
//
//        _cameraValue!.isOnPreview = true
////        _rtmpStream!.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
//
//        _glView?.attachStream(_rtmpStream)
        

        super.init()
    }
    
    func setStreamingSettings(streamingSettings: StreamingSettings) {
        if (_streamingSettings == nil){
            _streamingSettings = streamingSettings
        }
    }
    
    func sendCameraStatusToDart() {
        
        guard let p = _streamingSettings else {
            return
        }
        
        do {
            _dartMessenger?._send(eventType: "StreamingState", args: try getStreamingState( streamingSettings: p ))
        } catch {
            
        }
    }
    
    private func getStreamingState(streamingSettings: StreamingSettings) throws -> [String: String]
    {
        let streamState = StreamingState(
            isStreaming: false,
            isOnPreview: false,
            isAudioMuted: false,
            isRtmpConnected: false,
            streamResolution: Resolution(width: 1, height: 1),
            resolution: Resolution(width: 1, height: 1),
            cameraOrientation: 1,
            streamingSettings: streamingSettings
        )
        
        let reply:[String: String] = [
            "streamState": String(decoding: try JSONEncoder().encode(streamState), as: UTF8.self)
        ]
        
        return reply
    }
    
//    func getStreamingState():MutableMap<String, String>
//        {
//          val reply: MutableMap<String, String> = HashMap()
//
//          reply["streamState"] = Json.encodeToString(StreamState.serializer(), StreamState(
//            isStreaming = camera2Base!!.isStreaming,
//            isOnPreview = camera2Base!!.isOnPreview,
//            isAudioMuted = camera2Base!!.isAudioMuted,
//            isRtmpConnected = isRtmpConnected,
//            resolution = streamingSettings.resolution,
//            streamResolution = if (camera2Base!!.isStreaming)
//              Resolution(width = camera2Base!!.streamWidth, height = camera2Base!!.streamHeight)
//            else
//              Resolution(0,0),
//            cameraOrientation = CameraHelper.getCameraOrientation(contextApp),
//            streamingSettings = streamingSettings,
//          ));
//
//          return reply
//        }
    
}
