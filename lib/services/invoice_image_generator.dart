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

/// ✅ FUNCIONA 100% OFFLINE - No requiere internet
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
      AppLogger.info('📸 Generando boleta...');
      
      final overlay = Overlay.of(context);
      
      overlayEntry = OverlayEntry(
        builder: (overlayContext) => Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              child: Container(
                width: 600,
                color: Colors.grey[200],
                child: Center(
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(24),
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
          ),
        ),
      );

      overlay.insert(overlayEntry);
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (_globalKey.currentContext == null) {
        throw Exception('No se pudo obtener el contexto del RepaintBoundary');
      }

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('No se pudo convertir la imagen a bytes');
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      AppLogger.success('Imagen capturada: ${pngBytes.length} bytes');

      overlayEntry.remove();
      overlayEntry = null;

      final directory = await getTemporaryDirectory();
      final tempPath = '${directory.path}/temp_invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);
      
      if (!await file.exists()) {
        throw Exception('No se pudo guardar la imagen temporal');
      }

      AppLogger.success('Imagen guardada: $tempPath');
      return tempPath;
      
    } catch (e, stackTrace) {
      AppLogger.error('Error crítico al generar imagen', e, stackTrace);
      rethrow;
    } finally {
      try {
        overlayEntry?.remove();
      } catch (e) {
        AppLogger.warning('Error al remover overlay (no crítico)');
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
        
        // Logo centrado
        Center(
          child: Column(
            children: [
              // ✅ CORREGIDO: Usar businessProfile.logoPath
              if (businessProfile.logoPath.isNotEmpty)
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(businessProfile.logoPath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business, 
                          size: 70,
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 70,
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Icon(
                    Icons.business, 
                    size: 70,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // ✅ CORREGIDO: Usar businessProfile.name
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
        
        // ✅ CORREGIDO: Usar businessProfile.address
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
        
        // ✅ CORREGIDO: Usar businessProfile.phone
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
        
        // ✅ CORREGIDO: Usar businessProfile.email
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
        
        // Tabla de productos con header integrado
        Table(
          border: TableBorder.all(color: Colors.grey[400]!, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.2),
          },
          children: [
            // Header de tabla
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.productList,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.unitPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.totalPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Filas de productos
            ...invoice.items.map((item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    settingsProvider.formatPrice(item.price),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    settingsProvider.formatPrice(item.total),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Total
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
        
        // Fecha y hora
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
