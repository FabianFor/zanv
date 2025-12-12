import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'backups_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;
    
    final double maxWidth = isLargeTablet ? 900 : (isTablet ? 700 : double.infinity);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
            children: [
              // MODO OSCURO
              _buildSettingCard(
                context: context,
                theme: theme,
                icon: settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor: theme.primary,
                title: l10n.darkMode,
                subtitle: l10n.darkModeSubtitle,
                trailing: Switch(
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) => settingsProvider.toggleDarkMode(),
                  activeColor: theme.primary,
                ),
                isTablet: isTablet,
              ),
              
              SizedBox(height: isTablet ? 14.h : 16.h),

              // PERFIL DEL NEGOCIO - SOLO ADMIN
              if (authProvider.esAdmin)
                _buildSettingCard(
                  context: context,
                  theme: theme,
                  icon: Icons.store,
                  iconColor: theme.primary,
                  title: l10n.businessProfile,
                  subtitle: l10n.businessProfileSubtitle,
                  trailing: Icon(Icons.chevron_right, color: theme.iconColor),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  isTablet: isTablet,
                ),

              if (authProvider.esAdmin) SizedBox(height: isTablet ? 14.h : 16.h),

              // IDIOMA
              _buildSettingCard(
                context: context,
                theme: theme,
                icon: Icons.language,
                iconColor: theme.success,
                title: l10n.language,
                subtitle: settingsProvider.currentLanguageName,
                trailing: Icon(Icons.chevron_right, color: theme.iconColor),
                onTap: () => _showLanguageDialog(context, isTablet, theme),
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 14.h : 16.h),

              // MONEDA - SOLO ADMIN
              _buildSettingCard(
                context: context,
                theme: theme,
                icon: Icons.attach_money,
                iconColor: const Color(0xFF9C27B0),
                title: l10n.currency,
                subtitle: '${settingsProvider.currentCurrencyFlag} ${settingsProvider.currentCurrencyName}',
                trailing: authProvider.esAdmin 
                    ? Icon(Icons.chevron_right, color: theme.iconColor)
                    : Icon(Icons.lock, color: theme.textHint, size: 20.sp),
                onTap: authProvider.esAdmin 
                    ? () => _showCurrencyDialog(context, isTablet, theme)
                    : () => _showAdminOnlyDialog(context, theme, l10n),
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 14.h : 16.h),

              // FORMATO DE DESCARGA
              _buildSettingCard(
                context: context,
                theme: theme,
                icon: Icons.download,
                iconColor: const Color(0xFFFF6B6B),
                title: l10n.downloadFormat,
                subtitle: settingsProvider.downloadFormat == 'pdf' 
                    ? '📄 ${l10n.downloadFormatPdf}' 
                    : '🖼️ ${l10n.downloadFormatImage}',
                trailing: Icon(Icons.chevron_right, color: theme.iconColor),
                onTap: () => _showDownloadFormatDialog(context, isTablet, theme),
                isTablet: isTablet,
              ),

              // SECCIÓN: RESPALDO Y RESTAURACIÓN (SOLO 1 BOTÓN)
              if (authProvider.esAdmin) ...[
                SizedBox(height: isTablet ? 24.h : 28.h),
                
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                  child: Text(
                    l10n.backupAndRestore,
                    style: TextStyle(
                      fontSize: isTablet ? 15.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                    ),
                  ),
                ),

                // ✅ SOLO ESTE BOTÓN: MIS BACKUPS
                _buildSettingCard(
                  context: context,
                  theme: theme,
                  icon: Icons.backup,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Mis Backups',
                  subtitle: 'Administrar backups de productos y facturas',
                  trailing: Icon(Icons.chevron_right, color: theme.iconColor),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupsScreen()),
                  ),
                  isTablet: isTablet,
                ),
              ],

              SizedBox(height: isTablet ? 36.h : 32.h),

              // INFO DE LA APP
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.businessManagement,
                      style: TextStyle(
                        fontSize: isTablet ? 18.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${l10n.version} 1.0.0',
                      style: TextStyle(
                        fontSize: isTablet ? 14.sp : 14.sp,
                        color: theme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================
  Widget _buildSettingCard({
    required BuildContext context,
    required ThemeHelper theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isTablet,
  }) {
    final fontSize = isTablet ? 16.0.sp : 16.0.sp;
    final subtitleSize = isTablet ? 13.0.sp : 13.0.sp;
    final iconSize = isTablet ? 26.0.sp : 28.0.sp;
    final padding = isTablet ? 16.0.w : 16.0.w;

    return Card(
      elevation: theme.isDark ? 4 : 2,
      color: theme.cardBackground,
      shadowColor: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isTablet ? padding * 0.65 : padding * 0.75,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 11.w : 12.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 16.w : 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminOnlyDialog(BuildContext context, ThemeHelper theme, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.lock, color: theme.warning, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.adminOnly,
                style: TextStyle(fontSize: 18.sp, color: theme.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.adminOnlyCurrencyMessage,
          style: TextStyle(fontSize: 15.sp, color: theme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.understood, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isTablet, ThemeHelper theme) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500.w : 400.w,
            maxHeight: screenHeight * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 20.w : 20.w),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, color: Colors.white, size: isTablet ? 24.sp : 24.sp),
                    SizedBox(width: isTablet ? 14.w : 12.w),
                    Expanded(
                      child: Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          fontSize: isTablet ? 19.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: isTablet ? 23.sp : 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: SettingsProvider.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedLanguages.entries.elementAt(index);
                    final isSelected = settingsProvider.locale.languageCode == entry.key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.w : 24.w,
                        vertical: isTablet ? 10.h : 8.h,
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: theme.textPrimary,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: theme.primary,
                              size: isTablet ? 24.sp : 24.sp,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: theme.primaryWithOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      onTap: () {
                        settingsProvider.setLanguage(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, bool isTablet, ThemeHelper theme) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 550.w : 450.w,
            maxHeight: screenHeight * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 20.w : 20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.white, size: isTablet ? 24.sp : 24.sp),
                    SizedBox(width: isTablet ? 14.w : 12.w),
                    Expanded(
                      child: Text(
                        l10n.selectCurrency,
                        style: TextStyle(
                          fontSize: isTablet ? 19.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: isTablet ? 23.sp : 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: SettingsProvider.supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedCurrencies.entries.elementAt(index);
                    final currencyCode = entry.key;
                    final isSelected = settingsProvider.currencyCode == currencyCode;
                    
                    final currencyName = settingsProvider.getCurrencyNameForCode(
                      currencyCode,
                      settingsProvider.locale.languageCode,
                    );
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.w : 24.w,
                        vertical: isTablet ? 10.h : 8.h,
                      ),
                      leading: Text(
                        entry.value['flag']!,
                        style: TextStyle(fontSize: isTablet ? 28.sp : 28.sp),
                      ),
                      title: Text(
                        currencyName,
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '$currencyCode - ${entry.value['symbol']!}',
                        style: TextStyle(
                          fontSize: isTablet ? 14.sp : 14.sp,
                          color: theme.textSecondary,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF9C27B0),
                              size: isTablet ? 24.sp : 24.sp,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF9C27B0).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      onTap: () {
                        settingsProvider.setCurrency(currencyCode);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadFormatDialog(BuildContext context, bool isTablet, ThemeHelper theme) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 450.w : 380.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 20.w : 20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.white, size: isTablet ? 24.sp : 24.sp),
                    SizedBox(width: isTablet ? 14.w : 12.w),
                    Expanded(
                      child: Text(
                        l10n.downloadFormat,
                        style: TextStyle(
                          fontSize: isTablet ? 19.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: isTablet ? 23.sp : 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.w : 24.w,
                        vertical: isTablet ? 10.h : 8.h,
                      ),
                      leading: Text(
                        '🖼️',
                        style: TextStyle(fontSize: isTablet ? 28.sp : 28.sp),
                      ),
                      title: Text(
                        l10n.downloadFormatImage,
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 16.sp,
                          fontWeight: settingsProvider.downloadFormat == 'image' 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: theme.textPrimary,
                        ),
                      ),
                      trailing: settingsProvider.downloadFormat == 'image' 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFFFF6B6B),
                              size: isTablet ? 24.sp : 24.sp,
                            )
                          : null,
                      selected: settingsProvider.downloadFormat == 'image',
                      selectedTileColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      onTap: () {
                        settingsProvider.setDownloadFormat('image');
                        Navigator.pop(context);
                      },
                    ),
                    
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.w : 24.w,
                        vertical: isTablet ? 10.h : 8.h,
                      ),
                      leading: Text(
                        '📄',
                        style: TextStyle(fontSize: isTablet ? 28.sp : 28.sp),
                      ),
                      title: Text(
                        l10n.downloadFormatPdf,
                        style: TextStyle(
                          fontSize: isTablet ? 16.sp : 16.sp,
                          fontWeight: settingsProvider.downloadFormat == 'pdf' 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: theme.textPrimary,
                        ),
                      ),
                      trailing: settingsProvider.downloadFormat == 'pdf' 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFFFF6B6B),
                              size: isTablet ? 24.sp : 24.sp,
                            )
                          : null,
                      selected: settingsProvider.downloadFormat == 'pdf',
                      selectedTileColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      onTap: () {
                        settingsProvider.setDownloadFormat('pdf');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
