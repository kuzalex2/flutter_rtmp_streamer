import 'package:example_basic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';





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
              return ListView(children: [
                buildEntityRow2(disabled, Icons.timelapse,
                  "Video size (${snapshot.data!.back[0].toString()})",
                      () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //         builder: (BuildContext context) => ListDrawer<Resolution>(
                    //           title: "Video size",
                    //           list: availableResolutions,
                    //           activeItem: widget._controller.initialParams.resolution,
                    //           onNewActiveItem: (i) {
                    //             widget._controller.initialParams.resolution = i;
                    //             setState(() {});
                    //           },
                    //         )
                    //     )
                    // );
                  },
                ),

              ],);
            }
          );
          // stateStreamSnap.data!.streamResolution;
          return ListView(

          );
        }
      ),
    );
  }
}


