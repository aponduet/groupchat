import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groupchat/client/controller/controller.dart';
import 'package:groupchat/client/view/local_video_display.dart';
import 'package:groupchat/client/view/remote_video_grid.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String roomId;
  const ChatScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  Controller controller = Controller();
  //bool refresshVideoList = true;
  bool isAudioEnabled = true;

  //final String socketId = "1011";

  //These are for manual testing without a heroku server

  @override
  dispose() {
    IO.Socket socket = controller.webSocket.socket;
    //To stop multiple calling websocket, use the following code.
    if (socket.disconnected) {
      socket.disconnect();
    }
    //socket.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    controller.webRtcLocal.initRenderer();
    //print(widget.roomId);
    controller.webSocket.initSocket(widget.roomId, controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("groupchat"),
        actions: [
          ElevatedButton(
            // onPressed: () {
            //   //Do something here
            // },
            onPressed: (() {
              controller.webRtcLocal.createOfferAndConnect(
                  controller.webSocket.socket, widget.roomId);
            }),
            child: const Text('Connect'),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () async {
              if (isAudioEnabled) {
                controller.audioVideo
                    .disableAudio(controller.webRtcLocal.localStream!);
              } else {
                controller.audioVideo
                    .enableAudio(controller.webRtcLocal.localStream!);
              }
              setState(() {
                isAudioEnabled = !isAudioEnabled;
              });
            },
            child: Text('Mic is ${isAudioEnabled == true ? "on" : "off"}'),
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LocalVideoDisplay(
                  localRenderer: controller.webRtcLocal.localRenderer),
            ),
            SizedBox(
              height: double.infinity,
              width: 300,
              child: ValueListenableBuilder<bool>(
                  valueListenable: controller.appStates.refresshVideoList,
                  builder: (context, value, child) {
                    return RemoteVideoGrid(
                        connections: controller.webRtcLocal.connections);
                  }),
            ),
          ],
        ),
      ),
    );
    //);
  }
}
