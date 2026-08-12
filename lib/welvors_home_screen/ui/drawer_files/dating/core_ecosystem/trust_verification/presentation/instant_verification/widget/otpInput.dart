import '../../../export.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({super.key});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _focusOtp() {
    _focusNode.requestFocus();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
      builder: (context, state) {
        final otp = _controller.text;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // OTP BOXES + REAL TEXTFIELD
            // ========================================
            SizedBox(
              height: 60,
              child: Stack(
                children: [
                  // OTP UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final hasValue = index < otp.length;

                      final isActive = index == otp.length && otp.length < 6;

                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasValue || isActive
                                ? Mycolor.pinklight
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: hasValue || isActive
                                  ? Mycolor.pink
                                  : const Color(0xFFE9E3E6),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            hasValue ? otp[index] : '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Mycolor.pink1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // ==================================
                  // REAL TEXTFIELD OVERLAY
                  // ==================================
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.01,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,

                        keyboardType: TextInputType.number,

                        textInputAction: TextInputAction.done,

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],

                        onTap: _focusOtp,

                        onChanged: (value) {
                          context.read<InstantVerificationBloc>().add(
                            OtpChanged(value),
                          );
                        },

                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ========================================
            // RESEND
            // ========================================
            Row(
              children: [
                const Text(
                  "Didn't get it? ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9C969B),
                  ),
                ),

                if (state.resendSeconds > 0)
                  Text(
                    'Resend in 0:${state.resendSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Mycolor.pink1,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: state.canResend
                        ? () {
                            _controller.clear();

                            context.read<InstantVerificationBloc>().add(
                              const ResendOtp(),
                            );

                            _focusOtp();
                          }
                        : null,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Mycolor.pink1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);

    _focusNode.removeListener(_onFocusChanged);

    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}
