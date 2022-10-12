import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:groupchat/client/models/connection.dart';

class RemoteVideoGrid extends StatelessWidget {
  final Map<String, Connection> connections;
  const RemoteVideoGrid({Key? key, required this.connections})
      : super(key: key);

  // Codes for Video Call Grid
  List<Widget> renderStreamsGrid() {
    List<Widget> allRemoteVideo = [];

    connections.forEach((key, value) {
      allRemoteVideo.add(
        SizedBox(
          child: Container(
            padding: const EdgeInsets.all(5),
            width: 250,
            height: 200,
            color: Colors.yellow,
            child: RTCVideoView(
              value.renderer,
              // objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              // mirror: true,
            ),
          ),
        ),
      );

      //allRemoteVideo.add(value.renderer);
    });

    return allRemoteVideo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //itemCount: renderStreamsGrid().length,
        itemCount: renderStreamsGrid().length,
        itemBuilder: (context, index) {
          return renderStreamsGrid()[index];
        },
      ),
    );
  }
}
