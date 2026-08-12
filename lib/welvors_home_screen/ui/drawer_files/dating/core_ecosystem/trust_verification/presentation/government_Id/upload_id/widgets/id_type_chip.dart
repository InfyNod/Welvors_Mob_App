import 'package:flutter/material.dart';
import '../models/upload_id_model.dart';

class IdTypeChip extends StatelessWidget {
  final IdType idType;
  final bool selected;
  final VoidCallback onTap;

  const IdTypeChip({
    super.key,
    required this.idType,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE5F0) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? const Color(0xFFED1472) : const Color(0xFFE9E3E6),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(idType.emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(
              idType.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFFD41464)
                    : const Color(0xFF625D63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
