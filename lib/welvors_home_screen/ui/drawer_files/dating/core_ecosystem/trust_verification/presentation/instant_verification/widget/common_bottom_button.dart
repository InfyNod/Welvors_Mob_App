import 'package:flutter/material.dart';

class CommonBottomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool loading;

  const CommonBottomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null || loading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: disabled
              ? const LinearGradient(
                  colors: [Color(0xFFE5DDE1), Color(0xFFE5DDE1)],
                )
              : const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFE83B91), Color(0xFFC91660)],
                ),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: Color(0x55D01A63),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),

        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(22),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: disabled
                            ? const Color(0xFF9C969B)
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
