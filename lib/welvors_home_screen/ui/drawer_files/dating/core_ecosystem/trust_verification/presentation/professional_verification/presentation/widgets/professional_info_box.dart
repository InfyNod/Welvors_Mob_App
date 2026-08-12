import 'package:flutter/material.dart';

class ProfessionalInfoBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool success;

  const ProfessionalInfoBox({
    super.key,
    required this.text,
    required this.icon,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFE3F6EC) : const Color(0xFFFCE3EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: success ? const Color(0xFF21A366) : const Color(0xFFC9155D),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: success
                    ? const Color(0xFF279D63)
                    : const Color(0xFFC9155D),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
