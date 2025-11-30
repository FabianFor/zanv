import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: isDark ? null : const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // ✅ DARK MODE SWITCH
          Card(
            child: SwitchListTile(
              value: settingsProvider.isDarkMode,
              onChanged: (value) {
                settingsProvider.toggleDarkMode();
              },
              title: Text(
                _getDarkModeText(l10n),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _getDarkModeSubtitleText(l10n),
                style: TextStyle(fontSize: 13.sp),
              ),
              secondary: Icon(
                settingsProvider.isDarkMode 
                    ? Icons.dark_mode 
                    : Icons.light_mode,
                color: const Color(0xFF2196F3),
                size: 28.sp,
              ),
              activeColor: const Color(0xFF2196F3),
            ),
          ),
          
          SizedBox(height: 16.h),

          // Perfil del negocio
          Card(
            child: ListTile(
              leading: Icon(
                Icons.store,
                color: const Color(0xFF2196F3),
                size: 28.sp,
              ),
              title: Text(
                l10n.businessProfile,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _getBusinessProfileSubtitleText(l10n),
                style: TextStyle(fontSize: 13.sp),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          // Idioma
          Card(
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: const Color(0xFF4CAF50),
                size: 28.sp,
              ),
              title: Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${settingsProvider.currentLanguageFlag} ${settingsProvider.currentLanguageName}',
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
          ),

          SizedBox(height: 16.h),

          // Moneda
          Card(
            child: ListTile(
              leading: Icon(
                Icons.attach_money,
                color: const Color(0xFF9C27B0),
                size: 28.sp,
              ),
              title: Text(
                l10n.currency,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${settingsProvider.currentCurrencyFlag} ${settingsProvider.currentCurrencyName}',
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showCurrencyDialog(context);
              },
            ),
          ),

          SizedBox(height: 32.h),

          // Info de la app
          Center(
            child: Column(
              children: [
                Text(
                  'MiNegocio',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsProvider.supportedLanguages.entries.map((entry) {
            final isSelected = settingsProvider.locale.languageCode == entry.key;
            return ListTile(
              leading: Text(
                entry.value['flag']!,
                style: TextStyle(fontSize: 24.sp),
              ),
              title: Text(entry.value['name']!),
              trailing: isSelected 
                  ? Icon(Icons.check, color: const Color(0xFF2196F3), size: 24.sp)
                  : null,
              selected: isSelected,
              onTap: () {
                settingsProvider.setLanguage(entry.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCurrency),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: SettingsProvider.supportedCurrencies.entries.map((entry) {
              final isSelected = settingsProvider.currencyCode == entry.key;
              return ListTile(
                leading: Text(
                  entry.value['flag']!,
                  style: TextStyle(fontSize: 24.sp),
                ),
                title: Text(entry.value['name']!),
                subtitle: Text(entry.value['symbol']!),
                trailing: isSelected 
                    ? Icon(Icons.check, color: const Color(0xFF2196F3), size: 24.sp)
                    : null,
                selected: isSelected,
                onTap: () {
                  settingsProvider.setCurrency(entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  String _getDarkModeText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Modo oscuro';
      case 'en': return 'Dark mode';
      case 'pt': return 'Modo escuro';
      case 'zh': return '深色模式';
      default: return 'Dark mode';
    }
  }

  String _getDarkModeSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Activa el tema oscuro';
      case 'en': return 'Activate dark theme';
      case 'pt': return 'Ativar tema escuro';
      case 'zh': return '激活深色主题';
      default: return 'Activate dark theme';
    }
  }

  String _getBusinessProfileSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Edita la información de tu negocio';
      case 'en': return 'Edit your business information';
      case 'pt': return 'Edite as informações do seu negócio';
      case 'zh': return '编辑您的企业信息';
      default: return 'Edit your business information';
    }
  }
}
