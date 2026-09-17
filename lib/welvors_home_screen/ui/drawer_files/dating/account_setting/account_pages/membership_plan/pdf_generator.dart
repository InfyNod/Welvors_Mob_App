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

      final primaryColor = PdfColor.fromHex('#E43A6A');
      final greyDark = PdfColor.fromHex('#333333');
      final greyLight = PdfColor.fromHex('#F5F5F7');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // Top Color Bar
                pw.Container(
                  height: 12,
                  color: primaryColor,
                ),
                
                // Main Content Container
                pw.Container(
                  padding: const pw.EdgeInsets.all(40),
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
                                  fontSize: 32,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'TAX INVOICE',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: greyDark,
                                  letterSpacing: 2,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                company['legalName'] ?? 'INFYNOD TECH PRIVATE LIMITED',
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: statusBgColor,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                              border: pw.Border.all(color: statusColor, width: 1),
                            ),
                            child: pw.Text(
                              status,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: statusColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 30),
                      
                      // DIVIDER
                      pw.Divider(color: PdfColors.grey300, thickness: 1),
                      pw.SizedBox(height: 30),
                      
                      // Details Grid
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPdfDetailCol('INVOICE NO.', invoiceNo),
                          _buildPdfDetailCol('DATE', dateFormatted),
                          _buildPdfDetailCol('BILLED TO', billedTo['name'] ?? 'N/A'),
                          _buildPdfDetailCol('GSTIN', billedTo['gstin'] ?? 'N/A'),
                        ],
                      ),
                      pw.SizedBox(height: 40),
                      
                      // Items Table Header
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(8),
                            topRight: pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('DESCRIPTION', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      
                      // Items Table Body
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: greyLight,
                          borderRadius: const pw.BorderRadius.only(
                            bottomLeft: pw.Radius.circular(8),
                            bottomRight: pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            _buildPdfRow(
                              '${membership['packageName']} membership · ${membership['durationLabel']}',
                              'Rs. ${amountData['taxableAmount'] ?? 0}',
                            ),
                            pw.SizedBox(height: 16),
                            _buildPdfRow(
                              'GST (${amountData['gstPercentage'] ?? 18}%)',
                              'Rs. ${amountData['gstAmount'] ?? 0}',
                            ),
                            pw.SizedBox(height: 20),
                            pw.Divider(color: PdfColors.grey400, thickness: 1),
                            pw.SizedBox(height: 16),
                            _buildPdfRow(
                              'Total paid',
                              'Rs. ${amountData['totalPaid'] ?? 0}',
                              isBold: true,
                              fontSize: 18,
                              textColor: primaryColor,
                            ),
                            pw.SizedBox(height: 24),
                            _buildPdfRow(
                              'Payment Method',
                              payment['displayMethod'] ?? 'Online payment',
                              textColor: PdfColors.grey700,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      
                      pw.SizedBox(height: 60),
                      
                      // Footer
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 16),
                      pw.Center(
                        child: pw.Text(
                          invoiceData['note'] ?? 'Digital service · SAC 998439 · This is a computer-generated invoice.\nRegistered office: Office No. 243, The Capital, Hadapsar, Pune, 411028',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                            lineSpacing: 2,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
