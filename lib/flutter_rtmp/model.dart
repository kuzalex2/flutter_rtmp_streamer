import 'package:equatable/equatable.dart';
import 'dart:collection';

class Resolution extends Equatable {
  final int width;
  final int height;

  const Resolution(this.width, this.height);

  @override
  List<Object> get props => [
    width,
    height,
  ];

  @override
  String toString() => "$width × $height";
}


enum StreamingCameraFacing {
  front,
  back,
}



class StreamingState extends Equatable {

  final bool isStreaming;
  final bool isOnPreview;
  final bool isAudioMuted;
  final bool isRtmpConnected;

  final Resolution streamResolution;
  final int cameraOrientation;


  const StreamingState._( {
    required this.isStreaming,
    required this.isOnPreview,
    required this.isAudioMuted,
    required this.isRtmpConnected,
    required this.streamResolution,
    required this.cameraOrientation,
  });

  static const empty = StreamingState._(isStreaming:false,isOnPreview: false,isAudioMuted: false,isRtmpConnected: false, streamResolution: Resolution(0,0), cameraOrientation: 0);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  factory StreamingState.fromJson(Map<String, dynamic> json) =>
      StreamingState._(
          isStreaming: json['isStreaming'] as bool,
          isOnPreview: json['isOnPreview'] as bool,
          isAudioMuted: json['isAudioMuted'] as bool,
          isRtmpConnected: json['isRtmpConnected'] as bool,
          cameraOrientation: json['cameraOrientation'] as int,
          streamResolution: Resolution(
            json['streamResolution']['width'] as int,
            json['streamResolution']['height'] as int,
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



class StreamingSettings extends Equatable {
  final bool serviceInBackground;
  final StreamingCameraFacing cameraFacing;

  final Resolution resolutionFront;
  final Resolution resolutionBack;
  final int videoFps;
  final int videoBitrate;
  final String h264profile;
  final String stabilizationMode;

  final int audioBitrate;
  final int audioSampleRate;
  final int audioChannelCount;

  Resolution get resolution {
    switch (cameraFacing) {
      case StreamingCameraFacing.back: return resolutionBack;
      case StreamingCameraFacing.front: return resolutionFront;
    }
  }


  factory StreamingSettings.initial() => const StreamingSettings(
    serviceInBackground: true,
    cameraFacing : StreamingCameraFacing.front,
    resolutionFront :Resolution(640, 480),
    resolutionBack:Resolution(640, 480),
    videoFps:30,
    videoBitrate: 1024 * 1024,
    h264profile: "main",
    stabilizationMode: "",
    audioBitrate: 64 * 1024,
    audioSampleRate: 48000,
    audioChannelCount: 2,
  );

  const StreamingSettings({
    required this.serviceInBackground,
    required this.cameraFacing,
    required this.resolutionFront,
    required this.resolutionBack,
    required this.videoFps,
    required this.videoBitrate,
    required this.h264profile,
    required this.stabilizationMode,
    required this.audioBitrate,
    required this.audioSampleRate,
    required this.audioChannelCount,
  });

  StreamingSettings copyWith({
    bool? serviceInBackground,
    StreamingCameraFacing? cameraFacing,
    Resolution? resolutionFront,
    Resolution? resolutionBack,
    int? videoFps,
    int? videoBitrate,
    String? h264profile,
    String? stabilizationMode,
    int? audioBitrate,
    int? audioSampleRate,
    int? audioChannelCount,
  }) {
    return StreamingSettings(
      serviceInBackground: serviceInBackground ?? this.serviceInBackground,
      cameraFacing: cameraFacing ?? this.cameraFacing,
      resolutionFront: resolutionFront ?? this.resolutionFront,
      resolutionBack: resolutionBack ?? this.resolutionBack,
      videoFps: videoFps ?? this.videoFps,
      videoBitrate: videoBitrate ?? this.videoBitrate,
      h264profile: h264profile ?? this.h264profile,
      stabilizationMode: stabilizationMode ?? this.stabilizationMode,
      audioBitrate: audioBitrate ?? this.audioBitrate,
      audioSampleRate: audioSampleRate ?? this.audioSampleRate,
      audioChannelCount: audioChannelCount ?? this.audioChannelCount,

    );
  }

  @override
  List<Object> get props => [
    serviceInBackground,
    cameraFacing,
    resolutionFront,
    resolutionBack,
    videoFps,
    videoBitrate,
    h264profile,
    stabilizationMode,
    audioBitrate,
    audioSampleRate,
    audioChannelCount,

  ];

}


class BackAndFrontResolutions extends Equatable {

  final List<Resolution> _back;
  final List<Resolution> _front;

  UnmodifiableListView<Resolution> get back =>
      UnmodifiableListView<Resolution>(_back);

  UnmodifiableListView<Resolution> get front =>
      UnmodifiableListView<Resolution>(_front);

  const BackAndFrontResolutions._({required List<Resolution> back, required List<Resolution> front}):
        _back = back,
        _front = front
  ;

  static const empty = BackAndFrontResolutions._(back:[], front: [],);
  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  factory BackAndFrontResolutions.fromJson(Map<String, dynamic> json) =>
      BackAndFrontResolutions._(
        back: (json['back'] as List<dynamic>).map((e) =>
            Resolution(
              ((e as Map<String, dynamic>)["width"]) as int,
              ((e)["height"]) as int,
            )
        ).toList(),

        front: (json['front'] as List<dynamic>).map((e) =>
            Resolution(
              ((e as Map<String, dynamic>)["width"]) as int,
              ((e)["height"]) as int,
            )
        ).toList(),
      );

  @override
  List<Object> get props => [
    _back,
    _front,
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