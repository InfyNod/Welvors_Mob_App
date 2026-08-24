import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class EducationUploadBox extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const EducationUploadBox({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        // options: RoundedRectDottedBorderOptions(
        color: const Color(0xFFFFB5D3),
        strokeWidth: 2,
        dashPattern: const [3, 2],
        radius: const Radius.circular(15),
        // ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            height: 195,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5F0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE51C72),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: Color(0xFFE51C72),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Tap to upload degree certificate11111',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD51A68),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'JPG, PNG or PDF · Max 5MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D969A),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file_rounded,
                        size: 45,
                        color: Color(0xFFE51C72),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        file!.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Tap to change file',
                        style: TextStyle(
                          color: Color(0xFFD51A68),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
