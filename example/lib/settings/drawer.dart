
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:flutter_rtmp_streamer_example/settings/settings_rows.dart';
import 'package:flutter_rtmp_streamer_example/settings/utils.dart';
import 'package:flutter_rtmp_streamer_example/settings/widgets.dart';
import 'package:unicons/unicons.dart';
import 'dart:io' show Platform;





class CameraSettingsDrawer extends StatelessWidget {

  final FlutterRtmpStreamer streamer;
  const CameraSettingsDrawer({Key? key, required this.streamer})
      : super(key: key)
  ;



  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings:"),),

        body: StreamingStateBuilder(
            streamer: streamer,
            builder: (context, streamingState) {
              return ListView(
                children: [


                  ///
                  ///
                  /// Background streaming

                  Visibility(
                    visible: Platform.isAndroid,
                    child: SettingsSwitch(
                      iconData: UniconsLine.wifi_router,
                      title: "Background streaming",
                      disabled: streamingState.isStreaming || streamingState.inSettings,
                      value: streamingState.streamingSettings.serviceInBackground,
                      onChanged: (bool value) => streamer.changeStreamingSettings(
                          streamer.state.streamingSettings.copyWith(serviceInBackground: value)
                      ),
                    ),
                  ),

                  const SettingsLine(text: "VIDEO"),

                  VideoResolutionsOption(streamer, streamingState),


                  VideoBitrateOption(streamer, streamingState),


                  CameraFacingOption(streamer, streamingState),


                  VideoFPSOption(streamer, streamingState),


                  Visibility(
                    visible: Platform.isIOS,
                    child: H264ProfileOption(streamer, streamingState)
                  ),



                  Visibility(
                      visible: Platform.isIOS,
                      child: VideoStabilizationModeOption(streamer, streamingState)
                  ),




                  const SettingsLine(text: "AUDIO"),

                  AudioBitrateOption(streamer, streamingState),


                  AudioSampleRateOption(streamer, streamingState),


                  AudioChannelsOption(streamer, streamingState),

                ],
              );
            }
        ),
      ),
    );
  }


}



abstract class OptionsWidget extends StatelessWidget {
  final FlutterRtmpStreamer streamer;
  final StreamingState streamingState;

  const OptionsWidget(this.streamer, this.streamingState,{Key? key}) : super(key: key);
}


///
///
///
class VideoResolutionsOption extends OptionsWidget {

  const VideoResolutionsOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsOption(
      text: "Resolution",
      rightText: "${streamingState.streamingSettings.resolution}",
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => FutureListDrawer<Resolution>(
                      streamer: streamer,
                      title: "Bitrate:",
                      futureList: () async {
                        final result = await streamer.getResolutions();
                        // await Future.delayed(Duration(seconds: 1));
                        // throw "some error";
                        return result.front;
                      }(),
                      selectedItem: streamer.state.streamingSettings.resolution,
                      onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(resolution: item)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }
}



///
///
///
class VideoBitrateOption extends OptionsWidget {

  const VideoBitrateOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);


  static const List<NamedValue<int>> bitrates = [
    // NamedValue(-1, "Auto"),
    NamedValue(1 * 1024  * 1024,"1 Mbit/s"), // 360p
    NamedValue(2 * 1024 * 1024, "2 Mbit/s"), // 480p
    NamedValue(5 * 1024 * 1024, "5 Mbit/s"), // 720p
    NamedValue(8 * 1024 * 1024, "8 Mbit/s"), // 1080p
  ];

