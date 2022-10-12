import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:groupchat/models/connection.dart';
import 'package:groupchat/models/socket_id.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sdp_transform/sdp_transform.dart';

class WebRtcLocal {
  MediaStream? localStream;
  bool _offer = false;
  Map<String, Connection> connections = {};
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  //Start Renderers
  initRenderer() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    localStream = await getUserMedia();
  }

  getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      //'video': false,
      'video': {
        'facingMode': 'user',
      }, //If you want to make video calling app.
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    localRenderer.srcObject = stream;
    // localRenderer.mirror = true;

    return stream;
  }

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
      {
        "url": 'turn:192.158.29.39:3478?transport=udp',
        "credential": 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        "username": '28224511:1379330808'
      }
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true, //for video call
    },
    "optional": [],
  };

  Future<void> createLocalConnection(var id, IO.Socket socket) async {
    //print("Create connection");
    connections[id.destinationId] = Connection();
    connections[id.destinationId]!.renderer = RTCVideoRenderer();
    await connections[id.destinationId]!.renderer.initialize();
    connections[id.destinationId]!.peer =
        await createPeerConnection(configuration, offerSdpConstraints);
    connections[id.destinationId]!.peer.addStream(localStream!);

    //The below onIceCandidate will not call if you are a caller
    connections[id.destinationId]!.peer.onIceCandidate = (e) {
      print("On-ICE Candidate is Finding");
      //Transmitting candidate data from answerer to caller
      if (e.candidate != null && !_offer) {
        socket.emit("sendCandidate", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
          "socketId": id.toJson(),
        });
      }
    };

    connections[id.destinationId]!.peer.onIceConnectionState = (e) {
      print(e);
    };

    connections[id.destinationId]!.peer.onAddStream = (stream) {
      //print('addStream: ' + stream.id);
      connections[id.destinationId]!.renderer.srcObject =
          stream; //same as the _remoteRenderer.srcObject = stream
    };
  }

  Future<void> createOffer(var id, IO.Socket socket) async {
    RTCSessionDescription description =
        await connections[id.destinationId]!.peer.createOffer({
      //'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1
    }); //{'offerToReceiveVideo': 1} for video call
    var session = parse(
        description.sdp.toString()); //parse comes from sdp_transform package
    socket.emit("createOffer", {"session": session, "socketId": id.toJson()});

    _offer = true;

    connections[id.destinationId]!.peer.setLocalDescription(description);
  }

//This is the method that initiates the connection
  void createOfferAndConnect(IO.Socket socket, String roomId) async {
    socket.emitWithAck("newConnect", roomId, ack: (data) async {
      // print(
      //     "OriginId: ${data["originId"]}, DestinationIds: ${data["destinationIds"]}");

      data["destinationIds"].forEach((destinationId) async {
        if (connections[destinationId] == null) {
          SocketId id = SocketId(
              originId: data["originId"], destinationId: destinationId);
          await createLocalConnection(id, socket);
          await createOffer(id, socket);
        }
      });
      // await createLocalConnection(socketId);
      // await createOffer(socketId);
    });
  }
}
