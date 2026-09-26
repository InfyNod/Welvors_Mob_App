import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';

class DocumentUploadBox extends StatelessWidget {
  final String title;
  final File? file;
  final VoidCallback onTap;

  const DocumentUploadBox({
    super.key,
    required this.title,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool uploaded = file != null;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        // options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        dashPattern: const [3, 2],
        color: AppColors.pinkDeep.withValues(alpha: 0.4),
        strokeWidth: 1.5,
        padding: EdgeInsets.zero,
        // ),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7F1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: uploaded ? const Color(0xFFF5B8D2) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: uploaded
              ? _UploadedContent(file: file!)
              : _EmptyContent(title: title),
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  final String title;

  const _EmptyContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 25,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFED1472), width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFFED1472),
            size: 15,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD41464),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'JPG, PNG or PDF · Max 5MB',
          style: TextStyle(color: Color(0xFFA39BA1), fontSize: 12),
        ),
      ],
    );
  }
}

class _UploadedContent extends StatelessWidget {
  final File file;

  const _UploadedContent({required this.file});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF22A66F), size: 42),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            file.path.split('/').last,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to replace',
          style: TextStyle(
            color: Color(0xFFD41464),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
