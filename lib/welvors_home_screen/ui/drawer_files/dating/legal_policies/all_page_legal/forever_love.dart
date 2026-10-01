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

  Widget _buildRichText(List<dynamic> contentSegments, {double fontSize = 14, bool defaultBold = false}) {
    List<TextSpan> spans = [];
    for (var segment in contentSegments) {
      if (segment is Map<String, dynamic>) {
        final text = segment['text'] ?? '';
        final isBold = segment['bold'] == true || defaultBold;

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

            return Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
              child: _buildRichText(content, fontSize: fontSize, defaultBold: true),
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
                    color: Colors.black.withValues(alpha: 0.04),
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
