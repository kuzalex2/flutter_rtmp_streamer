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
    
    func setStreamingSettings(newValue: StreamingSettings) {
        if (_streamingState == nil){
            _streamingState = StreamingState(
                isStreaming: false,
                isOnPreview: false,
                isAudioMuted: false,
                isRtmpConnected: false,
                streamResolution: Resolution(width: 1, height: 1),
                resolution: Resolution(width: 1, height: 1),
                cameraOrientation: 1,
                streamingSettings: newValue
            )
            
            _rtmpStream = RTMPStream(connection: _rtmpConnection)
        } else {
           
            if (newValue.cameraFacing != _streamingState!.streamingSettings.cameraFacing){
               switchCamera()
             }
            
            if (!_streamingState!.isStreaming){
                                       
                if newValue.videoBitrate != _streamingState!.streamingSettings.videoBitrate {
                     _streamingState!.streamingSettings.videoBitrate = newValue.videoBitrate
                }
                
                if newValue.videoFps != _streamingState!.streamingSettings.videoFps {
                     _streamingState!.streamingSettings.videoFps = newValue.videoFps
                }
                
                if newValue.audioBitrate != _streamingState!.streamingSettings.audioBitrate {
                     _streamingState!.streamingSettings.audioBitrate = newValue.audioBitrate
                }
                
                if newValue.audioSampleRate != _streamingState!.streamingSettings.audioSampleRate {
                     _streamingState!.streamingSettings.audioSampleRate = newValue.audioSampleRate
                }
                
                
                var needRestartPreview = false
                
                
                
                if (newValue.resolution != _streamingState!.streamingSettings.resolution ){
                    _streamingState!.streamingSettings.resolution = newValue.resolution
                    needRestartPreview = true
                }
                
                if (newValue.h264profile != _streamingState!.streamingSettings.h264profile ){
                    _streamingState!.streamingSettings.h264profile = newValue.h264profile
                    needRestartPreview = true
                }
                
                if (newValue.stabilizationMode != _streamingState!.streamingSettings.stabilizationMode ){
                    _streamingState!.streamingSettings.stabilizationMode = newValue.stabilizationMode
                    needRestartPreview = true
                }
                
                if needRestartPreview && _streamingState!.isOnPreview {
                    let view:MTHKView = _lfView!
                    stopPreview();
                    startPreview(lfView: view)
                }
            }
        }
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
    
    func switchCamera() {
        
        if _streamingState != nil {
            
            if _streamingState!.isOnPreview || _streamingState!.isStreaming {
               
                let newCameraFacing = _streamingState!.streamingSettings.cameraFacing == "FRONT" ? "BACK" : "FRONT"

                let prevVideoIsMirrored = _rtmpStream!.captureSettings[.isVideoMirrored]
                

                _rtmpStream!.captureSettings[.isVideoMirrored] = newCameraFacing == "FRONT"

                _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: newCameraFacing == "FRONT" ? .front : .back)) { error in

                    self._rtmpStream!.captureSettings[.isVideoMirrored] = prevVideoIsMirrored
                    return
                }
                
                _streamingState!.streamingSettings.cameraFacing = newCameraFacing
            }
        }
        
    }
    
    
    
    func startPreview(lfView: MTHKView) {
        guard let streamingState = _streamingState else {
            return
        }
        
        if (streamingState.isOnPreview) {
            return;
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
            .preferredVideoStabilizationMode: stabilizationMode
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
            .width: streamingSettings.resolution.height,
            .height: streamingSettings.resolution.width,
        ]
        
        _rtmpStream!.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            logger.warn(error.description)
            self.sendErrorToDart(description: "\(error)")
        }
                
        
        _rtmpStream!.captureSettings[.isVideoMirrored] = streamingSettings.cameraFacing == "FRONT"
        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: streamingSettings.cameraFacing == "FRONT" ? .front : .back)) { error in
            
            self.sendErrorToDart(description: "\(error)")
        }
       
        _lfView = lfView
        _lfView!.attachStream(_rtmpStream)
        
        
        _streamingState!.isOnPreview = true;
        _streamingState!.resolution =  streamingSettings.resolution
        
        _streamingState!.cameraOrientation = 90
        sendCameraStatusToDart()
        
    }
    
    func stopPreview() {
        
        guard let streamingState = _streamingState else {
            return
        }
        
        if (!streamingState.isOnPreview) {
            return;
        }
        
        _streamingState!.isOnPreview = false
//        _lfView!.attachStream(nil)
        _lfView = nil
        
        
//        _rtmpStream.close()
//        _rtmpConnection.close()
        
    }
    
    
    func startStreaming(uri:String, streamName: String) {

        
        guard let streamingState = _streamingState else {
            return
        }
        
        if (streamingState.isStreaming) {
            return;
        }
        
        let streamingSettings = streamingState.streamingSettings
        
        
        
        _rtmpStream!.audioSettings = [
            .bitrate: streamingSettings.audioBitrate == -1 ? 32 * 1024 :  streamingSettings.audioBitrate,
            .sampleRate: streamingSettings.audioSampleRate == -1 ? 0 : streamingSettings.audioSampleRate,
        ]
        
        _rtmpStream!.videoSettings = [
            .bitrate : streamingSettings.videoBitrate,
//            .maxKeyFrameIntervalDuration : _initialParams!.keyframeInterval,
        ]

        _rtmpStream!.captureSettings[.fps] = streamingSettings.videoFps
        
        
//        _rtmpStream!.audioSettings = [
//            .muted :muteAudio
//        ]
        
        
        
        _uri = uri;
        _streamName = streamName;
        
        _rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//        _rtmpConnection?.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
//        _retryCount = 0
        _rtmpConnection.connect(_uri)
        
    }
    
    func stopStreaming() {
        guard let streamingState = _streamingState else {
            return
        }
        
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

//            _cameraValue?.isRtmpConnected = false
//            outputChannelsSendUpdateStatus(errorDescription: code)
            
//            guard _retryCount <= CameraView.maxRetryCount else {
//                _cameraValue?.isStreaming = false
//                outputChannelsSendUpdateStatus()
//                return
//            }
            
//            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
           
            _rtmpConnection.connect(_uri)
//            _retryCount += 1
            break;
        case RTMPStream.Code.publishBadName.rawValue:
            
            _rtmpConnection.close()
            
//            _cameraValue?.isRtmpConnected = false
//            outputChannelsSendUpdateStatus(errorDescription: code)

//            guard _retryCount <= CameraView.maxRetryCount else {
//                _cameraValue?.isStreaming = false
//                outputChannelsSendUpdateStatus()
//                return
//            }

//            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
          
            _rtmpConnection.connect(_uri)
//            _retryCount += 1
            break;
        case RTMPStream.Code.publishStart.rawValue:
//            _cameraValue?.isRtmpConnected = true
//            outputChannelsSendUpdateStatus()
            
                        
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
//                if (self?._cameraValue?.isRtmpConnected ?? false){
//                    self?._retryCount = 0
//                }
//            }
            break;
        default:
//            outputChannelsSendUpdateStatus(errorDescription: code)
            break
        }
    }
    
}
