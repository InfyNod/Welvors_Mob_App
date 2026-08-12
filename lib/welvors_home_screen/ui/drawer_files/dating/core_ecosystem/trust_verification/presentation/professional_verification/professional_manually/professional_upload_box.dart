import 'dart:io';

import 'package:flutter/material.dart';

class ProfessionalUploadBox extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const ProfessionalUploadBox({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 195,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB6D3), width: 2),
        ),
        child: hasFile ? _selectedFile() : _uploadView(),
      ),
    );
  }

  // ===========================================================
  // DEFAULT UPLOAD VIEW
  // ===========================================================

  Widget _uploadView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Document Icon
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE51C72), width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: Color(0xFFE51C72),
            size: 24,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Tap to upload last 3 months’ bank statement',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD51A68),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'JPG, PNG or PDF · Max 5MB',
          style: TextStyle(
            color: Color(0xFF9D969C),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // SELECTED FILE VIEW
  // ===========================================================

  Widget _selectedFile() {
    final fileName = file!.path.split('/').last;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // File icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC8DF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFFE51C72),
            size: 30,
          ),
        ),

        const SizedBox(height: 14),

        // File name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3D383C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Change file
        const Text(
          'Tap to change file',
          style: TextStyle(
            color: Color(0xFFD51A68),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
