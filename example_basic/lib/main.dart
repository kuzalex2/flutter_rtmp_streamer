import 'package:example_basic/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';

import 'drawer.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<FlutterRtmpStreamer>(
          future: FlutterRtmpStreamer.init(StreamingSettings.initial),
          builder: (context, snapshot) {
            if (snapshot.hasError){
              return MyErrorWidget( error: snapshot.error.toString() );
            }
            if (!snapshot.hasData) {
              return const Loader();
            }

            return MainScreen(streamer: snapshot.data!);
          }
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final FlutterRtmpStreamer streamer;
  const MainScreen({Key? key, required this.streamer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CameraSettingsDrawer(streamer: streamer),
      appBar: const _AppBar(),
      body: Stack(
        children: [

          Container(color: Colors.black,),

          // Center(
          //     child: FlutterRtmpCameraPreview(controller: streamer),
          //
          // ),

          NotificationListener(streamer: streamer),

          Center(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                const Spacer(),
                LeftControlBox(streamer: streamer),
                const Spacer(),
                RightControlBox(streamer: streamer),
                const Spacer(),
              ]),
            ),
          ),


        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: ElevatedButton(
          onPressed: () { Scaffold.of(context).openDrawer(); },
          child: const Icon(
            Icons.menu,
          ),
        ),
        title:const Text("FlutterRtmpStreamer Basic sample")
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}


class LeftControlBox extends StatelessWidget {
  const LeftControlBox({Key? key, required this.streamer}) : super(key: key);
  final FlutterRtmpStreamer streamer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamingState>(
        stream: streamer.stateStream,
        initialData: streamer.state,
        builder: (context, snap) {
          if (!snap.hasData){
            return const Loader();
          }

          final streamingState= snap.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("isAudioMuted = ${streamingState.isAudioMuted}\n"
                "isOnPreview = ${streamingState.isOnPreview}\n"
                "isRtmpConnected = ${streamingState.isRtmpConnected}\n"
                "isStreaming = ${streamingState.isStreaming}\n"
                "resolution=${streamingState.streamResolution}\n"
                "cameraOrientation = ${streamingState.cameraOrientation}"
            ),
          );
        }
    );
  }
}

class RightControlBox extends StatelessWidget {
  const RightControlBox({Key? key, required this.streamer}) : super(key: key);
  final FlutterRtmpStreamer streamer;

  @override
  Widget build(BuildContext context) {


    return ElevatedButton(
        onPressed: () {
          try {

            if ( streamer.state.isStreaming ) {
              streamer.stopStream();
            } else {
              Future.delayed(const Duration(seconds: 2)).then((value) =>
                streamer.startStream(
                    uri: "rtmp://flutter-webrtc.kuzalex.com/live",
                    streamName: "one"
                )
              );
            }

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $e'),
            ));
          }
        },
        child: StreamBuilder<StreamingState>(
            stream: streamer.stateStream,
            initialData: streamer.state,
            builder: (context, streamingState) {
              if (!streamingState.hasData){
                return const Loader();
              }
              return Text(
                  streamingState.data!.isStreaming ? "Stop streaming" : "Start streaming"
              );
            }
        )
    );

  }
}


class NotificationListener extends StatelessWidget {
  const NotificationListener ({Key? key, required this.streamer}) : super(key: key);
  final FlutterRtmpStreamer streamer;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamingNotification>(
        stream: streamer.notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            WidgetsBinding.instance?.addPostFrameCallback((_) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(snapshot.data!.description),
                ))
            );
          }
          return const SizedBox();
        }
    );
  }
}









