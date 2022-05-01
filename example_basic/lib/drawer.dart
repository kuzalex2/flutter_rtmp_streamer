import 'package:example_basic/main.dart';
import 'package:example_basic/settings_rows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:unicons/unicons.dart';



extension _StreamingCameraFacing on StreamingCameraFacing {

  String get name => toString().replaceAll('StreamingCameraFacing.', '');
}

class CameraSettingsDrawer extends StatefulWidget {
  const CameraSettingsDrawer(this.streamer, {Key? key}) : super(key: key);
  final FlutterRtmpStreamer streamer;


  @override
  _CameraSettingsDrawerState createState() => _CameraSettingsDrawerState();
}

class _CameraSettingsDrawerState extends State<CameraSettingsDrawer> {
  // StreamingSettings streamingSettings = StreamingSettings.initial();


  @override
  Widget build(BuildContext context) {


    return Drawer(
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings:"),),

        body: StreamBuilder<StreamingState>(
          stream: widget.streamer.stateStream,
          initialData: widget.streamer.state,
          builder: (context, streamStateSnap) {

            if (!streamStateSnap.hasData) {
              return const Loader();
            }

            final streamingState = streamStateSnap.data!;

            return ListView(children:  [

              SettingsSwitch(
                iconData: UniconsLine.wifi_router,
                title: "Background streaming",
                disabled: streamingState.isStreaming || streamingState.inSettings,
                value: streamingState.streamingSettings.serviceInBackground,
                onChanged: (bool value) => widget.streamer.changeBgMode( value ),
                // setState(() {
                //   streamingSettings = streamingSettings.copyWith(serviceInBackground: value);
                // }),
              ),

              const SettingsLine(text: "VIDEO"),

              // SettingsOption(
              //   text: "Initial camera facing",
              //   rightText: streamingSettings.cameraFacing.name,
              //
              //   onTap: () {},
              //   disabled: streamingState.isStreaming,
              // ),
              //
              // SettingsOption(
              //   text: "Video size (${streamingSettings.resolution.toString()})",
              //   onTap: () {},
              //   disabled: streamingState.isStreaming,
              // ),
              //
              //
              // SettingsOption(
              //   text: "FFS (${streamingSettings.videoFps.toString()})",
              //   onTap: () {},
              //   disabled: streamingState.isStreaming,
              // ),

              VideoBitrateOption(streamer: widget.streamer,),

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

            ],);



          }


        ),
      ),
    );
  }
}


class Tuple<A,B> {
  final A value;
  final B name;

  const Tuple(this.value, this.name);

  //
  //
  // compare by value
  @override
  bool operator ==(Object other) {

    if (other is Tuple<A,B>) {
      return (other.value == value);
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}

class NamedValue<V> extends Tuple<V, String> {
  const NamedValue(V value, String name) : super(value, name);
}

abstract class StreamStateStatelessWidget extends StatelessWidget {
  const StreamStateStatelessWidget({Key? key, required this.streamer}) : super(key: key);
  final FlutterRtmpStreamer streamer;


  Widget builder(BuildContext context, StreamingState state);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamingState>(
        stream: streamer.stateStream,
        initialData: streamer.state,
        builder: (context, streamStateSnap) {
          if (!streamStateSnap.hasData) {
            return const Loader();
          }

          return builder(context, streamStateSnap.data!);
        });
  }
}

class ListDrawer<T extends NamedValue> extends StreamStateStatelessWidget {

  const ListDrawer({
    Key? key,
    required FlutterRtmpStreamer streamer,
    required this.title,
    required this.list,
    this.selectedItem,
    this.onSelected,
  }) : super(key: key, streamer: streamer);

  final String title;
  final List<T> list;
  final T? selectedItem;
  final Function(T)? onSelected;

  @override
  Widget builder(BuildContext context, StreamingState state) {

   return Drawer(
       child: Scaffold(
        appBar: AppBar(title: Text(title),),
        body: ListView(
          children: list.map((item) =>
              InkWell(
                onTap: state.inSettings || state.isStreaming ? null : () {
                  Navigator.of(context).pop();
                  if (onSelected!=null) {
                    onSelected!(item);
                  }
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: item == selectedItem ? (state.isStreaming ? Colors.grey : Colors.lightBlueAccent) : const Color.fromRGBO(0, 0, 0, 0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB (16,8,0,8),
                      child: Text(item.name),
                    )
                ),
              )
          ).toList(),
        ),
       ),
   );
  }


}



class VideoBitrateOption extends StreamStateStatelessWidget {

  const VideoBitrateOption({Key? key, required FlutterRtmpStreamer streamer}) : super(key: key, streamer: streamer);

  static const List<NamedValue<int>> bitrates = [
    NamedValue(-1, "Auto"),
    NamedValue(1 * 1024  * 1024,"1 Mbit/s"), // 360p
    NamedValue(2 * 1024 * 1024, "2 Mbit/s"), // 480p
    NamedValue(5 * 1024 * 1024, "5 Mbit/s"), // 720p
    NamedValue(8 * 1024 * 1024, "8 Mbit/s"), // 1080p
  ];


  @override
  Widget builder(BuildContext context, StreamingState state) {

    final selected = bitrates
        .firstWhere((b) => b.value == state.streamingSettings.videoBitrate, orElse: () => const NamedValue(0, ""));

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
                    streamer.changeVideoBitrate(item.value ),
                )
            )
        ),
      disabled: state.inSettings || state.isStreaming,
    );
  }

}




