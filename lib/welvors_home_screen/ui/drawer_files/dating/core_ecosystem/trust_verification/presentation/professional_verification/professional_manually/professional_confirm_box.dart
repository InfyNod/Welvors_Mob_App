import 'package:flutter/material.dart';

class ProfessionalConfirmBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfessionalConfirmBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE91E73), width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFE91E73) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE91E73), width: 2),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 25,
                    )
                  : null,
            ),

            const SizedBox(width: 19),

            const Expanded(
              child: Text(
                'I confirm these details are accurate. False information leads to removal.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF252126),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
