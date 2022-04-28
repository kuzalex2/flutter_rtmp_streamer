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
          future: FlutterRtmpStreamer.init(),
          builder: (context, snapshot) {
            if (snapshot.hasError){
              return ErrorWidget( error: snapshot.error.toString() );
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
      drawer: CameraSettingsDrawer(streamer),
      appBar: _AppBar(),
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
        title:const Text("FlutterRtmpStreamer")
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}


class LeftControlBox extends StatelessWidget {
  const LeftControlBox({Key? key, required this.streamer}) : super(key: key);
  final FlutterRtmpStreamer? streamer;

  @override
  Widget build(BuildContext context) {
    if (streamer==null) {
      return const Loader();
    }

    return StreamBuilder<StreamingState>(
        stream: streamer!.stateStream,
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
  final FlutterRtmpStreamer? streamer;

  @override
  Widget build(BuildContext context) {
    if (streamer==null) {
      return const Loader();
    }

    return ElevatedButton(
        onPressed: () {
          try {

            if ( streamer!.state.isStreaming ) {
              streamer!.stopStream();
            } else {
              streamer!.startStream(
                  uri: "rtmp://flutter-webrtc.kuzalex.com/live",
                  streamName: "one"
              );
            }

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $e'),
            ));
          }
        },
        child: StreamBuilder<Object>(
            stream: streamer!.stateStream,
            builder: (context, _) {
              return Text(
                  streamer!.state.isStreaming ? "Stop streaming" : "Start streaming"
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



class ErrorWidget extends StatelessWidget {
  final String error;

  const ErrorWidget({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Text(error)
    );
  }
}

class Loader extends StatelessWidget {

  final double radius;
  final Brightness brightness;

  const Loader({Key? key, this.radius = mediumRadius, this.brightness = Brightness.light}) : super(key: key);

  static const double smallRadius = 10.0;
  static const double mediumRadius = 14.0;

  @override
  Widget build(BuildContext context) {
    if (brightness == Brightness.light) {
      return Center(child: CupertinoActivityIndicator(radius: radius,),);
    }

    return Center(
      child: Theme(data: ThemeData(cupertinoOverrideTheme: const CupertinoThemeData(brightness: Brightness.dark)),
          child: CupertinoActivityIndicator(radius: radius,)),
    );

  }
}





