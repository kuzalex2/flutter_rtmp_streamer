
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp/controller.dart';
import 'package:flutter_rtmp_streamer/flutter_rtmp/model.dart';

import '../main.dart';


class StreamingStateBuilder extends StatelessWidget {
  const StreamingStateBuilder({Key? key, required this.streamer, required this.builder}) : super(key: key);
  final FlutterRtmpStreamer streamer;
  final Function(BuildContext context, StreamingState streamingState) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamingState>(
        stream: streamer.stateStream,
        initialData: streamer.state,
        builder: (context, streamStateSnap) {

          if (!streamStateSnap.hasData) {
            return const Loader();
          }

          return builder(context, streamStateSnap.data!);
        });
  }
}






class ListDrawer<T> extends StatelessWidget {

  final FlutterRtmpStreamer streamer;
  const ListDrawer({
    Key? key,
    required this.streamer,
    required this.title,
    required this.list,
    this.selectedItem,
    this.onSelected,
    this.checkIsStreaming = true,
  }) : super(key: key);

  final String title;
  final List<T> list;
  final T? selectedItem;
  final Function(T)? onSelected;
  final bool checkIsStreaming;

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Scaffold(
        appBar: AppBar(title: Text(title),),
        body: StreamingStateBuilder(
            streamer: streamer,
            builder: (context, state) {
              return ListView(
                children: list.map((item) =>
                    InkWell(
                      onTap: state.inSettings || (checkIsStreaming && state.isStreaming) ? null : () {
                        Navigator.of(context).pop();
                        if (onSelected!=null) {
                          onSelected!(item);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: item == selectedItem ? ((checkIsStreaming && state.isStreaming) ? Colors.grey : Colors.lightBlueAccent) : const Color.fromRGBO(0, 0, 0, 0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB (16,8,0,8),
                            child: Text(item.toString()),
                          )
                      ),
                    )
                ).toList(),
              );
            }
        ),
      ),
    );
  }
}


class FutureListDrawer<T> extends StatelessWidget {
  const FutureListDrawer({
    Key? key,
    required this.streamer,
    required this.title,
    this.selectedItem,
    this.onSelected,
    required this.futureList,
  }) : super(key: key);

  final FlutterRtmpStreamer streamer;
  final String title;
  final Future<List<T>> futureList;
  final T? selectedItem;
  final Function(T)? onSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
        future: futureList,
        builder: (context, snapshot) {

          if (snapshot.hasError){
            return Drawer(
                child: Scaffold(
                    appBar: AppBar(title: Text(title),),
                    body: MyErrorWidget( error: snapshot.error.toString() )
                ));
          }

          if (!snapshot.hasData){
            return Drawer(
                child: Scaffold(
                    appBar: AppBar(title: Text(title),),
                    body: const Loader()
                ));
          }

          return ListDrawer<T>(
            streamer: streamer,
            title: title,
            list: snapshot.data!,
            selectedItem: selectedItem,
            onSelected: onSelected,
          );
        }
    );
  }
}
