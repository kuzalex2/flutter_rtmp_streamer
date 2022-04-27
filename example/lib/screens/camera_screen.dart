

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';
import 'package:flutter_rtmp_streamer_example/screens/loader.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  String? _platformVersion;
  FlutterRtmpStreamer? streamer1;
  /// just for test 2 different controller instances
  FlutterRtmpStreamer? streamer2;

  @override
  void initState() {


    FlutterRtmpStreamer.init().then((value) {
      streamer1 = value;
    });

    FlutterRtmpStreamer.init().then((value) {
      streamer2 = value;
    });

    FlutterRtmpStreamer.platformVersion.then((version)  {
      setState(() {
        _platformVersion = version;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [

          if (streamer1!=null)
            StreamBuilder<StreamingNotification>(
              stream: streamer1!.notificationStream,
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
            ),

          const SizedBox(height: 100,),
          Text(
            "Camera here. \nPlugin version=$_platformVersion",
            style: textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),

          SizedBox(
            width: 100,
            height: 100,

            child: OrientationBuilder(
              builder: (context, orientation) {
                return AndroidView(
                  key: ValueKey<String>(orientation == Orientation.portrait ? "portrait" : "landscape"),

                  viewType: 'flutter_rtmp_streamer_camera_view',
                  onPlatformViewCreated: (id) {
                    debugPrint("_onPlatformViewCreated $id");
                  },
                  creationParamsCodec: const StandardMessageCodec(),
                );
              }
            ),
          ),

          const SizedBox(height: 20,),

          Row(children: [
            const Spacer(),

            LeftControlBox(streamer: streamer1),

            const Spacer(),

            RightControlBox(streamer: streamer2),


            const Spacer(),

          ],),

        ],
      ),
    );

    // return Center(
    //   child: Text(
    //     "Camera here. \nPlugin version=$_platformVersion",
    //     style: textTheme.bodyText1,
    //     textAlign: TextAlign.center,
    //   ),
    // );
  }
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

        return Text("isAudioMuted = ${snap.data!.isAudioMuted}\n"
            "isOnPreview = ${snap.data!.isOnPreview}\n"
            "isRtmpConnected = ${snap.data!.isRtmpConnected}\n"
            "isStreaming = ${snap.data!.isStreaming}\n"
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

//
// class CameraScreen extends StatelessWidget {
//   const CameraScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return Center(
//       child: Text(
//         "Camera here. \nPlugin version=${FlutterRtmpStreamer.platformVersion}",
//         style: textTheme.bodyText1,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }


/// Container(
//         color: Colors.black,
//         child: Center(
//           child: Stack(
//             children: [
//
//               streamer.cameraPreview(),
//
//               NotificationListener(streamer: streamer),
//
//               Positioned(
//                 bottom: 20,
//
//
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         color: Colors.white30,
//                         borderRadius: BorderRadius.all(Radius.circular(20))
//                       ),
//                       child: Row(children: [
//                           const Spacer(),
//                           LeftControlBox(streamer: streamer),
//                           const Spacer(),
//                           RightControlBox(streamer: streamer),
//                           const Spacer(),
//                       ]),
//                     ),
//                   ),
//                 ),
//
//               ),
//
//             ],
//           ),
//         ),
//       ),