import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalVideoDisplay extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  const LocalVideoDisplay({Key? key, required this.localRenderer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: RTCVideoView(localRenderer),
    );
  }
}
