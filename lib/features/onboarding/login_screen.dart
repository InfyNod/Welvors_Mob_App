import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'waitlist_confirmed_screen.dart';
import 'user_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isPhoneValid = false;
  bool _isOtpSent = false;
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
      // Verify OTP logic
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
          // Navigate to Waitlist Confirmed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitlistConfirmedScreen()),
          );
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.line, width: 1.5),
                          ),
                          child: const Icon(Icons.chevron_left, color: AppColors.ink),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 1),
                          
                          // Heart Animation
                          Center(
                            child: Lottie.asset(
                              'assets/drawinglove.json',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              repeat: false,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Welvors logo
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: AppText.display.copyWith(fontSize: 24), 
                                children: const [
                                  TextSpan(text: 'Wel', style: TextStyle(color: AppColors.ink)),
                                  TextSpan(text: 'vors', style: TextStyle(color: AppColors.pinkDeep)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Welcome back
                          Text(
                            'Welcome back.',
                            textAlign: TextAlign.center,
                            style: AppText.display.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          
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
                                  const TextSpan(
                                    text: 'We sent a code to ',
                                  ),
                                  TextSpan(
                                    text: '+91 ${_phoneController.text}.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              'Your matches are waiting. Log in with your\nregistered number — we\'ll text you a one-\ntime code.',
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.ink60,
                                height: 1.5,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 32),
                          
                          // Phone number input
                          Text(
                            'Phone number',
                            style: AppText.eyebrow.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              // Country code container
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.line,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(AppDimens.rInput),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 8),
                                    Text('+91', style: AppText.body.copyWith(fontSize: 16)),
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
                                                : AppColors.line),
                                      width: _phoneFocusNode.hasFocus && !_isOtpSent ? 1.5 : 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(AppDimens.rInput),
                                    boxShadow: _phoneFocusNode.hasFocus && !_isOtpSent ? [
                                      BoxShadow(
                                        color: AppColors.pinkDeep.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )
                                    ] : null,
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
                                      hintStyle: AppText.body.copyWith(color: AppColors.muted, fontSize: 16),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: AppText.body.copyWith(
                                      fontSize: 18, 
                                      letterSpacing: 1.5,
                                      color: _isOtpSent ? AppColors.ink.withOpacity(0.6) : AppColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_isOtpSent) ...[
                            const SizedBox(height: 24),
                            // Divider line with text
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.line,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                    color: AppColors.line,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Custom OTP Input Boxes
                            GestureDetector(
                              onTap: () => FocusScope.of(context).requestFocus(_otpFocusNode),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (index) {
                                        String char = '';
                                        if (_otpController.text.length > index) {
                                          char = _otpController.text[index];
                                        }
                                        bool isCurrent = _otpController.text.length == index && _otpFocusNode.hasFocus;
                                        bool isFilled = char.isNotEmpty;

                                        return Container(
                                          width: 46,
                                          height: 56,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isFilled || isCurrent
                                                ? AppColors.pinkSoft.withOpacity(0.4)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isFilled || isCurrent
                                                  ? AppColors.pinkDeep
                                                  : AppColors.line,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: isCurrent
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.pinkDeep.withOpacity(0.15),
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
                                     const TextSpan(text: 'Didn\'t get it? '),
                                     TextSpan(
                                       text: 'Resend code in 0:${_timerSeconds.toString().padLeft(2, '0')}',
                                     ),
                                   ],
                                 ),
                               )
                            else
                               RichText(
                                 text: TextSpan(
                                   style: AppText.sub.copyWith(
                                     fontSize: 12,
                                     color: AppColors.ink60,
                                     fontWeight: FontWeight.w600,
                                   ),
                                   children: [
                                     const TextSpan(text: 'Didn\'t get it? '),
                                     TextSpan(
                                       text: 'Resend code',
                                       style: const TextStyle(
                                         color: AppColors.pinkDeep,
                                         fontWeight: FontWeight.w800,
                                       ),
                                       recognizer: TapGestureRecognizer()..onTap = () {
                                         _startTimer();
                                       },
                                     ),
                                   ],
                                 ),
                               ),
                          ],

                          const SizedBox(height: 32),
                          
                          // Create account link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: AppText.sub.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink60),
                                children: [
                                  const TextSpan(text: 'New to Welvors? '),
                                  TextSpan(
                                    text: 'Create an account',
                                    style: const TextStyle(color: AppColors.pinkDeep, fontWeight: FontWeight.w800),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      Navigator.pop(context); // Go back to landing
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Trust badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 14, color: AppColors.green),
                              const SizedBox(width: 4),
                              Text('Encrypted login', style: AppText.sub.copyWith(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 16),
                              const Icon(Icons.check_circle_outline, size: 14, color: AppColors.green),
                              const SizedBox(width: 4),
                              Text('2M+ verified singles', style: AppText.sub.copyWith(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          const Spacer(flex: 2),
                          
                        ]
                      )
                    )
                  )
                ]
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.pad, 16, AppDimens.pad, 20),
              child: PrimaryButton(
                _isLoading ? 'Please wait...' : (_isOtpSent ? 'Log in' : 'Send code'),
                onTap: _isLoading 
                  ? null 
                  : ((_isOtpSent ? isOtpValid : _isPhoneValid) 
                      ? _onSendCodePressed
                      : null), 
              ),
            ),
          ]
        )
      )
    );
  }
}