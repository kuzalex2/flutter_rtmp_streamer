import 'package:example_basic/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:unicons/unicons.dart';





class CameraSettingsDrawer extends StatefulWidget {
  const CameraSettingsDrawer(this.streamer, {Key? key}) : super(key: key);
  final FlutterRtmpStreamer streamer;


  @override
  _CameraSettingsDrawerState createState() => _CameraSettingsDrawerState();
}

class _CameraSettingsDrawerState extends State<CameraSettingsDrawer> {
  StreamingSettings streamingSettings = StreamingSettings.initial();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              disabled: streamingState.isStreaming,
              value: streamingSettings.serviceInBackground,
              onChanged: (bool value) => setState(() {
                streamingSettings = streamingSettings.copyWith(serviceInBackground: value);
              }),
            ),

            const SettingsLine(text: "VIDEO"),

            SettingsOption(
              text: "Video size (${streamingSettings.resolution.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),


            SettingsOption(
              text: "FFS (${streamingSettings.videoFps.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            SettingsOption(
              text: "Bitrate (${streamingSettings.videoBitrate.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            SettingsOption(
              text: "Profile (${streamingSettings.h264profile.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            SettingsOption(
              text: "Stabilization (${streamingSettings.stabilizationMode.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            const SettingsLine(text: "AUDIO"),

            SettingsOption(
              text: "Bitrate (${streamingSettings.audioBitrate.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            SettingsOption(
              text: "Sample Rate (${streamingSettings.audioSampleRate.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

            SettingsOption(
              text: "Channels Count (${streamingSettings.audioChannelCount.toString()})",
              onTap: () {},
              disabled: streamingState.isStreaming,
            ),

          ],);



        }


      ),
    );
  }
}


class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    Key? key,
    required this.iconData,
    required this.title,
    required this.disabled,
    required this.value,
    required this.onChanged
  }) : super(key: key);

  final IconData iconData;
  final String title;
  final bool disabled;
  final bool value;
  final Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return  SettingsRow(
      left: Icon(iconData),
      title: Text(title),
      right: CupertinoSwitch(
        activeColor: Colors.blue,
        onChanged: disabled ? null : onChanged,
        value: value,
      ),
      isActive: !disabled,
    );
  }
}

class SettingsOption extends StatelessWidget {
  const SettingsOption({
    Key? key,
    this.iconData,
    required this.text,
    required this.disabled,
    required this.onTap,
  }) : super(key: key);
  final IconData? iconData;
  final String text;
  final bool disabled;
  final Function() onTap;




  @override
  Widget build(BuildContext context) {
    return  SettingsRow(
      left: iconData!=null ? Icon(iconData) : null,
      title: Text(text),
      onTap: disabled ? null : onTap,
      right: const Icon(Icons.arrow_right),

      // decoration: const BoxDecoration(
      //   color: Colors.blueGrey ,
      // ),

    );
  }
}



class SettingsLine extends StatelessWidget {
  const SettingsLine({Key? key, this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: text!=null ? const EdgeInsets.symmetric(vertical: 16, horizontal: 16) : null,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.blue))),
        child: Text(text ?? "")
    );
  }
}




class SettingsRow extends StatelessWidget {
  final Widget? left;
  final Widget? title;
  final Widget? right;
  final Function()? onTap;
  final Decoration? decoration;
  final bool _isActive;


  const SettingsRow({
    Key? key,
    this.left,
    this.title,
    this.right,
    this.onTap,
    this.decoration,
    bool isActive = false,
  }) : _isActive = isActive || onTap!=null, super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.all(16),
        child: IconTheme(
          data: _isActive ? const IconThemeData(color: Colors.black) : const IconThemeData(color: Colors.black45),
          child: DefaultTextStyle(
            style: _isActive ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.black45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: left,
                      ),
                      title ?? const SizedBox.shrink(),
                    ],
                  ),
                ),
                right ?? const SizedBox.shrink(),

              ],
            ),
          ),
        ),
      ),
    );
  }

}


