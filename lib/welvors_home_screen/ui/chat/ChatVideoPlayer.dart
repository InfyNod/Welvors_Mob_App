import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChatVideoPlayer extends StatefulWidget {
  final String url;
  const ChatVideoPlayer({required this.url});

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller
        .initialize()
        .then((_) {
          if (mounted) setState(() => _ready = true);
        })
        .catchError((e) => debugPrint('❌ VIDEO PLAYER ERROR => $e'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_ready) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final aspect = _controller.value.aspectRatio == 0
        ? 16 / 9
        : _controller.value.aspectRatio;
    return GestureDetector(
      onTap: _toggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: aspect, child: VideoPlayer(_controller)),
          if (!_controller.value.isPlaying)
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 4,
            child: VideoProgressIndicator(_controller, allowScrubbing: true),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// Runs on a background isolate via compute(). Must be a
// top-level (or static) function — decodes, resizes (max
// 1600px on the longer side), and JPEG-encodes the image,
// stepping quality down until it is comfortably below common
// server upload limits (~900 KB).
// ==========================================================
Uint8List? encodeChatImageIsolate(Uint8List originalBytes) {
  final decoded = img.decodeImage(originalBytes);
  if (decoded == null) return null;

  img.Image resized = decoded;
  if (decoded.width > 1600 || decoded.height > 1600) {
    if (decoded.width >= decoded.height) {
      resized = img.copyResize(decoded, width: 1600);
    } else {
      resized = img.copyResize(decoded, height: 1600);
    }
  }

  int quality = 75;
  Uint8List jpgBytes = Uint8List.fromList(
    img.encodeJpg(resized, quality: quality),
  );

  while (jpgBytes.length > 900 * 1024 && quality > 25) {
    quality -= 10;
    jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  return jpgBytes;
}
