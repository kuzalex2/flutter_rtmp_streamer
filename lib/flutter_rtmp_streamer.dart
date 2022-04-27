
import 'dart:async';
import 'dart:convert';

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

  final Size streamResolution;
  final int cameraOrientation;


  const StreamingState._( {
    required this.isStreaming,
    required this.isOnPreview,
    required this.isAudioMuted,
    required this.isRtmpConnected,
    required this.streamResolution,
    required this.cameraOrientation,
  });

  static const empty = StreamingState._(isStreaming:false,isOnPreview: false,isAudioMuted: false,isRtmpConnected: false, streamResolution: Size(0,0), cameraOrientation: 0);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  factory StreamingState.fromJson(Map<String, dynamic> json) =>
      StreamingState._(
        isStreaming: json['isStreaming'] as bool,
        isOnPreview: json['isOnPreview'] as bool,
        isAudioMuted: json['isAudioMuted'] as bool,
        isRtmpConnected: json['isRtmpConnected'] as bool,
        cameraOrientation: json['cameraOrientation'] as int,
        streamResolution: Size(
            (json['streamResolution']['width'] as int).toDouble(),
            (json['streamResolution']['height'] as int).toDouble(),
        )
      );


  // StreamingState copyWith({
  //   bool? isStreaming,
  //   bool? isOnPreview,
  //   bool? isAudioMuted,
  //   bool? isRtmpConnected,
  // }) {
  //   return StreamingState(
  //     isStreaming: isStreaming ?? this.isStreaming,
  //     isOnPreview: isOnPreview ?? this.isOnPreview,
  //     isAudioMuted: isAudioMuted ?? this.isAudioMuted,
  //     isRtmpConnected: isRtmpConnected ?? this.isRtmpConnected,
  //   );
  // }

  @override
  List<Object> get props => [
    isStreaming,
    isOnPreview,
    isAudioMuted,
    isRtmpConnected,

    streamResolution,
    cameraOrientation,
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

class FlutterRtmpCameraPreview extends StatelessWidget {
  const FlutterRtmpCameraPreview({Key? key, required this.controller}) : super(key: key);
  final FlutterRtmpStreamer controller;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<StreamingState>(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        if (snapshot.hasError){
          return Text(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const CupertinoActivityIndicator();
        }

        return _FlutterRtmpCameraPreview(key: key, state: snapshot.data!);
      }
    );
  }
}

class _FlutterRtmpCameraPreview extends StatelessWidget {
  const _FlutterRtmpCameraPreview({Key? key, required this.state}) : super(key: key);
  final StreamingState state;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AspectRatio(
        aspectRatio: state.streamResolution.width == 0 ? 1.0 : state.streamResolution.height / state.streamResolution.width,
        child: AndroidView(
          key: key,

          viewType: 'flutter_rtmp_streamer_camera_view',
          onPlatformViewCreated: (id) {
            debugPrint("_onPlatformViewCreated $id");
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
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

  StreamingState _state;

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


  FlutterRtmpStreamer._(): _state = StreamingState.empty
  {
    _events.listen((event) {
      debugPrint('$event');

      switch (event['eventType']){

        ///
        ///
        ///
        case "StreamingState": {


          _state = StreamingState.fromJson( jsonDecode(event['streamState']) );
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


  // _FlutterRtmpCameraPreview cameraPreview({Key? key}) => _FlutterRtmpCameraPreview(key: key,);


  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
