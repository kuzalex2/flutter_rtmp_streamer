import 'package:equatable/equatable.dart';
import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

///
/// fvm flutter packages pub run  build_runner build
///
///

@JsonSerializable()
class Resolution extends Equatable {
  final int width;
  final int height;

  const Resolution(this.width, this.height);

  factory Resolution.fromJson(Map<String, dynamic> json) => _$ResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$ResolutionToJson(this);

  @override
  List<Object> get props => [
    width,
    height,
  ];

  @override
  String toString() => "$width × $height";
}

enum StreamingCameraFacing {
  @JsonValue('FRONT')
  front,
  @JsonValue('BACK')
  back,
}


@JsonSerializable()
class StreamingState extends Equatable {

  final bool isStreaming;
  final bool isOnPreview;
  final bool isAudioMuted;
  final bool isRtmpConnected;

  final Resolution streamResolution;
  final int cameraOrientation;

  final StreamingSettings streamingSettings;

  @JsonKey(ignore: true)
  final bool inSettings;

  const StreamingState( {
    required this.isStreaming,
    required this.isOnPreview,
    required this.isAudioMuted,
    required this.isRtmpConnected,
    required this.streamResolution,
    required this.cameraOrientation,
    required this.streamingSettings,
    this.inSettings = false,
  });

  static const empty = StreamingState(
      isStreaming:false,
      isOnPreview: false,
      isAudioMuted: false,
      isRtmpConnected: false,
      streamResolution: Resolution(0,0),
      cameraOrientation: 0,
      inSettings: false,
      streamingSettings: StreamingSettings.initial,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  factory StreamingState.fromJson(Map<String, dynamic> json) => _$StreamingStateFromJson(json);
  Map<String, dynamic> toJson() => _$StreamingStateToJson(this);


  StreamingState copyWith({
    bool? inSettings,
  }) {
    return StreamingState(
      isStreaming: isStreaming,
      isOnPreview: isOnPreview,
      isAudioMuted: isAudioMuted,
      isRtmpConnected: isRtmpConnected,
      cameraOrientation: cameraOrientation,
      streamResolution: streamResolution,
      streamingSettings: streamingSettings,
      inSettings: inSettings ?? this.inSettings,
    );
  }

  @override
  List<Object> get props => [
    isStreaming,
    isOnPreview,
    isAudioMuted,
    isRtmpConnected,

    streamResolution,
    cameraOrientation,
    inSettings,

    streamingSettings,
  ];
}


///
///
@JsonSerializable()
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

  static const initial = StreamingSettings(
    // serviceInBackground: true,
    serviceInBackground: false,
    cameraFacing : StreamingCameraFacing.back,
    resolutionFront: Resolution(640, 480),
    resolutionBack: Resolution(640, 480),
    videoFps:30,
    videoBitrate: 1024 * 1024,
    h264profile: "main",
    stabilizationMode: "auto",
    audioBitrate: 96 * 1024,
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


  factory StreamingSettings.fromJson(Map<String, dynamic> json) => _$StreamingSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$StreamingSettingsToJson(this);


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



///
///
@JsonSerializable()
class BackAndFrontResolutions extends Equatable {
  final List<Resolution> back;
  final List<Resolution> front;

  const BackAndFrontResolutions({
    required this.back,
    required this.front,

  });


  factory BackAndFrontResolutions.fromJson(Map<String, dynamic> json) => _$BackAndFrontResolutionsFromJson(json);
  Map<String, dynamic> toJson() => _$BackAndFrontResolutionsToJson(this);




  @override
  List<Object> get props => [
    back,
    front,

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