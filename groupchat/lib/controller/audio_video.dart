import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioVideo {
  //enable audio
  void enableAudio(MediaStream localStream) async {
    localStream.getAudioTracks().forEach((track) {
      track.enabled = true;
    });
  }

  //disable audio
  void disableAudio(MediaStream localStream) async {
    localStream.getAudioTracks().forEach((track) {
      track.enabled = false;
    });
  }
}
