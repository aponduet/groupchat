import 'package:groupchat/client/controller/audio_video.dart';
import 'package:groupchat/client/controller/webrtc.dart';
import 'package:groupchat/client/controller/websocket.dart';
import 'package:groupchat/client/data/app_states.dart';

class Controller {
  WebSocket webSocket = WebSocket();
  WebRtcLocal webRtcLocal = WebRtcLocal();
  AudioVideo audioVideo = AudioVideo();
  AppStates appStates = AppStates();
}
