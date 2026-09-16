import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<File?> generateInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final pdf = pw.Document();

      final invoice = invoiceData['invoice'] ?? {};
      final company = invoiceData['company'] ?? {};
      final billedTo = invoiceData['billedTo'] ?? {};
      final membership = invoiceData['membership'] ?? {};
      final amountData = invoiceData['amount'] ?? {};
      final payment = invoiceData['payment'] ?? {};
      
      final String invoiceNo = invoice['invoiceNumber'] ?? 'INV-N/A';
      String dateFormatted = 'N/A';
      if (invoice['date'] != null) {
        try {
          dateFormatted = DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['date']));
        } catch (_) {}
      }
      
      final String status = invoice['status']?.toString().toUpperCase() ?? 'PAID';
      
      // Determine colors based on status
      PdfColor statusColor = PdfColor.fromHex('#1CB569'); // Green
      PdfColor statusBgColor = PdfColor.fromHex('#E8F6EF');
      if (status == 'REFUNDED' || status == 'FAILED') {
        statusColor = PdfColor.fromHex('#E43A6A');
        statusBgColor = PdfColor.fromHex('#FDF0F3');
      } else if (status == 'PENDING') {
        statusColor = PdfColor.fromHex('#E28A11');
        statusBgColor = PdfColor.fromHex('#FFF7E6');
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // HEADER
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            company['brandName'] ?? 'Welvors',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            company['legalName'] ?? 'INFYNOD TECH PRIVATE LIMITED',
                            style: const pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: statusBgColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          status,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  
                  // DIVIDER
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 24),
                  
                  // Details Grid
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildPdfDetailCol('INVOICE NO.', invoiceNo),
                      ),
                      pw.Expanded(
                        child: _buildPdfDetailCol('DATE', dateFormatted),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildPdfDetailCol('BILLED TO', billedTo['name'] ?? 'N/A'),
                      ),
                      pw.Expanded(
                        child: _buildPdfDetailCol('GSTIN', billedTo['gstin'] ?? 'N/A'),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 32),
                  
                  // Items Table
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F9F9F9'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfRow(
                          '${membership['packageName']} membership · ${membership['durationLabel']}',
                          '₹${amountData['taxableAmount'] ?? 0}',
                        ),
                        pw.SizedBox(height: 12),
                        _buildPdfRow(
                          'GST (${amountData['gstPercentage'] ?? 18}%)',
                          '₹${amountData['gstAmount'] ?? 0}',
                        ),
                        pw.SizedBox(height: 16),
                        pw.Divider(color: PdfColors.black, thickness: 1.5),
                        pw.SizedBox(height: 12),
                        _buildPdfRow(
                          'Total paid',
                          '₹${amountData['totalPaid'] ?? 0}',
                          isBold: true,
                          fontSize: 16,
                        ),
                        pw.SizedBox(height: 24),
                        _buildPdfRow(
                          'Paid via',
                          payment['displayMethod'] ?? 'Online payment',
                          textColor: PdfColors.grey700,
                        ),
                      ],
                    ),
                  ),
                  
                  pw.Spacer(),
                  
                  // Footer
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    invoiceData['note'] ?? 'Digital service · SAC 998439 · This is a computer-generated invoice.\nRegistered office: Office No. 243, The Capital, Hadapsar, Pune, 411028',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$invoiceNo.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildPdfDetailCol(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfRow(String label, String amount, {bool isBold = false, double fontSize = 14, PdfColor textColor = PdfColors.black}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor,
          ),
        ),
        pw.Text(
          amount,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}
