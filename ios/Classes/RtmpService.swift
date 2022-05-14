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
        
        _rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
            .continuousAutofocus: true,
            .continuousExposure: true
            // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
        ]
        _rtmpStream.videoSettings = [
            .width: 720,
            .height: 1280
        ]
        
        _rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            logger.warn(error.description)
        }
        _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: streamingState.streamingSettings.cameraFacing == "FRONT" ? .front : .back)) { error in
            logger.warn(error.description)
            
        }
       
//        _rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
        lfView.attachStream(_rtmpStream)
        
        
        _streamingState!.isOnPreview = true;
        _streamingState!.resolution = Resolution(width: 1280, height: 720)
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
