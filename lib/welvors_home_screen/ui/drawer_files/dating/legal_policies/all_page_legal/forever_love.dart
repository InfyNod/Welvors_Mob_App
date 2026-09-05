import 'package:flutter/material.dart';
import '../service_legal/service_legal.dart';
import 'package:intl/intl.dart';

class ForeverLoveScreen extends StatefulWidget {
  const ForeverLoveScreen({super.key});

  @override
  State<ForeverLoveScreen> createState() => _ForeverLoveScreenState();
}

class _ForeverLoveScreenState extends State<ForeverLoveScreen> {
  final LegalApiService _apiService = LegalApiService();
  late Future<Map<String, dynamic>?> _legalDataFuture;

  @override
  void initState() {
    super.initState();
    _legalDataFuture = _apiService.getLegalPage('FOREVER_LOVE_PROGRAMME_TERMS');
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildRichText(List<dynamic> contentSegments, {double fontSize = 14}) {
    List<TextSpan> spans = [];
    for (var segment in contentSegments) {
      if (segment is Map<String, dynamic>) {
        final text = segment['text'] ?? '';
        final isBold = segment['bold'] == true;

        Color textColor = isBold ? Colors.black87 : Colors.grey.shade700;
        final colorHex = segment['color'] as String?;
        if (colorHex != null && colorHex.startsWith('#')) {
          final hex = colorHex.replaceFirst('#', 'FF');
          final parsed = int.tryParse(hex, radix: 16);
          if (parsed != null) textColor = Color(parsed);
        }

        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              fontSize: fontSize,
              color: textColor,
              height: 1.6,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildBlocks(List<dynamic> blocks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block is Map<String, dynamic>) {
          final type = block['type'];

          if (type == 'paragraph') {
            final content = block['content'] as List<dynamic>? ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildRichText(content),
            );
          } else if (type == 'heading') {
            final content = block['content'] as List<dynamic>? ?? [];
            final level = block['level'] as int? ?? 2;
            final fontSize = level == 1 ? 22.0 : (level == 2 ? 18.0 : 16.0);

            String fullText = '';
            for (var segment in content) {
              if (segment is Map<String, dynamic>) {
                fullText += segment['text'] ?? '';
              }
            }

            final match = RegExp(
              r'^(\d+)\.\s*(.*)',
            ).firstMatch(fullText.trim());
            if (match != null) {
              final number = match.group(1)!;
              final text = match.group(2)!;

              return Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B8B), Color(0xFFE43A6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE43A6A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
              child: _buildRichText(content, fontSize: fontSize),
            );
          } else if (type == 'bulletList') {
            final items = block['items'] as List<dynamic>? ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  final itemContent = item['content'] as List<dynamic>? ?? [];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 0.0, right: 8.0),
                          child: Text(
                            "•",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Expanded(child: _buildRichText(itemContent)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          } else if (type == 'quote') {
            final content = block['content'] as List<dynamic>? ?? [];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE43A6A), width: 4),
                  ),
                ),
                child: _buildRichText(content, fontSize: 14),
              ),
            );
          }
        }
        return const SizedBox();
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Forever Love',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _legalDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE43A6A)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load terms.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _legalDataFuture = _apiService.getLegalPage(
                          'FOREVER_LOVE_PROGRAMME_TERMS',
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE43A6A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final effectiveFrom = data['effectiveFrom'] ?? '';
          final contentMap = data['content'] as Map<String, dynamic>? ?? {};
          final blocks = List<dynamic>.from(contentMap['blocks'] ?? []);

          String badgeText = '';
          if (blocks.isNotEmpty) {
            final firstBlock = blocks.first;
            if (firstBlock is Map<String, dynamic> &&
                firstBlock['type'] == 'paragraph') {
              final content = firstBlock['content'] as List<dynamic>? ?? [];
              if (content.isNotEmpty && content.first is Map<String, dynamic>) {
                final text = content.first['text']?.toString() ?? '';
                if (text.contains('Last updated') ||
                    text.contains('Effective')) {
                  badgeText = text;
                  blocks.removeAt(0); // Remove it so it doesn't render twice
                }
              }
            }
          }

          if (badgeText.isEmpty && effectiveFrom.isNotEmpty) {
            badgeText = 'Effective from ${_formatDate(effectiveFrom)}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badgeText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3), // light pink
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.pink.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.update,
                          size: 14,
                          color: Colors.pink.shade400,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.pink.shade600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Content parsed from API blocks
                if (blocks.isNotEmpty)
                  _buildBlocks(blocks)
                else
                  Text(
                    'No content available.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
