import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';


class InvoicePdfGenerator {
  static Future<String> generatePdf({
    required dynamic invoice,
    required BusinessProfile businessProfile,
    required SettingsProvider settingsProvider,
  }) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (businessProfile.logoPath.isNotEmpty) {
      try {
        final logoFile = File(businessProfile.logoPath);
        if (await logoFile.exists()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('⚠️ No se pudo cargar el logo: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Column(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 80,
                          height: 80,
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 70,
                          height: 70,
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 2),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '🏢',
                              style: const pw.TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                pw.Text(
                  businessProfile.name.isNotEmpty 
                    ? businessProfile.name 
                    : 'Nombre del Negocio',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),

                pw.SizedBox(height: 12),

                if (businessProfile.address.isNotEmpty)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('📍 ', style: const pw.TextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          businessProfile.address,
                          style: const pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (businessProfile.address.isNotEmpty)
                  pw.SizedBox(height: 8),

                if (businessProfile.phone.isNotEmpty)
                  pw.Row(
                    children: [
                      pw.Text('📞 ', style: const pw.TextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        businessProfile.phone,
                        style: const pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),

                if (businessProfile.phone.isNotEmpty)
                  pw.SizedBox(height: 8),

                if (businessProfile.email.isNotEmpty)
                  pw.Row(
                    children: [
                      pw.Text('📧 ', style: const pw.TextStyle(fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          businessProfile.email,
                          style: const pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                pw.SizedBox(height: 30),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(0.9),
                    2: const pw.FlexColumnWidth(1.3),
                    3: const pw.FlexColumnWidth(1.3),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'Lista de productos',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'Cant.',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'Unitario',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    ...invoice.items.map<pw.TableRow>((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                              item.productName,
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                              '${item.quantity}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                              settingsProvider.formatPrice(item.price),
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                              settingsProvider.formatPrice(item.total),
                              style: const pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.center,
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
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text(
                    'Total: ${settingsProvider.formatPrice(invoice.total)}',
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
            ),
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
