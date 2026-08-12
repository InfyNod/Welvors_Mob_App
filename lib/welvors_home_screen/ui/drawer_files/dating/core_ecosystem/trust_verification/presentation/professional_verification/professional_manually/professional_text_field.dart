import 'package:flutter/material.dart';
import '../../../utils/mycolor.dart';

class ProfessionalTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const ProfessionalTextField({
    super.key,
    required this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9E1E4), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),

      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLength: 12,
        cursorColor: const Color(0xFF9A9298),
        // controller: _aadhaarController,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9A9298),
        ),

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9A9298),
          ),

          // Remove character counter
          counterText: '',

          filled: true,
          fillColor: Colors.white,

          // Exact spacing like screenshot
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 1),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Mycolor.pink2, width: 1),
          ),
        ),
      ),
    );
  }
}
