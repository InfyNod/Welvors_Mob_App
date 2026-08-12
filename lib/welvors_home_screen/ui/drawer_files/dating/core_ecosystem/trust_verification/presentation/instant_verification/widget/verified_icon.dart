import 'package:flutter/material.dart';

class VerifiedIcon extends StatelessWidget {
  const VerifiedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE5F8F0),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2EA36B),
        ),
        child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
      ),
    );
  }
}
