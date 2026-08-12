import 'package:flutter/material.dart';

class ProfessionalSubmitButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ProfessionalSubmitButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: double.infinity,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFFE83B8A), Color(0xFFC9145C)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x45D81B69),
                blurRadius: 25,
                offset: Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
