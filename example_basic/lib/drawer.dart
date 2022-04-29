import 'package:example_basic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:unicons/unicons.dart';





class CameraSettingsDrawer extends StatelessWidget {
  final FlutterRtmpStreamer streamer;
  const CameraSettingsDrawer(this.streamer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: StreamBuilder<StreamingState>(
        stream: streamer.stateStream,
        initialData: streamer.state,
        builder: (context, streamStateSnap) {
          if (!streamStateSnap.hasData) {
            return const Loader();
          }

          // bool disabled = true;
          bool disabled = false;

          return FutureBuilder<BackAndFrontResolutions>(
            future: streamer.getResolutions(),
            builder: (context, snapshot) {
              if (snapshot.hasError){
                return Text("${snapshot.error}");
              }

              if (!snapshot.hasData){
                return const Loader();
              }


              // return Text("aaq ${snapshot.data}");
              return ListView(children:  [


                SettingsRow(
                  left: const Icon(UniconsLine.image_resize_landscape),
                  title: Text("Video size (${snapshot.data!.back[0].toString()})"),
                  onTap: disabled ? null : () {},
                  right: const Icon(Icons.arrow_right),

                ),

              ],);
            }
          );
        }
      ),
    );
  }
}





class SettingsRow extends StatelessWidget {
  final Widget? left;
  final Widget? title;
  final Widget? right;
  final Function()? onTap;


  const SettingsRow({
    Key? key,
    this.left,
    this.title,
    this.right,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IconTheme(
          data: onTap != null ? const IconThemeData(color: Colors.black) : const IconThemeData(color: Colors.black45),
          child: DefaultTextStyle(
            style: onTap != null ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.black45),
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





