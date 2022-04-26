import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp_streamer.dart';

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
    return Center(
      child: streamer.cameraPreview(),
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





