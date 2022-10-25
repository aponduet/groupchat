import 'package:groupchat/server/controller/webrtc.dart';
import 'package:groupchat/server/controller/websocket.dart';
import 'package:groupchat/server/data/app_states.dart';

class Controller {
  WebSocket webSocket = WebSocket();
  WebRtc webRtc = WebRtc();
  AppStates appStates = AppStates();
}
