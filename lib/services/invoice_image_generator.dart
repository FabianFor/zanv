import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';
import '../core/utils/app_logger.dart';
import '../l10n/app_localizations.dart';

class InvoiceImageGenerator {
  static final GlobalKey _globalKey = GlobalKey();

  static Future<String> generateImage({
    required Invoice invoice,
    required BusinessProfile businessProfile,
    required BuildContext context,
    required SettingsProvider settingsProvider,
  }) async {
    OverlayEntry? overlayEntry;
    
    try {
      AppLogger.info('Generating receipt image...');
      
      final overlay = Overlay.of(context);
      
      overlayEntry = OverlayEntry(
        builder: (overlayContext) => Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: InvoiceContent(
                  invoice: invoice,
                  businessProfile: businessProfile,
                  settingsProvider: settingsProvider,
                  context: context,
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (_globalKey.currentContext == null) {
        throw Exception('RepaintBoundary context not found');
      }

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Image conversion failed');
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      AppLogger.success('Image captured: ${pngBytes.length} bytes');

      overlayEntry.remove();
      overlayEntry = null;

      final directory = await getTemporaryDirectory();
      final tempPath = '${directory.path}/temp_invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);
      
      if (!await file.exists()) {
        throw Exception('Temp file save failed');
      }

      AppLogger.success('Image saved: $tempPath');
      return tempPath;
      
    } catch (e, stackTrace) {
      AppLogger.error('Critical error generating image', e, stackTrace);
      rethrow;
    } finally {
      try {
        overlayEntry?.remove();
      } catch (e) {
        AppLogger.warning('Overlay remove error (non-critical)');
      }
    }
  }
}

class InvoiceContent extends StatelessWidget {
  final Invoice invoice;
  final BusinessProfile businessProfile;
  final SettingsProvider settingsProvider;
  final BuildContext context;

  const InvoiceContent({
    super.key,
    required this.invoice,
    required this.businessProfile,
    required this.settingsProvider,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        
        Center(
          child: Column(
            children: [
              if (businessProfile.logoPath.isNotEmpty)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(businessProfile.logoPath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business, 
                          size: 90,
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Icon(
                    Icons.business, 
                    size: 90,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        Text(
          businessProfile.name.isNotEmpty 
              ? businessProfile.name 
              : l10n.businessNameLabel,
          style: const TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                businessProfile.address.isNotEmpty 
                    ? businessProfile.address 
                    : l10n.addressLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            const Icon(Icons.phone, size: 16, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              businessProfile.phone.isNotEmpty 
                  ? businessProfile.phone 
                  : l10n.phoneLabel,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            const Icon(Icons.email, size: 16, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                businessProfile.email.isNotEmpty 
                    ? businessProfile.email 
                    : l10n.emailLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        Table(
          border: TableBorder.all(color: Colors.grey[400]!, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(2.8),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    l10n.productList,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    l10n.quantity,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    l10n.unitPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    l10n.totalPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            ...invoice.items.map((item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    settingsProvider.formatPrice(item.price),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    settingsProvider.formatPrice(item.total),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[300],
          child: Text(
            '${l10n.totalLabel} ${settingsProvider.formatPrice(invoice.total)}',
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        Center(
          child: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
