// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resolution _$ResolutionFromJson(Map<String, dynamic> json) => Resolution(
      json['width'] as int,
      json['height'] as int,
    );

Map<String, dynamic> _$ResolutionToJson(Resolution instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
    };

StreamingState _$StreamingStateFromJson(Map<String, dynamic> json) =>
    StreamingState(
      isStreaming: json['isStreaming'] as bool,
      isOnPreview: json['isOnPreview'] as bool,
      isAudioMuted: json['isAudioMuted'] as bool,
      isRtmpConnected: json['isRtmpConnected'] as bool,
      streamResolution:
          Resolution.fromJson(json['streamResolution'] as Map<String, dynamic>),
      resolution:
          Resolution.fromJson(json['resolution'] as Map<String, dynamic>),
      cameraOrientation: json['cameraOrientation'] as int,
      streamingSettings: StreamingSettings.fromJson(
          json['streamingSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StreamingStateToJson(StreamingState instance) =>
    <String, dynamic>{
      'isStreaming': instance.isStreaming,
      'isOnPreview': instance.isOnPreview,
      'isAudioMuted': instance.isAudioMuted,
      'isRtmpConnected': instance.isRtmpConnected,
      'streamResolution': instance.streamResolution,
      'resolution': instance.resolution,
      'cameraOrientation': instance.cameraOrientation,
      'streamingSettings': instance.streamingSettings,
    };

StreamingSettings _$StreamingSettingsFromJson(Map<String, dynamic> json) =>
    StreamingSettings(
      serviceInBackground: json['serviceInBackground'] as bool,
      cameraFacing:
          $enumDecode(_$StreamingCameraFacingEnumMap, json['cameraFacing']),
      resolution:
          Resolution.fromJson(json['resolution'] as Map<String, dynamic>),
      videoFps: json['videoFps'] as int,
      videoBitrate: json['videoBitrate'] as int,
      h264profile: json['h264profile'] as String,
      stabilizationMode: json['stabilizationMode'] as String,
      audioBitrate: json['audioBitrate'] as int,
      audioSampleRate: json['audioSampleRate'] as int,
      audioChannelCount: json['audioChannelCount'] as int,
      muteAudio: json['muteAudio'] as bool,
    );

Map<String, dynamic> _$StreamingSettingsToJson(StreamingSettings instance) =>
    <String, dynamic>{
      'serviceInBackground': instance.serviceInBackground,
      'cameraFacing': _$StreamingCameraFacingEnumMap[instance.cameraFacing],
      'resolution': instance.resolution,
      'videoFps': instance.videoFps,
      'videoBitrate': instance.videoBitrate,
      'h264profile': instance.h264profile,
      'stabilizationMode': instance.stabilizationMode,
      'audioBitrate': instance.audioBitrate,
      'audioSampleRate': instance.audioSampleRate,
      'audioChannelCount': instance.audioChannelCount,
      'muteAudio': instance.muteAudio,
    };

const _$StreamingCameraFacingEnumMap = {
  StreamingCameraFacing.front: 'FRONT',
  StreamingCameraFacing.back: 'BACK',
};

BackAndFrontResolutions _$BackAndFrontResolutionsFromJson(
        Map<String, dynamic> json) =>
    BackAndFrontResolutions(
      back: (json['back'] as List<dynamic>)
          .map((e) => Resolution.fromJson(e as Map<String, dynamic>))
          .toList(),
      front: (json['front'] as List<dynamic>)
          .map((e) => Resolution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BackAndFrontResolutionsToJson(
        BackAndFrontResolutions instance) =>
    <String, dynamic>{
      'back': instance.back,
      'front': instance.front,
    };
