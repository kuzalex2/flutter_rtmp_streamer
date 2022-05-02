
# flutter_rtmp_streamer

RTMP streaming plugin SAMPLE.

## Getting Started

This plugin is an example of plugin for rtmp streaming.
This is a lightweight flutter wraper on the [rtmp-rtsp-stream-client-java](https://github.com/pedroSG94/rtmp-rtsp-stream-client-java)
for Android and [HaishinKit.swift](https://github.com/shogo4405/HaishinKit.swift) for IOS

## Features:

* Live camera preview in a widget.
* Configurable settings.
* Automatic reconnecting.
* Background streaming on Android.

## Installation

...

### iOS

Add two rows to the `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSMicrophoneUsageDescription</key>
<string>Can I use the mic please?</string>
```

### Android

...

### Example

Here is a sample flutter app .

```dart
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
             ///
             /// Initialize FlutterRtmpStreamer with default configuration
             /// 
            future: FlutterRtmpStreamer.init(StreamingSettings.initial),
            builder: (context, snapshot) {
              if (snapshot.hasError){
                return Center(
                    child: Text(snapshot.error.toString())
                );
              }
              
              if (!snapshot.hasData) {
                return const CupertinoActivityIndicator();
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
      body: Stack(
        children: [

          Container(color: Colors.black,),

          ///
          /// LIVE PREVIEW
          /// 
          Center(
            child: FlutterRtmpCameraPreview(controller: streamer),
          ),

          ///
          /// Notifications
          /// 
          NotificationListener(streamer: streamer),


          ///
          /// CONTROLS
          /// 
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
            return const CupertinoActivityIndicator();
          }

          final streamingState = snap.data!;

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
    
    return ElevatedButton(
        onPressed: () {
          try {

            if ( streamer.state.isStreaming ) {
              streamer.stopStream();
            } else {
              Future.delayed(const Duration(seconds: 2)).then((value) =>
                  streamer.startStream(
                      ///
                      /// Put real rtmp address here... 
                      /// 
                      uri: "rtmp://xyz.com/live",
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
                return const CupertinoActivityIndicator();
              }
              return Text(
                  streamingState.data!.isStreaming ? "Stop streaming" : "Start streaming"
              );
            }
        )
    );

  }
}
//
//
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
```

A more complete example of doing rtmp streaming is in the
[example code](https://github.com/kuzalex2/flutter_rtmp_streamer/tree/develop/example)