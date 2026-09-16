import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../service_account_Setting.dart';
import 'pdf_generator.dart';

void showInvoiceBottomSheet(BuildContext context, Map<String, dynamic> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _InvoiceSheetContent(item: item);
    },
  );
}

class _InvoiceSheetContent extends StatefulWidget {
  final Map<String, dynamic> item;
  const _InvoiceSheetContent({required this.item});

  @override
  State<_InvoiceSheetContent> createState() => _InvoiceSheetContentState();
}

class _InvoiceSheetContentState extends State<_InvoiceSheetContent> {
  bool _isLoading = true;
  Map<String, dynamic>? _invoiceData;

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
  }

  Future<void> _fetchInvoice() async {
    final userPackageId = widget.item['userPackageId'];
    if (userPackageId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final data = await AccountSettingService.getMembershipInvoice(userPackageId);
    if (mounted) {
      setState(() {
        _invoiceData = data;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  bool _isDownloading = false;

  Future<void> _downloadPdf() async {
    if (_invoiceData == null) return;
    
    setState(() => _isDownloading = true);
    
    // Generate PDF using frontend package instead of relying on the backend route
    final file = await PdfGenerator.generateInvoice(_invoiceData!);
    
    setState(() => _isDownloading = false);

    if (file != null) {
      try {
        final invoiceNo = _invoiceData?['invoice']?['invoiceNumber'] ?? 'invoice';
        // Share the file so user can save or view it
        await Share.shareXFiles([XFile(file.path)], text: 'Invoice $invoiceNo');
      } catch (e) {
        debugPrint('Error sharing file: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to open PDF')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoiceData == null) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('Failed to load invoice')),
      );
    }

    final invoice = _invoiceData!['invoice'] ?? {};
    final company = _invoiceData!['company'] ?? {};
    final billedTo = _invoiceData!['billedTo'] ?? {};
    final membership = _invoiceData!['membership'] ?? {};
    final amountData = _invoiceData!['amount'] ?? {};
    final payment = _invoiceData!['payment'] ?? {};

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Invoice Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F0EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company['brandName'] ?? 'Welvors',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            company['legalName'] ?? 'INFYNOD TECH PRIVATE LIMITED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          final statusText = invoice['status']?.toString().toUpperCase() ?? 'PAID';
                          Color statusColor = const Color(0xFF1CB569); // Green for PAID
                          Color statusBgColor = const Color(0xFFE8F6EF);
                          
                          if (statusText == 'REFUNDED' || statusText == 'FAILED') {
                            statusColor = const Color(0xFFE43A6A); // Reddish for Refunded/Failed
                            statusBgColor = const Color(0xFFFDF0F3);
                          } else if (statusText == 'PENDING') {
                            statusColor = const Color(0xFFE28A11); // Orange for pending
                            statusBgColor = const Color(0xFFFFF7E6);
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dashed Divider
                  Row(
                    children: List.generate(
                      40,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCol(
                          'INVOICE NO.',
                          invoice['invoiceNumber'] ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDetailCol('DATE', _formatDate(invoice['date']))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCol(
                          'BILLED TO',
                          billedTo['name'] ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCol('GSTIN', billedTo['gstin'] ?? 'N/A'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Items
                  _buildRow(
                    '${membership['packageName']} membership · ${membership['durationLabel']}',
                    '₹${amountData['taxableAmount']}',
                    isBoldAmount: true,
                  ),
                  const SizedBox(height: 8),
                  _buildRow('GST (${amountData['gstPercentage']}%)', '₹${amountData['gstAmount']}', isBoldAmount: true),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black, thickness: 1.5),
                  const SizedBox(height: 8),
                  _buildRow(
                    'Total paid',
                    '₹${amountData['totalPaid']}',
                    isBoldLabel: true,
                    isBoldAmount: true,
                    amountSize: 16,
                  ),
                  const SizedBox(height: 20),
                  _buildRow(
                    'Paid via',
                    payment['displayMethod'] ?? 'Online payment',
                    labelColor: Colors.black45,
                    amountSize: 12,
                    isBoldAmount: true,
                  ),
                  const SizedBox(height: 20),
                  // Footer disclaimer
                  Text(
                    _invoiceData!['note'] ?? 'Digital service · SAC 998439 · This is a computer-generated invoice.',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadPdf,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 18,
                        ),
                  label: Text(
                    _isDownloading ? 'Downloading...' : 'Download PDF',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A),
                    disabledBackgroundColor: const Color(0xFFE43A6A).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String amount, {
    bool isBoldLabel = false,
    bool isBoldAmount = false,
    Color? labelColor,
    double? amountSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBoldLabel ? FontWeight.bold : FontWeight.w500,
            color: labelColor ?? Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: amountSize ?? 13,
            fontWeight: isBoldAmount ? FontWeight.w800 : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
