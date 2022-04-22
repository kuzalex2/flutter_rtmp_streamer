

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  String? _platformVersion;

  @override
  void initState() {
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
          const SizedBox(height: 100,),
          Text(
            "Camera here. \nPlugin version=$_platformVersion",
            style: textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),

          SizedBox(
            width: 100,
            height: 100,
            // child: Container(color: Colors.red,),

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