
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/utils/theme_helper.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../services/backup_service.dart';
import '../models/product.dart';

class BackupsScreen extends StatefulWidget {
  const BackupsScreen({super.key});

  @override
  State<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends State<BackupsScreen> {
  List<BackupFile> _productBackups = [];
  List<BackupFile> _invoiceBackups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    
    final products = await BackupService.listProductBackups();
    final invoices = await BackupService.listInvoiceBackups();
    
    setState(() {
      _productBackups = products;
      _invoiceBackups = invoices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Mis Backups',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackups,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : RefreshIndicator(
              onRefresh: _loadBackups,
              color: theme.primary,
              child: ListView(
                padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
                children: [
                  // BOTONES DE ACCIÓN RÁPIDA (4 BOTONES EN GRID)
                  _buildQuickActions(theme, isTablet),

                  SizedBox(height: isTablet ? 28.h : 24.h),

                  // PRODUCTOS
                  _buildSectionHeader(
                    theme,
                    '📦 Productos',
                    Icons.inventory_2,
                    const Color(0xFF4CAF50),
                    isTablet,
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  if (_productBackups.isEmpty)
                    _buildEmptyState(theme, 'No hay backups de productos', isTablet)
                  else
                    ..._productBackups.map((backup) => _buildBackupCard(
                          theme,
                          backup,
                          'product',
                          isTablet,
                        )),
                  
                  SizedBox(height: isTablet ? 32.h : 28.h),
                  
                  // FACTURAS/RECIBOS
                  _buildSectionHeader(
                    theme,
                    '🧾 Facturas',
                    Icons.receipt_long,
                    const Color(0xFFFF9800),
                    isTablet,
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  if (_invoiceBackups.isEmpty)
                    _buildEmptyState(theme, 'No hay backups de facturas', isTablet)
                  else
                    ..._invoiceBackups.map((backup) => _buildBackupCard(
                          theme,
                          backup,
                          'invoice',
                          isTablet,
                        )),
                ],
              ),
            ),
    );
  }

  // ==================== BOTONES DE ACCIÓN RÁPIDA ====================
  Widget _buildQuickActions(ThemeHelper theme, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: isTablet ? 17.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // EXPORTAR PRODUCTOS
            Expanded(
              child: _buildActionButton(
                icon: Icons.upload_file,
                label: 'Exportar\nProductos',
                color: const Color(0xFF4CAF50),
                onTap: () => _exportProducts(),
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: 12.w),
            // IMPORTAR PRODUCTOS
            Expanded(
              child: _buildActionButton(
                icon: Icons.file_download,
                label: 'Importar\nProductos',
                color: const Color(0xFF2196F3),
                onTap: () => _importExternalProducts(),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // EXPORTAR FACTURAS
            Expanded(
              child: _buildActionButton(
                icon: Icons.receipt_long,
                label: 'Exportar\nFacturas',
                color: const Color(0xFFFF9800),
                onTap: () => _exportInvoices(),
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: 12.w),
            // IMPORTAR FACTURAS
            Expanded(
              child: _buildActionButton(
                icon: Icons.cloud_download,
                label: 'Importar\nFacturas',
                color: const Color(0xFF9C27B0),
                onTap: () => _importExternalInvoices(),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final theme = ThemeHelper(context);
    
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 18.h : 20.h,
            horizontal: 12.w,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: isTablet ? 28.sp : 32.sp),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 12.sp : 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EXPORTAR PRODUCTOS ====================
  Future<void> _exportProducts() async {
    final theme = ThemeHelper(context);
    final productProvider = context.read<ProductProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.primary),
              SizedBox(height: 16.h),
              Text(
                'Exportando productos...',
                style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await BackupService.exportProducts(productProvider.products);
      
      if (mounted) Navigator.pop(context);
      
      if (result.success && mounted) {
        await _loadBackups();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${productProvider.products.length} productos exportados'),
            backgroundColor: theme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  // ==================== EXPORTAR FACTURAS ====================
  Future<void> _exportInvoices() async {
    final theme = ThemeHelper(context);
    final invoiceProvider = context.read<InvoiceProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.primary),
              SizedBox(height: 16.h),
              Text(
                'Exportando facturas...',
                style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await BackupService.exportInvoices(invoiceProvider.invoices);
      
      if (mounted) Navigator.pop(context);
      
      if (result.success && mounted) {
        await _loadBackups();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${invoiceProvider.invoices.length} facturas exportadas'),
            backgroundColor: theme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  // ==================== IMPORTAR PRODUCTOS EXTERNOS (CON DIÁLOGO BONITO) ====================
  Future<void> _importExternalProducts() async {
    final theme = ThemeHelper(context);
    final productProvider = context.read<ProductProvider>();

    try {
      final result = await BackupService.importProducts();
      
      if (result.success && result.data != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Procesando productos...',
                    style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),
        );

        int imported = 0;
        int replaced = 0;
        int skipped = 0;

        for (var product in result.data!) {
          final existingProduct = productProvider.products
              .where((p) => p.name.toLowerCase() == product.name.toLowerCase())
              .firstOrNull;
          
          if (existingProduct != null) {
            if (mounted) Navigator.pop(context);
            
            // DIÁLOGO BONITO DE COMPARACIÓN
            final action = await _showProductComparisonDialog(
              theme,
              existingProduct,
              product,
            );

            if (action == 'replace') {
              await productProvider.updateProduct(product.copyWith(id: existingProduct.id));
              replaced++;
            } else if (action == 'skip') {
              skipped++;
            } else {
              skipped++;
            }
            
            if (result.data!.indexOf(product) < result.data!.length - 1 && mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => Center(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: theme.cardBackground,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: theme.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'Procesando productos...',
                          style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            await productProvider.addProduct(product);
            imported++;
          }
        }

        if (mounted) Navigator.pop(context);

        if (mounted) {
          await _loadBackups();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Importados: $imported | 🔄 Reemplazados: $replaced | ⏭️ Omitidos: $skipped',
              ),
              backgroundColor: theme.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  // ==================== IMPORTAR FACTURAS EXTERNAS ====================
  Future<void> _importExternalInvoices() async {
    final theme = ThemeHelper(context);
    final invoiceProvider = context.read<InvoiceProvider>();

    try {
      final result = await BackupService.importInvoices();
      
      if (result.success && result.data != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Importando facturas...',
                    style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),
        );

        int imported = 0;
        int replaced = 0;

        for (var invoice in result.data!) {
          final exists = invoiceProvider.invoices.any((i) => i.id == invoice.id);
          if (exists) {
            await invoiceProvider.updateInvoice(invoice);
            replaced++;
          } else {
            await invoiceProvider.addInvoice(invoice);
            imported++;
          }
        }

        if (mounted) {
          Navigator.pop(context);
          await _loadBackups();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Importados: $imported | 🔄 Reemplazados: $replaced'),
              backgroundColor: theme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  // ==================== RESTAURAR BACKUP (CON DIÁLOGO DE COMPARACIÓN) ====================
  Future<void> _restoreBackup(BackupFile backup, String type) async {
    final theme = ThemeHelper(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.warning, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Confirmar restauración',
                style: TextStyle(color: theme.textPrimary, fontSize: 18.sp),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Restaurar este backup? Se revisarán los productos uno por uno.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.primary),
              SizedBox(height: 16.h),
              Text(
                'Restaurando...',
                style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      if (type == 'product') {
        final result = await BackupService.importProductsFromPath(backup.path);
        if (result.success && result.data != null && mounted) {
          if (mounted) Navigator.pop(context); // Cerrar loading

          final productProvider = context.read<ProductProvider>();
          int imported = 0;
          int replaced = 0;
          int skipped = 0;

          for (var product in result.data!) {
            final existingProduct = productProvider.products
                .where((p) => p.name.toLowerCase() == product.name.toLowerCase())
                .firstOrNull;
            
            if (existingProduct != null) {
              // ✅ MOSTRAR DIÁLOGO DE COMPARACIÓN
              final action = await _showProductComparisonDialog(
                theme,
                existingProduct,
                product,
              );

              if (action == 'replace') {
                await productProvider.updateProduct(product.copyWith(id: existingProduct.id));
                replaced++;
              } else if (action == 'skip') {
                skipped++;
              } else {
                skipped++;
              }

              // Mostrar loading entre productos
              if (result.data!.indexOf(product) < result.data!.length - 1 && mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => Center(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: theme.primary),
                          SizedBox(height: 16.h),
                          Text(
                            'Procesando productos...',
                            style: TextStyle(color: theme.textPrimary, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            } else {
              await productProvider.addProduct(product);
              imported++;
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Importados: $imported | 🔄 Reemplazados: $replaced | ⏭️ Omitidos: $skipped',
                ),
                backgroundColor: theme.success,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        // FACTURAS (SIN COMPARACIÓN)
        final result = await BackupService.importInvoicesFromPath(backup.path);
        if (result.success && result.data != null && mounted) {
          final invoiceProvider = context.read<InvoiceProvider>();
          for (var invoice in result.data!) {
            final exists = invoiceProvider.invoices.any((i) => i.id == invoice.id);
            if (exists) {
              await invoiceProvider.updateInvoice(invoice);
            } else {
              await invoiceProvider.addInvoice(invoice);
            }
          }

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ Facturas restauradas exitosamente'),
                backgroundColor: theme.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  // ==================== DIÁLOGO DE COMPARACIÓN REUTILIZABLE ====================
  Future<String?> _showProductComparisonDialog(
    ThemeHelper theme,
    Product existingProduct,
    Product newProduct,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.zero,
        title: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: theme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: theme.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.warning,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Producto existente',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ya existe un producto con este nombre',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),

              // PRODUCTO ACTUAL (Rojo)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.error.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.error,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'ACTUAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Se eliminará',
                            style: TextStyle(
                              color: theme.error,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      existingProduct.name,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    _buildProductDetail(
                      theme,
                      'Precio',
                      '\$ ${existingProduct.price.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 4.h),
                    _buildProductDetail(
                      theme,
                      'Stock',
                      '${existingProduct.stock} unidades',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // FLECHA INDICADORA
              Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: theme.textHint,
                  size: 24.sp,
                ),
              ),

              SizedBox(height: 16.h),

              // PRODUCTO NUEVO (Verde)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.success.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.success,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'NUEVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Se importará',
                            style: TextStyle(
                              color: theme.success,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      newProduct.name,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    _buildProductDetail(
                      theme,
                      'Precio',
                      '\$ ${newProduct.price.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 4.h),
                    _buildProductDetail(
                      theme,
                      'Stock',
                      '${newProduct.stock} unidades',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'skip'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            child: Text(
              'Omitir',
              style: TextStyle(
                color: theme.textHint,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'keep'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.primary, width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Mantener actual',
              style: TextStyle(
                color: theme.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'replace'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.error,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Reemplazar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET AUXILIAR ====================
  Widget _buildProductDetail(ThemeHelper theme, String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _shareBackup(BackupFile backup) async {
    await BackupService.openFileLocation(backup.path);
  }

  Future<void> _deleteBackup(BackupFile backup, String type) async {
    final theme = ThemeHelper(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: theme.error, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Eliminar backup',
                style: TextStyle(color: theme.textPrimary, fontSize: 18.sp),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Eliminar este backup permanentemente?',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: theme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await BackupService.deleteBackup(backup.path);
      await _loadBackups();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Backup eliminado'),
            backgroundColor: theme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.error,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(
    ThemeHelper theme,
    String title,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: isTablet ? 22.sp : 24.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 17.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeHelper theme, String message, bool isTablet) {
    return Card(
      elevation: 0,
      color: theme.cardBackground.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: theme.textHint.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 28.w : 32.w),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: isTablet ? 52.sp : 56.sp,
              color: theme.textHint.withOpacity(0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 14.sp : 14.sp,
                color: theme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(
    ThemeHelper theme,
    BackupFile backup,
    String type,
    bool isTablet,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return Card(
      elevation: theme.isDark ? 4 : 2,
      color: theme.cardBackground,
      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: theme.primary,
                  size: isTablet ? 22.sp : 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: TextStyle(
                          fontSize: isTablet ? 15.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${dateFormat.format(backup.date)} • ${backup.size}',
                        style: TextStyle(
                          fontSize: isTablet ? 12.sp : 12.sp,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _restoreBackup(backup, type),
                    icon: Icon(Icons.restore, size: isTablet ? 18.sp : 18.sp),
                    label: Text(
                      'Restaurar',
                      style: TextStyle(fontSize: isTablet ? 13.sp : 13.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primary,
                      side: BorderSide(color: theme.primary),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareBackup(backup),
                    icon: Icon(Icons.share, size: isTablet ? 18.sp : 18.sp),
                    label: Text(
                      'Compartir',
                      style: TextStyle(fontSize: isTablet ? 13.sp : 13.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textSecondary,
                      side: BorderSide(color: theme.textHint.withOpacity(0.3)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                IconButton(
                  onPressed: () => _deleteBackup(backup, type),
                  icon: const Icon(Icons.delete_outline),
                  color: theme.error,
                  style: IconButton.styleFrom(
                    side: BorderSide(color: theme.error.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
