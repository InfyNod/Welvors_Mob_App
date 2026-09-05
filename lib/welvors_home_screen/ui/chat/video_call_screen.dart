import 'package:flutter/material.dart';
import 'chat_bloc/chat_state.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

class VideoCallScreen extends StatefulWidget {
  final ChatUser user;
  final String currentUserId;
  final String currentUserName;
  final String callId;

  const VideoCallScreen({
    super.key,
    required this.user,
    required this.currentUserId,
    required this.currentUserName,
    required this.callId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _muted = false;
  bool _cameraOff = false;
  bool _speaker = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.user.image.isNotEmpty
                  ? Image.network(
                      widget.user.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _videoFallback(),
                    )
                  : _videoFallback(),
            ),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                children: [
                  _roundIcon(Icons.arrow_back_rounded,
                      () => Navigator.of(context).pop()),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '00:00',
                      style: AppText.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 72,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.user.name,
                    style: AppText.h2.copyWith(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Video call',
                    style: AppText.sub.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 130,
              child: Container(
                width: 108,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  color: AppColors.darkChip,
                ),
                clipBehavior: Clip.antiAlias,
                child: _cameraOff
                    ? const Center(
                        child: Icon(
                          Icons.videocam_off_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.currentUserName.isEmpty
                              ? 'You'
                              : widget.currentUserName[0].toUpperCase(),
                          style: AppText.h1.copyWith(
                            color: Colors.white,
                            fontSize: 38,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _control(
                    _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    () => setState(() => _muted = !_muted),
                  ),
                  const SizedBox(width: 18),
                  _control(
                    _cameraOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    () => setState(() => _cameraOff = !_cameraOff),
                  ),
                  const SizedBox(width: 18),
                  _control(
                    _speaker
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    () => setState(() => _speaker = !_speaker),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoFallback() => Container(
        color: AppColors.darkChip,
        alignment: Alignment.center,
        child: Text(
          widget.user.name.isEmpty ? '?' : widget.user.name[0].toUpperCase(),
          style: AppText.h1.copyWith(color: Colors.white, fontSize: 80),
        ),
      );

  Widget _control(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
      );

  Widget _roundIcon(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
      );
}