  @override
  Widget build(BuildContext context) {

    final selected = bitrates
        .firstWhere((b) => b.value == streamingState.streamingSettings.videoBitrate, orElse: () => const NamedValue(0, ""));

    return SettingsOption(
      text: "Bitrate",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<int>>(
                    streamer: streamer,
                    title: "Bitrate:",
                    list: bitrates,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(videoBitrate: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}



///
///
/// Camera Facing

class CameraFacingOption extends OptionsWidget {

  static const list =  [
      NamedValue(StreamingCameraFacing.front, "front"),
      NamedValue(StreamingCameraFacing.back, "back"),
  ];

  const CameraFacingOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);



  @override
  Widget build(BuildContext context) {

    final selected = list
        .firstWhere((b) => b.value == streamingState.streamingSettings.cameraFacing, orElse: () => const NamedValue(StreamingCameraFacing.back, ""));


    return SettingsOption(
      text: "Camera Facing",
      rightText: streamingState.streamingSettings.cameraFacing.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<StreamingCameraFacing>>(
                    streamer: streamer,
                    checkIsStreaming: false,
                    title: "Camera Facing:",
                    list: list,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(cameraFacing: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings ,
    );

  }

}



///
///
///
class VideoFPSOption extends OptionsWidget {

  const VideoFPSOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);



  @override
  Widget build(BuildContext context) {


    return SettingsOption(
      text: "FPS",
      rightText: streamingState.streamingSettings.videoFps.toString(),
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<int>(
                    streamer: streamer,
                    title: "FPS:",
                    list: const [15,30,25],
                    selectedItem: streamingState.streamingSettings.videoFps,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(videoFps: item)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}


///
///
///



class H264ProfileOption extends OptionsWidget {

  const H264ProfileOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);

  static const List<NamedValue<String>> list = [
    NamedValue("baseline", "Baseline"),
    NamedValue("main", "Main"),
    NamedValue("high", "High"),
  ];

  @override
  Widget build(BuildContext context) {


    final selected = list
        .firstWhere((b) => b.value == streamingState.streamingSettings.h264profile, orElse: () => const NamedValue("", ""));


    return SettingsOption(
      text: "Encoding Profile",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<String>>(
                    streamer: streamer,
                    title: "Choose Encoding Profile:",
                    list: list,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(h264profile: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}


///
///
///



class VideoStabilizationModeOption extends OptionsWidget {

  const VideoStabilizationModeOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);

  static const List<NamedValue<String>> list = [
    NamedValue("off","Off"),
    NamedValue("standard","Standard"),
    NamedValue("cinematic","Cinematic"),
    NamedValue("auto","Auto"),
  ];

  @override
  Widget build(BuildContext context) {


    final selected = list
        .firstWhere((b) => b.value == streamingState.streamingSettings.stabilizationMode, orElse: () => const NamedValue("", ""));


    return SettingsOption(
      text: "Stabilization Mode",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<String>>(
                    streamer: streamer,
                    title: "Stabilization Mode:",
                    list: list,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(stabilizationMode: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }
}



///
///
///
class AudioBitrateOption extends OptionsWidget {

  const AudioBitrateOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);


  static const List<NamedValue<int>> bitrates = [
    NamedValue(-1, "Default"),
    NamedValue(96  * 1024, "96 Kb/s"),
    NamedValue(128 * 1024, "128 Kb/s"),
    NamedValue(160 * 1024, "160 Kb/s"),
    NamedValue(256 * 1024, "256 Kb/s"),
    NamedValue(320 * 1024, "320 Kb/s"),
  ];

  @override
  Widget build(BuildContext context) {

    final selected = bitrates
        .firstWhere((b) => b.value == streamingState.streamingSettings.audioBitrate, orElse: () => const NamedValue(0, ""));

    return SettingsOption(
      text: "Bitrate",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<int>>(
                    streamer: streamer,
                    title: "Audio Bitrate:",
                    list: bitrates,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(audioBitrate: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}



///
///
///
class AudioSampleRateOption extends OptionsWidget {

  const AudioSampleRateOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);


  static const List<NamedValue<int>> list = [
    NamedValue(-1, "Default"),
    NamedValue(48000, "48 KHz"),
    NamedValue(44100, "44.1 KHz"),
    NamedValue(32000, "32 KHz"),
    NamedValue(24000, "24 KHz"),
    NamedValue(22050, "22.05 KHz"),
  ];

  @override
  Widget build(BuildContext context) {

    final selected = list
        .firstWhere((b) => b.value == streamingState.streamingSettings.audioSampleRate, orElse: () => const NamedValue(0, ""));

    return SettingsOption(
      text: "Sample Rate",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<int>>(
                    streamer: streamer,
                    title: "Audio Sample Rate:",
                    list: list,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(audioSampleRate: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}


///
///
///
class AudioChannelsOption extends OptionsWidget {

  const AudioChannelsOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);


  static const List<NamedValue<int>> list = [
    // NamedValue(-1, "Default"),
    NamedValue(1, "Mono"),
    NamedValue(2, "Stereo"),
  ];

  @override
  Widget build(BuildContext context) {

    final selected = list
        .firstWhere((b) => b.value == streamingState.streamingSettings.audioChannelCount, orElse: () => const NamedValue(0, ""));

    return SettingsOption(
      text: "Channels",
      rightText: selected.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<int>>(
                    streamer: streamer,
                    title: "Audio Channels:",
                    list: list,
                    selectedItem: selected,
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(audioChannelCount: item.value)
                        ),
                  )
              )
          ),
      disabled: streamingState.inSettings || streamingState.isStreaming,
    );
  }

}



