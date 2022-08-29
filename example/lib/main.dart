import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';

import 'settings/drawer.dart';

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


class MainScreen extends StatefulWidget {
  final FlutterRtmpStreamer streamer;
  const MainScreen({Key? key, required this.streamer}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showPreview = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CameraSettingsDrawer(streamer: widget.streamer),
      appBar: const _AppBar(),
      body: Stack(
        children: [

          Container(color: Colors.black,),

          if (showPreview)
            Center(
              child: FlutterRtmpCameraPreview(controller: widget.streamer),

            ),



          NotificationListener(streamer: widget.streamer),

          SafeArea(
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Row(children: [
                      const Spacer(),
                      LeftControlBox(streamer: widget.streamer),
                      const Spacer(),
                      RightControlBox(streamer: widget.streamer),
                      const Spacer(),
                    ]),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPreview = !showPreview;
                          });

                        },
                        child: const Text("Stop/Start Preview Test")
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}


// class MainScreen extends StatelessWidget {
//   final FlutterRtmpStreamer streamer;
//   const MainScreen({Key? key, required this.streamer}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: CameraSettingsDrawer(streamer: streamer),
//       appBar: const _AppBar(),
//       body: Stack(
//         children: [
//
//           Container(color: Colors.black,),
//
//           Center(
//               child: FlutterRtmpCameraPreview(controller: streamer),
//
//           ),
//
//           NotificationListener(streamer: streamer),
//
//           Center(
//             child: Container(
//               decoration: const BoxDecoration(
//                   color: Colors.white30,
//                   borderRadius: BorderRadius.all(Radius.circular(20))
//               ),
//               width: MediaQuery.of(context).size.width,
//               child: Row(children: [
//                 const Spacer(),
//                 LeftControlBox(streamer: streamer),
//                 const Spacer(),
//                 RightControlBox(streamer: streamer),
//                 const Spacer(),
//               ]),
//             ),
//           ),
//
//
//         ],
//       ),
//     );
//   }
// }

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
                "resolution=${streamingState.resolution}\n"
                "streamResolution=${streamingState.streamResolution}\n"
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


    return StreamBuilder<StreamingState>(
        stream: streamer.stateStream,
        initialData: streamer.state,
        builder: (context, streamingState) {
        return ElevatedButton(
            style: streamingState.data?.isStreaming??false ? ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)):null,
            onPressed: () {
              try {

                if ( streamer.state.isStreaming ) {
                  streamer.stopStream();
                } else {
                  // Future.delayed(const Duration(seconds: 2)).then((value) =>
                    streamer.startStream(
                        uri: "rtmp://flutter-webrtc.kuzalex.com/live",
                        streamName: "one"
                    // )
                  );
                }

              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: $e'),
                ));
              }
            },
            child: Text(
                streamingState.data!.isStreaming ? "Stop streaming" : "Start streaming"
            )
        );
      }
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




class MyErrorWidget extends StatelessWidget {
  final String error;

  const MyErrorWidget({Key? key, required this.error}) : super(key: key);

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
