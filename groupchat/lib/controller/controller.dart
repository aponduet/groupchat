import 'package:groupchat/controller/audio_video.dart';
import 'package:groupchat/controller/webrtc_local.dart';
import 'package:groupchat/controller/websocket.dart';
import 'package:groupchat/data/app_states.dart';

class Controller {
  WebSocket webSocket = WebSocket();
  WebRtcLocal webRtcLocal = WebRtcLocal();
  AudioVideo audioVideo = AudioVideo();
  AppStates appStates = AppStates();
}
