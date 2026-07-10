import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_data.dart';

class VerifyNumberScreen extends StatefulWidget {
  final VoidCallback onVerifySuccess;
  const VerifyNumberScreen({super.key, required this.onVerifySuccess});

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isPhoneValid = false;
  bool _isOtpSent = false;
  bool _isInviteCodeEntered = false;
  bool _isLoading = false;

  int _timerSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isPhoneValid = _phoneController.text.length == 10;
      });
    });

    _phoneFocusNode.addListener(() {
      setState(() {});
    });

    _otpFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
  }

  Future<void> _onSendCodePressed() async {
    if (_isLoading) return;

    if (!_isOtpSent) {
      setState(() => _isLoading = true);
      final errorMsg = await ApiService.sendOtp(_phoneController.text);
      setState(() => _isLoading = false);

      if (errorMsg == null) {
        setState(() {
          _isOtpSent = true;
        });
        _startTimer();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            FocusScope.of(context).requestFocus(_otpFocusNode);
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } else {
      setState(() => _isLoading = true);
      final result = await ApiService.verifyOtp(_phoneController.text, _otpController.text);
      setState(() => _isLoading = false);

      final token = result['token'];
      final errorMsg = result['error'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // Save phone to UserData
        userData.phone = '+91 ${_phoneController.text.trim()}';
        
        if (mounted) {
          widget.onVerifySuccess();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg ?? 'Invalid OTP. Please try again.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOtpValid = _otpController.text.length == 6;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 1),

                      // Shield Icon Circle
                      Center(
                        child: Container(
                          width: 89,
                          height: 89,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pink.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.pinkDeep,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pinkDeep.withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SECURE VERIFICATION',
                        textAlign: TextAlign.center,
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.pinkDeep,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced gap
                      // Verify your number
                      Text(
                        'Verify your number',
                        textAlign: TextAlign.center,
                        style: AppText.display.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 8), // Reduced gap
                      // Subtitle
                      if (_isOtpSent)
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppText.body.copyWith(
                              color: AppColors.ink60,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(text: 'Sent a 6-digit code to '),
                              TextSpan(
                                text: '+91 ${_phoneController.text}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const TextSpan(text: ' · '),
                              TextSpan(
                                text: 'Change',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pinkDeep,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _isOtpSent = false;
                                      _resendTimer?.cancel();
                                    });
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        if (context.mounted) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(_phoneFocusNode);
                                        }
                                      },
                                    );
                                  },
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'We\'ll text a one-time code to confirm it\'s\nreally you. Takes just a few seconds.',
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            color: AppColors.ink60,
                            height: 1.5,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 34),

                      Text(
                        'Phone number',
                        style: AppText.eyebrow.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.line,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimens.rInput,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🇮🇳',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: AppText.body.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Phone input
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isOtpSent
                                    ? AppColors.pinkSoft.withOpacity(0.4)
                                    : Colors.white,
                                border: Border.all(
                                  color: _isOtpSent
                                      ? AppColors.pinkSoft.withOpacity(0.4)
                                      : (_phoneFocusNode.hasFocus
                                            ? AppColors.pinkDeep
                                            : AppColors.ink.withOpacity(0.12)),
                                  width: _phoneFocusNode.hasFocus && !_isOtpSent
                                      ? 1.5
                                      : 1.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.rInput,
                                ),
                                boxShadow:
                                    _phoneFocusNode.hasFocus && !_isOtpSent
                                    ? [
                                        BoxShadow(
                                          color: AppColors.pinkDeep.withOpacity(
                                            0.15,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                readOnly: _isOtpSent,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  hintText: '98765 43210',
                                  hintStyle: AppText.body.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: AppText.body.copyWith(
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: _isOtpSent
                                      ? AppColors.ink.withOpacity(0.6)
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!_isOtpSent) ...[
                        const SizedBox(height: 24),
                        // Security Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EFE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: AppColors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Only verified members can join Welvors. Your number stays private — never shown on your profile or shared.',
                                  style: AppText.sub.copyWith(
                                    fontSize: 13,
                                    color: AppColors.ink.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Invite Code Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.line.withOpacity(0.6),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Have an invite code?',
                                style: AppText.sub.copyWith(
                                  fontSize: 11,
                                  color: AppColors.ink.withOpacity(0.4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.line.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Invite Code Input
                        Row(
                          children: [
                            // Invite Code Input Box
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: _isInviteCodeEntered
                                        ? AppColors.pinkDeep
                                        : AppColors.line,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(8),
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _isInviteCodeEntered =
                                          val.trim().length == 8;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter friend\'s code (optional)',
                                    hintStyle: AppText.body.copyWith(
                                      color: AppColors.ink.withOpacity(0.4),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: AppText.body.copyWith(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Apply Button Box
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isInviteCodeEntered
                                    ? AppColors.pinkDeep
                                    : AppColors.pinkSoft.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: _isInviteCodeEntered ? () {} : null,
                                style: TextButton.styleFrom(
                                  foregroundColor: _isInviteCodeEntered
                                      ? Colors.white
                                      : AppColors.pinkDeep,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                ),
                                child: Text(
                                  'Apply',
                                  style: AppText.body.copyWith(
                                    color: _isInviteCodeEntered
                                        ? Colors.white
                                        : AppColors.pinkDeep,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your friend earns a reward when you activate a plan.',
                          style: AppText.sub.copyWith(
                            fontSize: 11,
                            color: AppColors.ink.withOpacity(0.5),
                          ),
                        ),
                      ],

                      if (_isOtpSent) ...[
                        const SizedBox(height: 24),
                        // Divider line with text
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.ink.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Enter the 6-digit code',
                                style: AppText.sub.copyWith(
                                  color: AppColors.ink.withOpacity(0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.ink.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Custom OTP Input Boxes
                        GestureDetector(
                          onTap: () {
                            if (!_otpFocusNode.hasFocus) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_otpFocusNode);
                            } else {
                              SystemChannels.textInput.invokeMethod(
                                'TextInput.show',
                              );
                            }
                          },
                          child: Container(
                            height: 56,
                            color: Colors.transparent,
                            child: Stack(
                              children: [
                                // Hidden true text field
                                Opacity(
                                  opacity: 0,
                                  child: TextField(
                                    controller: _otpController,
                                    focusNode: _otpFocusNode,
                                    keyboardType: TextInputType.number,
                                    autofillHints: const [AutofillHints.oneTimeCode],
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                // Visual Boxes
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    String char = '';
                                    if (_otpController.text.length > index) {
                                      char = _otpController.text[index];
                                    }
                                    bool isCurrent =
                                        _otpController.text.length == index &&
                                        _otpFocusNode.hasFocus;
                                    bool isFilled = char.isNotEmpty;

                                    return Container(
                                      width: 46,
                                      height: 56,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isFilled || isCurrent
                                            ? AppColors.pinkSoft.withOpacity(
                                                0.4,
                                              )
                                            : Colors.white,
                                        border: Border.all(
                                          color: isFilled || isCurrent
                                              ? AppColors.pinkDeep
                                              : AppColors.ink.withOpacity(0.12),
                                          width: isFilled || isCurrent
                                              ? 1.5
                                              : 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: isCurrent
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.pinkDeep
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        char,
                                        style: AppText.h2.copyWith(
                                          fontSize: 22,
                                          color: AppColors.pinkDeep,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resend code timer or button
                        if (_timerSeconds > 0)
                          RichText(
                            text: TextSpan(
                              style: AppText.sub.copyWith(
                                fontSize: 12,
                                color: AppColors.ink60,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                  text:
                                      '0:${_timerSeconds.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              _startTimer();
                            },
                            child: Text(
                              'Resend code',
                              style: AppText.sub.copyWith(
                                fontSize: 12,
                                color: AppColors.pinkDeep,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Security Box (Visible in OTP state too)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EFE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: AppColors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Only verified members can join Welvors. Your number stays private — never shown on your profile or shared.',
                                  style: AppText.sub.copyWith(
                                    fontSize: 13,
                                    color: AppColors.ink.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            16,
            AppDimens.pad,
            20,
          ),
          child: PrimaryButton(
            _isLoading ? 'Please wait...' : (_isOtpSent ? 'Verify' : 'Send code'),
            onTap: _isLoading
                ? null
                : ((_isOtpSent ? isOtpValid : _isPhoneValid)
                    ? _onSendCodePressed
                    : null),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.pinkSoft.withOpacity(
                  0.6,
                ), // Light pink background
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.ink.withOpacity(0.7),
                size: 24,
              ), // Greyish icon
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.sub.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
