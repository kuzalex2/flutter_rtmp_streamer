import 'package:example_basic/settings_rows.dart';
import 'package:example_basic/utils.dart';
import 'package:example_basic/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:unicons/unicons.dart';



extension _StreamingCameraFacing on StreamingCameraFacing {

  String get name => toString().replaceAll('StreamingCameraFacing.', '');
}



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
            return ListView(children:  [


              ///
              ///
              /// Background streaming

              SettingsSwitch(
                iconData: UniconsLine.wifi_router,
                title: "Background streaming",
                disabled: streamingState.isStreaming || streamingState.inSettings,
                value: streamingState.streamingSettings.serviceInBackground,
                onChanged: (bool value) => streamer.changeStreamingSettings(
                    streamer.state.streamingSettings.copyWith(serviceInBackground: value)
                ),
              ),

              const SettingsLine(text: "VIDEO"),

              VideoResolutionsOption(streamer, streamingState),


              VideoBitrateOption(streamer, streamingState),


              CameraFacingOption(streamer, streamingState),


              VideoFPSOption(streamer, streamingState),







                  // SettingsOption(
                  //   text: "Profile (${streamingSettings.h264profile.toString()})",
                  //   onTap: () {},
                  //   disabled: streamingState.isStreaming,
                  // ),
                  //
                  // SettingsOption(
                  //   text: "Stabilization (${streamingSettings.stabilizationMode.toString()})",
                  //   onTap: () {},
                  //   disabled: streamingState.isStreaming,
                  // ),
                  //


                  // const SettingsLine(text: "AUDIO"),
                  //
                  // SettingsOption(
                  //   text: "Bitrate (${streamingSettings.audioBitrate.toString()})",
                  //   onTap: () {},
                  //   disabled: streamingState.isStreaming,
                  // ),

                  // SettingsOption(
                  //   text: "Sample Rate (${streamingSettings.audioSampleRate.toString()})",
                  //   onTap: () {},
                  //   disabled: streamingState.isStreaming,
                  // ),
                  //
                  // SettingsOption(
                  //   text: "Channels Count (${streamingSettings.audioChannelCount.toString()})",
                  //   onTap: () {},
                  //   disabled: streamingState.isStreaming,
                  // ),

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
                      onSelected: (item) {
                        switch (streamer.state.streamingSettings.cameraFacing) {
                          case StreamingCameraFacing.back:
                            streamer.changeStreamingSettings(
                                streamer.state.streamingSettings.copyWith(resolutionBack: item)
                            );
                            break;
                          case StreamingCameraFacing.front:
                            streamer.changeStreamingSettings(
                                streamer.state.streamingSettings.copyWith(resolutionFront: item)
                            );
                            break;
                        }
                      }
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

  const CameraFacingOption(FlutterRtmpStreamer streamer, StreamingState streamingState, {Key? key}) : super(streamer, streamingState, key: key);



  @override
  Widget build(BuildContext context) {
    return SettingsOption(
      text: "Camera Facing",
      rightText: streamingState.streamingSettings.cameraFacing.name,
      onTap: () =>
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => ListDrawer<NamedValue<StreamingCameraFacing>>(
                    streamer: streamer,
                    title: "Bitrate:",
                    list: const [
                      NamedValue<StreamingCameraFacing>(StreamingCameraFacing.front, "front"),
                      NamedValue<StreamingCameraFacing>(StreamingCameraFacing.back, "back"),
                    ],
                    onSelected: (item) =>
                        streamer.changeStreamingSettings(
                            streamer.state.streamingSettings.copyWith(cameraFacing: item.value)
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

