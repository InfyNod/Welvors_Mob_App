import 'dart:io';

import 'package:flutter/material.dart';

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
      child: Container(
        width: double.infinity,
        height: 194,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE7F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5B8D2), width: 1.5),
        ),
        child: uploaded
            ? _UploadedContent(file: file!)
            : _EmptyContent(title: title),
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
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFED1472), width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFFED1472),
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD41464),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'JPG, PNG or PDF · Max 5MB',
          style: TextStyle(color: Color(0xFFA39BA1), fontSize: 16),
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
