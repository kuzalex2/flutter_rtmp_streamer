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
    

    private var _dartMessenger:DartMessenger
    private var _streamingState:StreamingState?

    private var _rtmpConnection: RTMPConnection = RTMPConnection()
    private var _rtmpStream: RTMPStream!
    private var _lfView: MTHKView?
    
    private static let MAX_RETRY_COUNT: Int = 10
    
    
    private var _retryCount:Int = 0
    private var _uri: String = ""
    private var _streamName: String = ""
    
    private func sendErrorToDart(description: String) {
    
        _dartMessenger.send(eventType: "Notification", args: ["description":description])
    }

    
    func getSupportedResolutions() -> [Resolution]
    {
        var result: [Resolution] = [];
        
        let session:AVCaptureSession = AVCaptureSession();
        let presets: [AVCaptureSession.Preset] = [
            AVCaptureSession.Preset.hd4K3840x2160,
            AVCaptureSession.Preset.hd1920x1080,
            AVCaptureSession.Preset.hd1280x720,
            AVCaptureSession.Preset.iFrame960x540,
            AVCaptureSession.Preset.vga640x480,
            AVCaptureSession.Preset.cif352x288
        ];
        
        for preset in presets {
            if session.canSetSessionPreset(preset){
                result.append(Resolution.fromPreset(preset: preset))
            }
            
        }
        
        
        return result;
    }
    
    init(dartMessenger: DartMessenger) {
        logger.info("init")
        _dartMessenger = dartMessenger
    
        super.init()
    }
    
    func sendCameraStatusToDart() {
        
        guard let streamingState = _streamingState else {
            return
        }
        
        
        do {
            
            let reply:[String: String] = [
                "streamState": String(decoding: try JSONEncoder().encode(streamingState), as: UTF8.self)
            ]
            
            _dartMessenger.send(eventType: "StreamingState", args: reply)
            
        } catch {
            debugPrint("sendCameraStatusToDart failed \(error)")
        }
    }
    
    
    func setStreamingSettings(newValue: StreamingSettings) {
        if (_streamingState == nil){
            _streamingState = StreamingState(
                isStreaming: false,
                isOnPreview: false,
                isAudioMuted: newValue.muteAudio,
                isRtmpConnected: false,
                streamResolution: Resolution(width: 1, height: 1),
                resolution: Resolution(width: 1, height: 1),
                cameraOrientation: 1,
                streamingSettings: newValue
            )
            
            _rtmpStream = RTMPStream(connection: _rtmpConnection)
            
            setupSession()
            
        } else {
            
            if (true || !_streamingState!.isStreaming){
                
                if (newValue != _streamingState!.streamingSettings){
                
                    _streamingState!.streamingSettings = newValue
                    _streamingState!.isAudioMuted = _streamingState!.streamingSettings.muteAudio
                    setupSession()
                }
            }
        }
    }
    
    
    func setupSession() {
        guard let streamingState = _streamingState else {
            return
        }
        
        let streamingSettings = streamingState.streamingSettings
        
        
        
        let session = AVAudioSession.sharedInstance()
        do {
            // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
            if #available(iOS 10.0, *) {
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            } else {
                session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
                    AVAudioSession.CategoryOptions.allowBluetooth,
                    AVAudioSession.CategoryOptions.defaultToSpeaker
                ])
                try session.setMode(.default)
            }
            try session.setActive(true)
        } catch {
            logger.error(error)
            sendErrorToDart(description: "\(error)")
        }
        
        let preset : AVCaptureSession.Preset = streamingSettings.resolution.toPreset()
        
        var stabilizationMode:AVCaptureVideoStabilizationMode

        switch streamingSettings.stabilizationMode {
            case "off": stabilizationMode = .off; break;
            case "standard": stabilizationMode = .standard; break;
            case "cinematic": stabilizationMode = .cinematic; break;
            case "auto": stabilizationMode = .auto; break;
            default:
                stabilizationMode = .off
                break;
        }
        

        _rtmpStream!.captureSettings = [
            .sessionPreset: preset,
            .continuousAutofocus: true,
            .continuousExposure: true,
            .preferredVideoStabilizationMode: stabilizationMode,
            .fps: streamingSettings.videoFps
        ]
        
        
        var profileLevel:CFString

        switch streamingSettings.h264profile {
            case "baseline": profileLevel = kVTProfileLevel_H264_Baseline_AutoLevel; break;
            case "main": profileLevel = kVTProfileLevel_H264_Main_AutoLevel; break;
            case "high": profileLevel = kVTProfileLevel_H264_High_AutoLevel; break;
            default:
                profileLevel = kVTProfileLevel_H264_Baseline_AutoLevel
            break;
        }
        
        _rtmpStream!.videoSettings = [
            .scalingMode: ScalingMode.letterbox,
            .profileLevel: profileLevel,
            .bitrate : streamingSettings.videoBitrate,
        ]
        
        
        
        _onOrientationChange()
        NotificationCenter.default.addObserver(self, selector: #selector(_onOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
        
        _rtmpStream!.audioSettings = [
            .bitrate: streamingSettings.audioBitrate == -1 ? 32 * 1024 :  streamingSettings.audioBitrate,
            .sampleRate: streamingSettings.audioSampleRate == -1 ? 0 : streamingSettings.audioSampleRate,
            .muted: streamingSettings.muteAudio
        ]

        
        _rtmpStream!.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            logger.warn(error.description)
            self.sendErrorToDart(description: "\(error)")
        }
                
        
        _rtmpStream!.captureSettings[.isVideoMirrored] = streamingSettings.cameraFacing == "FRONT"
        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: streamingSettings.cameraFacing == "FRONT" ? .front : .back)) { error in
            
            self.sendErrorToDart(description: "\(error)")
        }
        
        
       
        
        sendCameraStatusToDart()
        
    }
    
    @objc
    private func _onOrientationChange(_ notification: Notification) {
        
        _onOrientationChange()
        sendCameraStatusToDart()
        
    }
    
    private func _onOrientationChange() {
        guard let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) else {
            return
        }
        
        guard let streamingState = _streamingState else {
            return
        }
        
        let streamingSettings = streamingState.streamingSettings
        
        
        if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ||  UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.unknown) {
            _rtmpStream!.videoSettings = [
                .width: streamingSettings.resolution.height,
                .height: streamingSettings.resolution.width,
            ];
            _streamingState!.cameraOrientation = 90

        } else if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portraitUpsideDown) {
            _rtmpStream!.videoSettings = [
                .width: streamingSettings.resolution.height,
                .height: streamingSettings.resolution.width,
            ];
            _streamingState!.cameraOrientation = 270

        } else if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) {
            _rtmpStream!.videoSettings = [
                .width: streamingSettings.resolution.width,
                .height: streamingSettings.resolution.height,
               
            ];
            _streamingState!.cameraOrientation = 180

        } else if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight) {
            
            _rtmpStream!.videoSettings = [
                .width: streamingSettings.resolution.width,
                .height: streamingSettings.resolution.height,
               
            ];
            _streamingState!.cameraOrientation = 0

        }
            
            
        _rtmpStream.orientation = orientation
        
        _streamingState!.resolution =  streamingSettings.resolution
        _streamingState!.streamResolution =  streamingSettings.resolution
       }

    
    
    func startPreview(lfView: MTHKView) {
        guard let streamingState = _streamingState else {
            return
        }
        
        if (!streamingState.isOnPreview) {
            _lfView = lfView
            _lfView!.attachStream(_rtmpStream)
        
            _streamingState!.isOnPreview = true;
            sendCameraStatusToDart()
        }
    }
    
    func stopPreview() {
        
        guard let streamingState = _streamingState else {
            return
        }
        
        if (streamingState.isOnPreview) {
            _lfView!.attachStream(nil)
            _lfView = nil
        
            _streamingState!.isOnPreview = false;
            sendCameraStatusToDart()
        }
//        _rtmpStream.close()
//        _rtmpConnection.close()
    }
    
    
    func startStreaming(uri:String, streamName: String) {
        
        guard let streamingState = _streamingState else {
            return
        }
        
        if (!streamingState.isStreaming) {
            
            _uri = uri;
            _streamName = streamName;
            _retryCount = 0;
            
            _rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    //        _rtmpConnection?.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
            _rtmpConnection.connect(_uri)
        
            _streamingState!.isStreaming = true;
            sendCameraStatusToDart()
        }
        
    }
    
    func stopStreaming() {

        guard let streamingState = _streamingState else {
            return
        }
        
        if (streamingState.isStreaming) {
            
            _streamingState!.isRtmpConnected = false
            _streamingState!.isStreaming = false
            _rtmpConnection.close()
            
            _rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//            _rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
            
            
            sendCameraStatusToDart()
        }
        
//        _rtmpStream?.close()
//        _rtmpStream?.dispose()
//        _rtmpConnection?.close()
    }
    
    
    
    @objc
    private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        logger.info("rtmpStatusHandler status \(code)")
        switch code {
      
            
        case RTMPConnection.Code.connectSuccess.rawValue:

            _rtmpStream?.publish(_streamName)
            
        case RTMPConnection.Code.connectFailed.rawValue,
             RTMPConnection.Code.connectClosed.rawValue:

            _streamingState?.isRtmpConnected = false
            sendCameraStatusToDart()
            sendErrorToDart(description: code)
            
            guard _retryCount <= RtpService.MAX_RETRY_COUNT else {
                _streamingState?.isStreaming = false
                sendCameraStatusToDart()
                return
            }
            
            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
           
            _rtmpConnection.connect(_uri)
            _retryCount += 1
            break;
        case RTMPStream.Code.publishBadName.rawValue:
            
            _rtmpConnection.close()
            
            _streamingState?.isRtmpConnected = false
            sendCameraStatusToDart()
            sendErrorToDart(description: code)

            guard _retryCount <= RtpService.MAX_RETRY_COUNT else {
                _streamingState?.isStreaming = false
                sendCameraStatusToDart()
                return
            }

            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
          
            _rtmpConnection.connect(_uri)
            _retryCount += 1
            break;
        case RTMPStream.Code.publishStart.rawValue:
            _streamingState?.isRtmpConnected = true
            sendCameraStatusToDart()
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if (self?._streamingState?.isRtmpConnected ?? false){
                    self?._retryCount = 0
                }
            }
            break;
        default:
            sendErrorToDart(description: code)
            break
        }
    }
    
}
