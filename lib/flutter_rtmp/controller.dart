
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import 'model.dart';

class FlutterRtmpStreamer {
  static const MethodChannel _channel = MethodChannel('flutter_rtmp_streamer');

  /// native -> flutter channel
  ///
  static const EventChannel _inputChannel =  EventChannel('flutter_rtmp_streamer/events');
  static final Stream _events = _inputChannel.receiveBroadcastStream();

  StreamingState _state;

  /// The current [state].
  StreamingState get state => _state;

  /// states from plugin: isStreaming, isOnPreview, etc...
  ///
  StreamController<StreamingState>? __stateController;
  StreamController<StreamingState> get _stateController {
    return __stateController ??= StreamController<StreamingState>.broadcast();
  }

  /// notifications from plugin: text mesages about errors, etc...
  ///
  StreamController<StreamingNotification>? __nofiticationController;
  StreamController<StreamingNotification> get _nofiticationController {
    return __nofiticationController ??= StreamController<StreamingNotification>.broadcast();
  }


  /// The current state stream.
  Stream<StreamingState> get stateStream => _stateController.stream;
  /// Notifications from streaming module
  Stream<StreamingNotification> get notificationStream => _nofiticationController.stream;

  bool _initialized = false;

  // setSettings(StreamingSettings settings) async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   _state = _state.copyWith(streamingSettings: settings);
  //   if (!_stateController.isClosed) {
  //     _stateController.add(_state);
  //   }
  //
  //
  // }

  _changeState(StreamingState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }


  FlutterRtmpStreamer._(): _state = StreamingState.empty
  {
    _events.listen((event) {
      debugPrint('$event');

      switch (event['eventType']){

      ///
      ///
      ///
        case "StreamingState": {

          _changeState(
              StreamingState.fromJson( jsonDecode(event['streamState']) ).copyWith(inSettings: state.inSettings)
          );

        }
        break;

      ///
      ///
      ///
        case "Notification": {
          final notification = StreamingNotification(description: event['description']);
          if (!_nofiticationController.isClosed) {
            _nofiticationController.add(notification);
          }

        }
        break;

        default:
          debugPrint("Unknown event");
      }






    });
  }

  stopStream() async {

    if (!_initialized) {
      throw 'FlutterRtmpStreamer not initialized!';
    }

    try {
      await _channel.invokeMethod('stopStream');
    } catch (e) {
      debugPrint("stopStream failed: $e");
      rethrow;
    }
  }


  startStream({required String uri, required String streamName}) async {
    if (!_initialized) {
      throw 'FlutterRtmpStreamer not initialized!';
    }

    try {
      await _channel.invokeMethod(
          'startStream',
          {
            // 'muteAudio': value.isAudioMuted,
            'uri': uri,
            'streamName': streamName,
          }
      );

    } catch (e) {
      debugPrint("startStream failed: $e");
      rethrow;
    }
  }



  Future<BackAndFrontResolutions> getResolutions() async {

    if (!_initialized) {
      throw 'FlutterRtmpStreamer not initialized!';
    }

    try {
      final result = await _channel.invokeMethod('getResolutions');

      return BackAndFrontResolutions.fromJson( jsonDecode(result) );
    } catch (e) {
      debugPrint("getResolutions failed: $e");
      rethrow;
    }
  }

  static Future<FlutterRtmpStreamer> init(StreamingSettings streamingSettings) async {

    try {
      if (!(await Permission.microphone.request().isGranted)) {
        throw 'We need microphone permission to stream';
      }

      if (!(await Permission.camera.request().isGranted)) {
        throw 'We need camera permission to stream';
      }

      final instance = FlutterRtmpStreamer._();
      await _channel.invokeMethod('init', {
        'streamingSettings' : jsonEncode(streamingSettings.toJson())
      });
      await instance.stateStream.first;




      instance._initialized = true;

      return instance;
    } catch (e) {
      return Future.error(e);
    }
  }


  changeVideoBitrate(int bitrate) async {

    if (!_initialized) {
      throw 'FlutterRtmpStreamer not initialized!';
    }

    if (state.inSettings) {
      return;
    }

    _changeState(
        _state.copyWith(inSettings: true)
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await _channel.invokeMethod('changeVideoBitrate', {'value': bitrate});
    } catch (e) {
      debugPrint("changeVideoBitrate failed: $e");
      rethrow;
    } finally {
      _changeState(_state.copyWith(inSettings: false));
    }
  }

  changeBgMode(bool value) async {

    if (!_initialized) {
      throw 'FlutterRtmpStreamer not initialized!';
    }

    if (state.inSettings) {
      return;
    }

    _changeState(
        _state.copyWith(inSettings: true)
    );

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await _channel.invokeMethod('changeBgMode', {'value': value});
    } catch (e) {
      debugPrint("changeBgMode failed: $e");
      rethrow;
    } finally {
      _changeState(_state.copyWith(inSettings: false));
    }
  }


  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
