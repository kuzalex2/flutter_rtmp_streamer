
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';

class FlutterRtmpCameraPreview extends StatelessWidget {
  const FlutterRtmpCameraPreview({Key? key, required this.controller}) : super(key: key);
  final FlutterRtmpStreamer controller;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<StreamingState>(
        stream: controller.stateStream,
        initialData: controller.state,
        builder: (context, snapshot) {
          if (snapshot.hasError){
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const CupertinoActivityIndicator();
          }

          return _FlutterRtmpCameraPreview(key: key, state: snapshot.data!);
        }
    );
  }
}

class _FlutterRtmpCameraPreview extends StatelessWidget {
  const _FlutterRtmpCameraPreview({Key? key, required this.state}) : super(key: key);
  final StreamingState state;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: state.resolution.width == 0 ? 1.0 : state.resolution
            .height / state.resolution.width,
        child: const FlutterRtmpCameraView()
    );
  }
}

class FlutterRtmpCameraView extends StatelessWidget {
  const FlutterRtmpCameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        key: key,

        viewType: 'flutter_rtmp_streamer_camera_view',
        onPlatformViewCreated: (id) {
          debugPrint("_onPlatformViewCreated $id");
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    // if (Platform.isIOS) {
    //
    // }

    return Center(child: Text("FlutterRtmpCamera doesn't support ${Platform.operatingSystem} yet."),);
  }
}
