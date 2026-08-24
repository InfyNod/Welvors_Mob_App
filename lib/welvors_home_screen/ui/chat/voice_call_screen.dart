import 'package:flutter/material.dart';
import 'chat_bloc/chat_state.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

class VoiceCallScreen extends StatefulWidget {
  final ChatUser user;
  final String currentUserId;
  final String currentUserName;
  final String callId;

  const VoiceCallScreen({
    super.key,
    required this.user,
    required this.currentUserId,
    required this.currentUserName,
    required this.callId,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _muted = false;
  bool _speaker = true;
  bool _connected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 22),
                Text(
                  _connected ? 'Connected' : 'Calling...',
                  style: AppText.sub.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.name,
                  style: AppText.h2.copyWith(fontSize: 27),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.user.online ? 'Online' : 'Calling',
                  style: AppText.body.copyWith(color: AppColors.ink60),
                ),
                const Spacer(),
                _avatar(),
                const SizedBox(height: 22),
                Text(
                  _connected ? '00:00' : 'Connecting...',
                  style: AppText.body.copyWith(
                    fontSize: 16,
                    color: AppColors.ink60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _control(
                        icon: _muted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        label: _muted ? 'Unmute' : 'Mute',
                        active: _muted,
                        onTap: () => setState(() => _muted = !_muted),
                      ),
                      _control(
                        icon: _speaker
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: 'Speaker',
                        active: !_speaker,
                        onTap: () => setState(() => _speaker = !_speaker),
                      ),
                      _control(
                        icon: Icons.dialpad_rounded,
                        label: 'Keypad',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
            Positioned(
              left: 18,
              top: 14,
              child: _roundIcon(
                Icons.arrow_back_rounded,
                () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 190,
      height: 190,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.green, width: 2),
      ),
      child: ClipOval(
        child: widget.user.image.isNotEmpty
            ? Image.network(
                widget.user.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackAvatar(),
              )
            : _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() => Container(
    color: AppColors.greenSoft,
    alignment: Alignment.center,
    child: Text(
      widget.user.name.isEmpty ? '?' : widget.user.name[0].toUpperCase(),
      style: AppText.h1.copyWith(fontSize: 58, color: AppColors.green),
    ),
  );

  Widget _control({
    required IconData icon,
    required String label,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: active ? AppColors.greenSoft : Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppColors.shadow,
            ),
            child: Icon(icon, color: AppColors.ink, size: 25),
          ),
        ),
        const SizedBox(height: 7),
        Text(label, style: AppText.sub.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppColors.shadow,
      ),
      child: Icon(icon, color: AppColors.ink),
    ),
  );
}
