import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/business_provider.dart';
import '../providers/auth_provider.dart';
import '../models/business_profile.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _logoPath;
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'USD';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Cambiar idioma inmediatamente
  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.setLanguage(languageCode);
  }

  Future<void> _finishOnboarding() async {
    final l10n = AppLocalizations.of(context)!;

    // Validar nombre del negocio
    if (_businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.businessNameHint),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar contraseña
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordTooShort),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordMismatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Guardar configuración (idioma ya está guardado)
    await settingsProvider.setCurrency(_selectedCurrency);

    // Guardar perfil de negocio
    final profile = BusinessProfile(
      name: _businessNameController.text.trim(),
      address: '',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      logoPath: _logoPath ?? '',
    );
    await businessProvider.updateProfile(profile);

    // Guardar contraseña
    await authProvider.setPassword(_passwordController.text);

    // Marcar onboarding como completado
    await settingsProvider.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator (oculto en página de bienvenida)
            if (_currentPage > 0)
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Text(
                      '${l10n.step} $_currentPage ${l10n.ofPreposition} 5',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_currentPage < 5)
                      TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(5);
                        },
                        child: Text(l10n.skip, style: TextStyle(fontSize: 14.sp)),
                      ),
                  ],
                ),
              ),

            if (_currentPage > 0)
              LinearProgressIndicator(
                value: _currentPage / 5,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(l10n, theme),
                  _buildLanguageSelectionPage(l10n, theme),
                  _buildBusinessInfoPage(l10n, theme),
                  _buildContactInfoPage(l10n, theme),
                  _buildCurrencyPage(l10n, theme),
                  _buildSecurityPage(l10n, theme),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: theme.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(l10n.previous, style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        _currentPage == 0 ? l10n.getStarted : (_currentPage == 5 ? l10n.finish : l10n.next),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PÁGINA 1: BIENVENIDA
  Widget _buildWelcomePage(AppLocalizations l10n, ThemeHelper theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_rounded,
              size: 120.sp,
              color: theme.primary,
            ),
            SizedBox(height: 40.h),
            Text(
              'Proio',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.setupYourBusiness,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PÁGINA 2: SELECCIÓN DE IDIOMA
  Widget _buildLanguageSelectionPage(AppLocalizations l10n, ThemeHelper theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            l10n.selectYourLanguage,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.preferences,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),

          _buildLanguageOption('es', l10n.spanish, '🇪🇸', theme),
          SizedBox(height: 12.h),
          _buildLanguageOption('en', l10n.english, '🇺🇸', theme),
          SizedBox(height: 12.h),
          _buildLanguageOption('pt', l10n.portuguese, '🇧🇷', theme),
          SizedBox(height: 12.h),
          _buildLanguageOption('zh', l10n.chinese, '🇨🇳', theme),
        ],
      ),
    );
  }

  // PÁGINA 3: INFORMACIÓN DEL NEGOCIO
  Widget _buildBusinessInfoPage(AppLocalizations l10n, ThemeHelper theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            l10n.businessInfo,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.setupYourBusiness,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),

          TextField(
            controller: _businessNameController,
            style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.enterBusinessName,
              hintText: l10n.businessNameHint,
              prefixIcon: Icon(Icons.business, color: theme.iconColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            l10n.businessLogo,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          InkWell(
            onTap: _pickLogo,
            child: Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: theme.borderColor, width: 2),
              ),
              child: _logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        File(_logoPath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48.sp, color: theme.iconColor),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.tapToAddLogo,
                          style: TextStyle(fontSize: 14.sp, color: theme.textSecondary),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // PÁGINA 4: INFORMACIÓN DE CONTACTO
  Widget _buildContactInfoPage(AppLocalizations l10n, ThemeHelper theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            l10n.contactInfo,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.optionalField,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              hintText: l10n.phoneHint,
              prefixIcon: Icon(Icons.phone, color: theme.iconColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.emailAddress,
              hintText: l10n.emailHint,
              prefixIcon: Icon(Icons.email, color: theme.iconColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PÁGINA 5: MONEDA
  Widget _buildCurrencyPage(AppLocalizations l10n, ThemeHelper theme) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            l10n.selectYourCurrency,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.preferences,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),

          // Todas las monedas
          ...SettingsProvider.supportedCurrencies.entries.map((entry) {
            final code = entry.key;
            final currencyData = entry.value;
            final name = settingsProvider.getCurrencyNameForCode(code, _selectedLanguage);
            
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildCurrencyOption(
                code,
                name,
                currencyData['symbol']!,
                currencyData['flag']!,
                theme,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // PÁGINA 6: SEGURIDAD
  Widget _buildSecurityPage(AppLocalizations l10n, ThemeHelper theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            l10n.security,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.adminPasswordInfo,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: 40.h),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.createAdminPassword,
              hintText: l10n.passwordHint,
              prefixIcon: Icon(Icons.lock, color: theme.iconColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(fontSize: 16.sp, color: theme.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.confirmPassword,
              hintText: l10n.confirmPasswordHint,
              prefixIcon: Icon(Icons.lock_outline, color: theme.iconColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.passwordTooShort,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag, ThemeHelper theme) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () async {
        await _changeLanguage(code);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryWithOpacity(0.1) : theme.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.primary : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: theme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, String symbol, String flag, ThemeHelper theme) {
    final isSelected = _selectedCurrency == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCurrency = code;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryWithOpacity(0.1) : theme.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.primary : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 12.w),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
