import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart'; // ✅ AGREGADO

class InvoiceImageGenerator {
  static final GlobalKey _globalKey = GlobalKey();

  /// Genera imagen de boleta con diseño minimalista
  static Future<String> generateImage({
    required Invoice invoice,
    required BusinessProfile businessProfile,
    required BuildContext context,
    required SettingsProvider settingsProvider, // ✅ NUEVO PARÁMETRO
  }) async {
    try {
      print('📸 Generando boleta minimalista...');
      
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              child: Container(
                width: 600,
                color: const Color(0xFFF5F3EE),
                child: MinimalistInvoiceWidget(
                  invoice: invoice,
                  businessProfile: businessProfile,
                  settingsProvider: settingsProvider, // ✅ PASAMOS EL PROVIDER
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      await Future.delayed(const Duration(milliseconds: 500));

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      print('✅ Imagen capturada: ${pngBytes.length} bytes');

      overlayEntry.remove();

      final directory = await getTemporaryDirectory();
      final tempPath = '${directory.path}/temp_invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);

      print('✅ Imagen guardada: $tempPath');
      return tempPath;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }
}

class MinimalistInvoiceWidget extends StatelessWidget {
  final Invoice invoice;
  final BusinessProfile businessProfile;
  final SettingsProvider settingsProvider; // ✅ AGREGADO

  const MinimalistInvoiceWidget({
    super.key,
    required this.invoice,
    required this.businessProfile,
    required this.settingsProvider, // ✅ AGREGADO
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      color: const Color(0xFFF5F3EE),
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== HEADER ====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NÚMERO DE BOLETA
              Text(
                'N° ${invoice.invoiceNumber.toString().padLeft(7, '0')}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                  letterSpacing: 1,
                ),
              ),

              // INFO DEL NEGOCIO
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (businessProfile.logoPath.isNotEmpty)
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(businessProfile.logoPath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.store,
                                size: 60,
                                color: Color(0xFF4A7C8C),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Text(
                    businessProfile.businessName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C8C),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  if (businessProfile.email.isNotEmpty)
                    Text(
                      businessProfile.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                  if (businessProfile.address.isNotEmpty)
                    Text(
                      businessProfile.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (businessProfile.phone.isNotEmpty)
                    Text(
                      businessProfile.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ==================== TABLA ====================
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2C2C2C),
                  width: 1.5,
                ),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'CANT.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'DESCRIPCIÓN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'PRECIO UNIT.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Items
          ...invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2C2C2C),
                      ),
                      maxLines: 2, // ✅ Protección contra nombres largos
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      settingsProvider.formatPrice(item.price), // ✅ USA MONEDA CORRECTA
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 100,
                    child: Text(
                      settingsProvider.formatPrice(item.total), // ✅ USA MONEDA CORRECTA
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // ==================== TOTAL ====================
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF2C2C2C),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'TOTAL: ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  settingsProvider.formatPrice(invoice.total), // ✅ USA MONEDA CORRECTA
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ==================== MENSAJE FINAL ====================
          Center(
            child: Text(
              _getThankYouMessage(settingsProvider.locale.languageCode), // ✅ TRADUCIDO
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5C5C5C),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Fecha
          Center(
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Traducción del mensaje de agradecimiento
  String _getThankYouMessage(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Gracias por su preferencia.';
      case 'en':
        return 'Thank you for your preference.';
      case 'pt':
        return 'Obrigado pela sua preferência.';
      case 'zh':
        return '感谢您的惠顾。';
      default:
        return 'Thank you for your preference.';
    }
  }
}
