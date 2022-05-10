//
//  CameraView.swift
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



class CameraView: NSObject, FlutterPlatformView {
    
    func view() -> UIView {
        return _view
    }
    
    
    private var _view: UIView
//    private var _initialParams: InitialParams?
//    private var _inputChannel: FlutterMethodChannel
//    private var _outputChannel: DartMessenger
//    private var _rtmpConnection: RTMPConnection?
//    private var _rtmpStream: RTMPStream?
//    private var _cameraValue: CameraValue?
    private var _glView: MTHKView?
    
//    private static let maxRetryCount: Int = 10
//    private var _retryCount:Int = 0
//    private var _uri:String?
//    private var _streamName:String?
    

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        
//        Logboard.with(HaishinKitIdentifier).level = .trace
        
        logger.info("init")

        _view = UIView()
//        _inputChannel = FlutterMethodChannel(name: "stork_rtmp_camera_\(viewId)", binaryMessenger: registrar.messenger())
//        _outputChannel = DartMessenger(messenger: registrar.messenger(), name: "stork_rtmp_camera/cameraEvents\(viewId)")
        
        

        super.init()
        
        _glView = MTHKView(frame: UIScreen.main.bounds)
        _glView!.videoGravity = AVLayerVideoGravity.resizeAspect
        
        _view.addSubview(_glView!)
        _view.backgroundColor = UIColor.black
        
//        _inputChannel.setMethodCallHandler({
//             (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//
//            self.handleMethodCallAsync(call: call, result: result)

//           })
    }
    
    
//    private func outputChannelsSendUpdateStatus(errorDescription:String? = nil) {
//
//        do {
//            let cameraValue = try getCameraValue()
//            _outputChannel._send(eventType: "cameraValue", args: cameraValue)
//        } catch {
//
//        }
//
//
//        if (errorDescription != nil) {
//            _outputChannel._send(eventType: "onError", args: ["description":errorDescription!])
//        }
//
//    }
     
