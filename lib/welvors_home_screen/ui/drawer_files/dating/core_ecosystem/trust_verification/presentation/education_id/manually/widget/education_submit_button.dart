import 'package:flutter/material.dart';

class EducationSubmitButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const EducationSubmitButton({
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
        opacity: onTap == null ? 1 : 1,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
