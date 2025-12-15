import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class InvoicePdfGenerator {
  static Future<String> generatePdf({
    required dynamic invoice,
    required BusinessProfile businessProfile,
    required SettingsProvider settingsProvider,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();

    final textStyle = const pw.TextStyle(fontSize: 12, color: PdfColors.black);
    final boldStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final titleStyle = pw.TextStyle(
      fontSize: 32,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final infoStyle = const pw.TextStyle(fontSize: 16, color: PdfColors.black);

    pw.ImageProvider? logoImage;
    if (businessProfile.logoPath.isNotEmpty) {
      try {
        final logoFile = File(businessProfile.logoPath);
        if (await logoFile.exists()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('Logo error: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),

              if (logoImage != null)
                pw.Center(
                  child: pw.Container(
                    width: 100,
                    height: 100,
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),

              pw.SizedBox(height: 30),

              pw.Text(
                businessProfile.name.isNotEmpty
                    ? businessProfile.name
                    : l10n.businessNameLabel,
                style: titleStyle,
              ),

              pw.SizedBox(height: 12),

              if (businessProfile.address.isNotEmpty)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('📍 ', style: infoStyle),
                    pw.Expanded(
                      child: pw.Text(businessProfile.address, style: infoStyle),
                    ),
                  ],
                ),

              pw.SizedBox(height: 8),

              if (businessProfile.phone.isNotEmpty)
                pw.Row(
                  children: [
                    pw.Text('📞 ', style: infoStyle),
                    pw.Text(businessProfile.phone, style: infoStyle),
                  ],
                ),

              pw.SizedBox(height: 8),

              if (businessProfile.email.isNotEmpty)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('📧 ', style: infoStyle),
                    pw.Expanded(
                      child: pw.Text(businessProfile.email, style: infoStyle),
                    ),
                  ],
                ),

              pw.SizedBox(height: 30),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.8),
                  1: const pw.FlexColumnWidth(1.2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.productList, style: boldStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          l10n.quantity,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          l10n.unitPrice,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          l10n.totalPrice,
                          style: boldStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  ...invoice.items.map<pw.TableRow>((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.productName, style: textStyle),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item.quantity}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            settingsProvider.formatPrice(item.price),
                            style: textStyle,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            settingsProvider.formatPrice(item.total),
                            style: textStyle,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Text(
                  '${l10n.totalLabel} ${settingsProvider.formatPrice(invoice.total)}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/invoice_${invoice.invoiceNumber}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
