
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;


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


class StreamingNotification extends Equatable {

  final String description;


  const StreamingNotification( {
    required this.description,
  });


  StreamingNotification copyWith({
    String? description,
  }) {
    return StreamingNotification(
      description: description ?? this.description,
    );
  }

  @override
  List<Object> get props => [
    description,
  ];
}

class _FlutterRtmpCameraPreview extends StatelessWidget {
  const _FlutterRtmpCameraPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (Platform.isAndroid) {
      return AndroidView(
        key: key,

        viewType: 'flutter_rtmp_streamer_camera_view',
        onPlatformViewCreated: (id) {
          debugPrint("_onPlatformViewCreated $id");
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    // if (Platform.isIOS) {
    //
    // }

    return Center(child: Text("FlutterRtmpCamera doesn't support ${Platform.operatingSystem} yet."),);
  }
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

  StreamController<StreamingNotification>? __nofiticationController;
  StreamController<StreamingNotification> get _nofiticationController {
    return __nofiticationController ??= StreamController<StreamingNotification>.broadcast();
  }


  /// The current state stream.
  Stream<StreamingState> get stateStream => _stateController.stream;
  /// Notifications from streaming module
  Stream<StreamingNotification> get notificationStream => _nofiticationController.stream;


  FlutterRtmpStreamer._()
  {
    _events.listen((event) {
      debugPrint('$event');

      switch (event['eventType']){

        ///
        ///
        ///
        case "StreamingState": {

          _state = StreamingState(
              isStreaming: event['isStreaming'].toLowerCase() == 'true',
              isOnPreview: event['isOnPreview'].toLowerCase() == 'true',
              isAudioMuted: event['isAudioMuted'].toLowerCase() == 'true',
              isRtmpConnected: event['isRtmpConnected'].toLowerCase() == 'true'
          );
          if (!_stateController.isClosed) {
            _stateController.add(_state);
          }
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
    await instance.stateStream.first;


    if (!(await Permission.microphone.request().isGranted)) {
      throw 'We need microphone permission to stream';
    }

    if (!(await Permission.camera.request().isGranted)) {
      throw 'We need camera permission to stream';
    }

    return instance;
  }


  _FlutterRtmpCameraPreview cameraPreview({Key? key}) => _FlutterRtmpCameraPreview(key: key,);


  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
