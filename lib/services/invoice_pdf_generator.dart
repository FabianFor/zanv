import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

/// ⚡ PDF LIGERO - Sin Google Fonts (ahorra ~15-20 MB)
class InvoicePdfGenerator {
  static Future<String> generatePdf({
    required dynamic invoice,
    required BusinessProfile businessProfile,
    required SettingsProvider settingsProvider,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();

    // ⚡ USAR FUENTES POR DEFECTO (no descargar nada)
    final textStyle = const pw.TextStyle(fontSize: 12);
    final boldStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);

    pw.ImageProvider? logoImage;
    if (businessProfile.logoPath.isNotEmpty) {
      try {
        final logoFile = File(businessProfile.logoPath);
        if (await logoFile.exists()) {
          final bytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('⚠️ Logo no disponible');
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
              // Logo
              if (logoImage != null)
                pw.Center(
                  child: pw.Container(
                    width: 80,
                    height: 80,
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),

              pw.SizedBox(height: 20),

              // Nombre del negocio
              pw.Text(
                businessProfile.name.isNotEmpty ? businessProfile.name : l10n.businessNameLabel,
                style: titleStyle,
              ),

              pw.SizedBox(height: 20),

              // Información
              if (businessProfile.address.isNotEmpty)
                pw.Text('📍 ${businessProfile.address}', style: textStyle),
              if (businessProfile.phone.isNotEmpty)
                pw.Text('📞 ${businessProfile.phone}', style: textStyle),
              if (businessProfile.email.isNotEmpty)
                pw.Text('📧 ${businessProfile.email}', style: textStyle),

              pw.SizedBox(height: 30),

              // Tabla de productos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(l10n.productList, style: boldStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(l10n.quantity, style: boldStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(l10n.unitPrice, style: boldStyle)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(l10n.totalPrice, style: boldStyle)),
                    ],
                  ),

                  // Items
                  ...invoice.items.map<pw.TableRow>((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.productName, style: textStyle)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item.quantity}', style: textStyle)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(settingsProvider.formatPrice(item.price), style: textStyle)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(settingsProvider.formatPrice(item.total), style: textStyle)),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Text(
                  '${l10n.totalLabel} ${settingsProvider.formatPrice(invoice.total)}',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),

              pw.SizedBox(height: 20),

              // Fecha
              pw.Center(
                child: pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
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