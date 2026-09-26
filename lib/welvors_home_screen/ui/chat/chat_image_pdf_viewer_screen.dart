import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:velvors/welvors_home_screen/ui/drawer_files/dating/core_ecosystem/trust_verification/utils/mycolor.dart';
import 'package:velvors/config/app_cached_image.dart';

class ChatImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ChatImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  bool get _isLocal =>
      !imageUrl.startsWith('http://') && !imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final image = _isLocal
        ? Image.file(File(imageUrl), fit: BoxFit.contain)
        : AppCachedImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Mycolor.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Photo',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 25,
            color: Mycolor.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4,
          child: Center(
            child: heroTag == null ? image : Hero(tag: heroTag!, child: image),
          ),
        ),
      ),
    );
  }
}

class ChatPdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const ChatPdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = 'Document',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
