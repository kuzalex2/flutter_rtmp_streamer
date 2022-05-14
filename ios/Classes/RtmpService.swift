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
    
    func setStreamingSettings(streamingSettings: StreamingSettings) {
        if (_streamingState == nil){
            _streamingState = StreamingState(
                isStreaming: false,
                isOnPreview: false,
                isAudioMuted: false,
                isRtmpConnected: false,
                streamResolution: Resolution(width: 1, height: 1),
                resolution: Resolution(width: 1, height: 1),
                cameraOrientation: 1,
                streamingSettings: streamingSettings
            )
            
            _rtmpStream = RTMPStream(connection: _rtmpConnection)
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
        
        
//        _rtmpStream.captureSettings = [
//            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
//            .continuousAutofocus: true,
//            .continuousExposure: true
//            // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
//        ]
        
        
        
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
            .profileLevel: profileLevel
        ]
//        _rtmpStream.videoSettings = [
//            .width: 720,
//            .height: 1280
//        ]
        
//        _rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
//            logger.warn(error.description)
//        }
//        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: streamingState.streamingSettings.cameraFacing == "FRONT" ? .front : .back)) { error in
//            logger.warn(error.description)
//
//        }
        
        _rtmpStream!.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            logger.warn(error.description)
            self.sendErrorToDart(description: "\(error)")
        }
                
        
        _rtmpStream!.captureSettings[.isVideoMirrored] = streamingSettings.cameraFacing == "FRONT"
        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: streamingSettings.cameraFacing == "FRONT" ? .front : .back)) { error in
            
            self.sendErrorToDart(description: "\(error)")
        }
       
        lfView.attachStream(_rtmpStream)
        
        
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
        
        _streamingState!.isOnPreview = false;
        
    }
    
    
    func startStreaming() {
        guard let streamingState = _streamingState else {
            return
        }
        
    }
    
    func stopStreaming() {
        guard let streamingState = _streamingState else {
            return
        }
        
    }
    
}