//    private func getSupportedResolutions() -> [Resolution]
//    {
//        var result: [Resolution] = [];
//
//
//        let session:AVCaptureSession = AVCaptureSession();
//        let presets: [AVCaptureSession.Preset] = [
//            AVCaptureSession.Preset.hd4K3840x2160,
//            AVCaptureSession.Preset.hd1920x1080,
//            AVCaptureSession.Preset.hd1280x720,
//            AVCaptureSession.Preset.iFrame960x540,
//            AVCaptureSession.Preset.vga640x480,
//            AVCaptureSession.Preset.cif352x288
//        ];
//
//        for preset in presets {
//            if session.canSetSessionPreset(preset){
//                result.append(Resolution.fromPreset(preset: preset))
//            }
//
//        }
//
//
//        return result;
//    }
//
//    private func getCameraValue() throws -> [String: String]
//    {
//
//        guard let p = _initialParams else {
//            throw "no initialParams"
//        }
//
//        let initialParamsData = try JSONEncoder().encode(p)
//
//
//        guard let cameraValue = _cameraValue else {
//            throw "no cameraValue"
//        }
//
//        var reply:[String: String] = [
//            "isStreaming": String(cameraValue.isStreaming),
//            "isOnPreview": String(cameraValue.isOnPreview),
//            "isRtmpConnected": String(cameraValue.isRtmpConnected),
//            "isStopped": String(cameraValue.isStopped),
//            "initialParams":String(decoding: initialParamsData, as: UTF8.self),
//
//        ]
//
//        if (cameraValue.isStreaming){
//            if let muted = _rtmpStream!.audioSettings[.muted] as? Bool  {
//                reply["isAudioMuted"] = String( muted )
//            }
//        }
//
//
//        return reply
//    }
//
//    func handleMethodCallAsync(call: FlutterMethodCall, result: @escaping FlutterResult) {
//
//
//        logger.info("methodCall \(call.method)")
//
//
//
//        guard let args0 = call.arguments else {
//            result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
//            return
//        }
//
//        guard let args = args0 as? [String: Any] else {
//            result(FlutterError.init(code: call.method, message: "args is empty", details: nil))
//            return
//        }
//
//        switch call.method {
//
//
//            case "updateOrientation":
//                onOrientationChange();
//            break;
//
//            case "init":
//
//                if let initialParamsStr = args["initialParams"] as? String
//                {
//
//
////                    if (_rtmpConnection != nil) {
////                        do_dispose();
////                    }
//
//
//                    let decoder = JSONDecoder()
//                    let encoder = JSONEncoder()
//
//                    do {
//                        if (_rtmpConnection==nil){
//                            _initialParams = try decoder.decode(InitialParams.self, from: initialParamsStr.data(using: .utf8)!)
//
//
//                            try do_init();
//                        }
//
//                        var cameraValue = try getCameraValue()
//
//                        let resolutionsBack = getSupportedResolutions();
//
//                        let supportedResolutions = SupportedResolutions(back: resolutionsBack,front: resolutionsBack)
//                        let supportedResolutionsData = try encoder.encode(supportedResolutions)
//
//                        cameraValue["supportedResolutions"] = String(decoding: supportedResolutionsData, as: UTF8.self)
//
//                        result(cameraValue);
//
//                        outputChannelsSendUpdateStatus()
//
//                    } catch {
//                        result(FlutterError.init(code: "init", message: "\(error)", details: nil))
//
//
//                    }
//
//
//                    // parse initialParamsStr
//                } else {
//                    result(FlutterError.init(code: "init", message: "initialParams empty", details: nil))
//                }
//
//                break;
//            case "dispose":
//                do_dispose();
//                break;
//            case "stopIfNotServiceLocked":
//                do_deinit()
//                result(true)
////                outputChannelsSendUpdateStatus()
//                break
//            case "switchCamera":
//
//                if (_initialParams == nil || _rtmpStream == nil){
//                    result(FlutterError.init(code: "switchCamera", message: "switchCamera failed", details: nil))
//                    return
//                }
//
//
//
//                let prevCameraFacing = _initialParams!.cameraFacing
//                let isVideoMirrored = _rtmpStream!.captureSettings[.isVideoMirrored]
//
//
//                _initialParams!.cameraFacing = _initialParams!.cameraFacing == "FRONT" ? "BACK" : "FRONT"
//                _rtmpStream!.captureSettings[.isVideoMirrored] = _initialParams!.cameraFacing == "FRONT"
//
//                _rtmpStream!.attachCamera(DeviceUtil.device(withPosition: _initialParams!.cameraFacing == "FRONT" ? .front : .back)) { error in
//
//                    self._rtmpStream!.captureSettings[.isVideoMirrored] = isVideoMirrored
//                    self._initialParams!.cameraFacing = prevCameraFacing
//                    self.outputChannelsSendUpdateStatus(errorDescription: error.localizedDescription)
//                }
//
//
//                result(true)
//                outputChannelsSendUpdateStatus()
//                break
//
//            case "switchLantern":
//                if (_initialParams == nil || _rtmpStream == nil){
//                    result(FlutterError.init(code: "switchLantern", message: "switchLantern failed", details: nil))
//                    return
//                }
//
//                _rtmpStream!.torch.toggle()
//                result(true)
//                outputChannelsSendUpdateStatus()
//
//            case "startStreaming":
//
//                if (_initialParams == nil || _rtmpStream == nil || _rtmpConnection == nil || _cameraValue == nil){
//                    result(FlutterError.init(code: "startStreaming", message: "startStreaming failed", details: nil))
//                    return
//                }
//
//                if (_cameraValue!.isStreaming) {
//                    result(true)
//                    return
//                }
//
//                _rtmpStream!.audioSettings = [
//                    .bitrate: _initialParams!.audioBitrate == -1 ? 32 * 1024 :  _initialParams!.audioBitrate,
//                    .sampleRate: _initialParams!.audioSampleRate == -1 ? 0 : _initialParams!.audioSampleRate,
//                ]
//
//                var bitrate = _initialParams!.bitrate
//
//                if (bitrate < 0) {
//                    bitrate = _initialParams!.suggested_bitrate
//                }
//
//                logger.info("-- bitrate = \(bitrate)")
//
//                _rtmpStream!.videoSettings = [
//                    .bitrate : bitrate,
//                    .maxKeyFrameIntervalDuration : _initialParams!.keyframeInterval,
//                ]
//
//                _rtmpStream!.captureSettings[.fps] = _initialParams!.fps
//
//
//                if let uri = args["uri"] as? String,
//                   let streamName = args["streamName"] as? String,
//                   let muteAudio = args["muteAudio"] as? Bool
//                {
//                    _uri = uri
//                    _streamName = streamName
//
//                    _rtmpStream!.audioSettings = [
//                        .muted :muteAudio
//                    ]
//
//                    _cameraValue!.isRtmpConnected = false
//
//                    _rtmpConnection?.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//                    _rtmpConnection?.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
//                    _retryCount = 0
//                    _rtmpConnection?.connect(_uri!)
//
//                    _cameraValue!.isStreaming = true
//                }
//
//                result(true)
//                outputChannelsSendUpdateStatus()
//            break;
//
//            case "stopStreaming":
//                if (_initialParams == nil || _rtmpStream == nil || _rtmpConnection == nil || _cameraValue == nil){
//                    result(FlutterError.init(code: "stopStreaming", message: "stopStreaming failed", details: nil))
//                    return
//                }
//
//                if (!_cameraValue!.isStreaming) {
//                    result(true)
//                    return
//                }
//
//                _cameraValue!.isRtmpConnected = false
//                _cameraValue!.isStreaming = false
//                _rtmpConnection?.close()
//
//                _rtmpConnection!.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
//                _rtmpConnection!.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
//
//                result(true)
//                outputChannelsSendUpdateStatus()
//            break;
//
//            case "muteAudio":
//                if (_initialParams == nil || _rtmpStream == nil || _rtmpConnection == nil || _cameraValue == nil){
//                    return
//                }
//
//                if (!_cameraValue!.isStreaming) {
//                    result(true)
//                    return
//                }
//
//                if let muteAudio = args["mute"] as? Bool {
//                    _rtmpStream!.audioSettings = [
//                        .muted :muteAudio
//                    ]
//                }
//
//                result(true)
//                outputChannelsSendUpdateStatus()
//            break;
//
//            default:
//                result(FlutterMethodNotImplemented);
//        }
//    }
//
//    func view() -> UIView {
//        return _view
//    }
//
//
//
//
//    func do_init() throws {
//
//
//        _cameraValue = CameraValue(isStreaming: false, isOnPreview: false, isRtmpConnected: false, isStopped: false, initialParams: nil)
//
//
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
//            self.outputChannelsSendUpdateStatus(errorDescription: "\(error)")
//        }
//
//        _rtmpConnection = RTMPConnection()
//        _rtmpStream = RTMPStream(connection: _rtmpConnection!)
//
//
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
//
//    }
//
//    func do_dispose() {
//        logger.info("dispose")
//
//        do_deinit()
//        _glView?.attachStream(nil)
//        _glView?.view().removeFromSuperview()
//        _glView = nil
//
////        _view
////        _inputChannel
////        _outputChannel
//    }
//
//    func do_deinit() {
//        logger.info("do_deinit")
//
//        //        rtmpStream.removeObserver(self, forKeyPath: "currentFPS")
//        _rtmpStream?.close()
//        _rtmpStream?.dispose()
//        _rtmpStream = nil
//
//        _rtmpConnection?.close()
//        _rtmpConnection = nil
//
//        _cameraValue = nil
//    }
//
//
//    private func onOrientationChange() {
//        guard let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) else {
//            return
//        }
//        guard let rtmpStream = _rtmpStream else {
//            return
//        }
//        guard let initialParams = _initialParams else {
//            return
//        }
//
//        _glView?.frame = UIScreen.main.bounds
//
//        if (initialParams.verticalStream) {
//            rtmpStream.videoSettings = [
//                .width: initialParams.resolution.height,
//                .height: initialParams.resolution.width,
//            ]
//        } else {
//            rtmpStream.videoSettings = [
//                .width: initialParams.resolution.width,
//                .height: initialParams.resolution.height,
//            ]
//        }
//
//        rtmpStream.orientation = orientation
//
//    }
//
//
//    @objc
//    private func onOrientationChange(_ notification: Notification) {
//
//        onOrientationChange()
//
//    }
//
//    @objc
//    private func rtmpStatusHandler(_ notification: Notification) {
//        let e = Event.from(notification)
//        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
//            return
//        }
//        logger.info("rtmpHandler status \(code)")
//        switch code {
//
//
//        case RTMPConnection.Code.connectSuccess.rawValue:
////            _cameraValue?.isRtmpConnected = true
////            outputChannelsSendUpdateStatus()
//
//            guard let streamName = _streamName else {
//                return
//            }
//
//            _rtmpStream?.publish(streamName)
//
//        case RTMPConnection.Code.connectFailed.rawValue,
//             RTMPConnection.Code.connectClosed.rawValue:
//
//            _cameraValue?.isRtmpConnected = false
//            outputChannelsSendUpdateStatus(errorDescription: code)
//
//            guard _retryCount <= CameraView.maxRetryCount else {
//                _cameraValue?.isStreaming = false
//                outputChannelsSendUpdateStatus()
//                return
//            }
//
//            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
//            guard let uri = _uri else {
//                return
//            }
//            _rtmpConnection?.connect(uri)
//            _retryCount += 1
//            break;
//        case RTMPStream.Code.publishBadName.rawValue:
//
//            _rtmpConnection?.close()
//
//            _cameraValue?.isRtmpConnected = false
//            outputChannelsSendUpdateStatus(errorDescription: code)
//
//            guard _retryCount <= CameraView.maxRetryCount else {
//                _cameraValue?.isStreaming = false
//                outputChannelsSendUpdateStatus()
//                return
//            }
//
//            Thread.sleep(forTimeInterval: min(8, pow(2.0, Double(_retryCount))))
//            guard let uri = _uri else {
//                return
//            }
//            _rtmpConnection?.connect(uri)
//            _retryCount += 1
//            break;
//        case RTMPStream.Code.publishStart.rawValue:
//            _cameraValue?.isRtmpConnected = true
//            outputChannelsSendUpdateStatus()
//
////            _retryCount = 0
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
//                if (self?._cameraValue?.isRtmpConnected ?? false){
//                    self?._retryCount = 0
//                }
//            }
//            break;
//        default:
//            outputChannelsSendUpdateStatus(errorDescription: code)
//            break
//        }
//    }
//
//
//    @objc
//    private func rtmpErrorHandler(_ notification: Notification) {
//        logger.error("rtmpHandler error \(notification)")
//
//        // FIXME
////        outputChannelsSendUpdateStatus(errorDescription: <#T##String?#>)
//
//        _cameraValue?.isRtmpConnected = false
//        outputChannelsSendUpdateStatus()
//
//
//        guard let rtmpConnection = _rtmpConnection else {
//            _cameraValue?.isStreaming = false
//            outputChannelsSendUpdateStatus()
//            return
//        }
//
//        guard let uri = _uri else {
//            _cameraValue?.isStreaming = false
//            outputChannelsSendUpdateStatus()
//            return
//        }
//
//        rtmpConnection.connect(uri)
//    }

    
}
