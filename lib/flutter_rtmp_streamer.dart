
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';


class StreamingState extends Equatable {

  final bool isStreaming;
  final bool isOnPreview;
  final bool isAudioMuted;
  final bool isRtmpConnected;


  const StreamingState( {
    required this.isStreaming,
    required this.isOnPreview,
    required this.isAudioMuted,
    required this.isRtmpConnected,
  });

  // static const  = PermissionState(
  //   micStatus: MyPermissionStatus.unknown,
  //   camStatus:  MyPermissionStatus.unknown,
  // );

  StreamingState copyWith({
    bool? isStreaming,
    bool? isOnPreview,
    bool? isAudioMuted,
    bool? isRtmpConnected,
  }) {
    return StreamingState(
      isStreaming: isStreaming ?? this.isStreaming,
      isOnPreview: isOnPreview ?? this.isOnPreview,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isRtmpConnected: isRtmpConnected ?? this.isRtmpConnected,
    );
  }

  @override
  List<Object> get props => [
    isStreaming,
    isOnPreview,
    isAudioMuted,
    isRtmpConnected,
  ];
}


class FlutterRtmpStreamer {
  static const MethodChannel _channel = MethodChannel('flutter_rtmp_streamer');

  /// native -> flutter channel
  ///
  static const EventChannel _inputChannel =  EventChannel('flutter_rtmp_streamer/events');
  static final Stream _events = _inputChannel.receiveBroadcastStream();

  late StreamingState _state;

  /// The current [state].
  StreamingState get state => _state;

  StreamController<StreamingState>? __stateController;
  StreamController<StreamingState> get _stateController {
    return __stateController ??= StreamController<StreamingState>.broadcast();
  }


  /// The current state stream.
  Stream<StreamingState> get stream => _stateController.stream;


  FlutterRtmpStreamer._()
  {
    _events.listen((event) {
      debugPrint('$event');
      _state = StreamingState(
          isStreaming: event['isStreaming'].toLowerCase() == 'true',
          isOnPreview: event['isOnPreview'].toLowerCase() == 'true',
          isAudioMuted: event['isAudioMuted'].toLowerCase() == 'true',
          isRtmpConnected: event['isRtmpConnected'].toLowerCase() == 'true'
      );

      if (!_stateController.isClosed) {
        _stateController.add(_state);
      }


    });
  }

  startStream({required String uri, required String streamName}) async {
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

  stopStream() async {
    try {
      await _channel.invokeMethod('stopStream');
    } catch (e) {
      debugPrint("stopStream failed: $e");
      rethrow;
    }
  }

  static Future<FlutterRtmpStreamer> init() async {
    final instance = FlutterRtmpStreamer._();
    _channel.invokeMethod('getStreamerState');
    await instance.stream.first;


    return instance;
  }


  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
