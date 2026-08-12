import '../../../../export.dart';

class ProfessionalCodeInput extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const ProfessionalCodeInput({super.key, required this.onChanged});

  @override
  State<ProfessionalCodeInput> createState() => _ProfessionalCodeInputState();
}

class _ProfessionalCodeInputState extends State<ProfessionalCodeInput> {
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
    final otp = _controller.text;

    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          // ========================================
          // OTP UI
          // ========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final hasValue = index < otp.length;

              final isActive = index == otp.length && otp.length < 6;

              return SizedBox(
                width: 50,
                height: 60,
                child: GestureDetector(
                  onTap: _focusOtp,
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasValue || isActive
                          ? const Color(0xFFFFEAF2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: hasValue || isActive
                            ? const Color(0xFFE72B7A)
                            : const Color(0xFFE9E3E6),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      hasValue ? otp[index] : '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC71A61),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // ========================================
          // REAL TEXTFIELD OVERLAY
          // ========================================
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
                  widget.onChanged(value);
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
