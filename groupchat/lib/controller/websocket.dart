import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:groupchat/controller/controller.dart';
import 'package:groupchat/models/socket_id.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocket {
  late IO.Socket socket;

  void initSocket(String roomId, Controller controller) {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.on('connect', (_) {
      print('Connected id : ${socket.id}');
    });

    socket.onConnect((data) async {
      print('Socket Server Successfully connected');
      socket.emit("join", roomId);
    });

    //Offer received from other client which is set as remote description and answer is created and transmitted
    socket.on("receiveOffer", (data) async {
      //print("Offer received");
      SocketId id = SocketId.fromJson(data["socketId"]);
      await controller.webRtcLocal.createLocalConnection(id, socket);
      String sdp = write(data["session"], null);

      RTCSessionDescription description = RTCSessionDescription(sdp, 'offer');

      await controller.webRtcLocal.connections[id.destinationId]!.peer
          .setRemoteDescription(description);

      RTCSessionDescription description2 = await controller
          .webRtcLocal.connections[id.destinationId]!.peer
          .createAnswer({
        //'offerToReceiveAudio': 1,
        'offerToReceiveVideo': 1
      }); // {'offerToReceiveVideo': 1 for video call

      var session = parse(description2.sdp.toString());

      controller.webRtcLocal.connections[id.destinationId]!.peer
          .setLocalDescription(description2);
      socket.emit(
        "createAnswer",
        {
          "session": session,
          "socketId": id.toJson(),
        },
      );
      controller.appStates.refresshVideoList.value =
          !controller.appStates.refresshVideoList.value;

      // setState(() {
      //   refresshVideoList = !refresshVideoList;
      // });
    });
    //Answer received from originating client which is set as remote description
    socket.on("receiveAnswer", (data) async {
      //print("Answer received");
      String sdp = write(data["session"], null);

      RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');

      await controller
          .webRtcLocal.connections[data["socketId"]["destinationId"]]!.peer
          .setRemoteDescription(description);
      controller.appStates.refresshVideoList.value =
          !controller.appStates.refresshVideoList.value;
    });

    //Candidate received from answerer which is added to the peer connection
    //THIS COMPELETES THE CONNECTION PROCEDURE
    socket.on("receiveCandidate", (data) async {
      print("Candidate received");
      dynamic candidate = RTCIceCandidate(data['candidate']['candidate'],
          data['candidate']['sdpMid'], data['candidate']['sdpMlineIndex']);
      await controller
          .webRtcLocal.connections[data['socketId']['destinationId']]!.peer
          .addCandidate(candidate);
    });

    socket.on("userDisconnected", (id) async {
      await controller.webRtcLocal.connections[id]!.renderer.dispose();
      await controller.webRtcLocal.connections[id]!.peer.close();
      controller.webRtcLocal.connections.remove(id);
    });

    socket.onConnectError((data) {
      //print(data);
    });
  }
}
