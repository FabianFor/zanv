import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAsAdmin() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;

    if (password.isEmpty) {
      _showMessage(l10n.pleaseEnterPassword, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    // ✅ MÉTODO CORRECTO: loginAdmin
    final isValid = await authProvider.loginAdmin(password);

    setState(() => _isLoading = false);

    if (isValid) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      _showMessage(l10n.incorrectPassword, isError: true);
    }
  }

  Future<void> _continueAsUser() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    // ✅ MÉTODO CORRECTO: loginUsuario
    await authProvider.loginUsuario();

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // ✅ RESPONSIVE
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenHeight < 700;
    final isSmall = screenHeight < 800;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.w : (isVerySmall ? 20.w : 24.w),
              vertical: isVerySmall ? 16.h : 24.h,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 450.w : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ LOGO RESPONSIVO
                  Container(
                    width: isVerySmall ? 100.w : (isSmall ? 120.w : 140.w),
                    height: isVerySmall ? 100.w : (isSmall ? 120.w : 140.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/logo2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: isVerySmall ? 24.h : (isSmall ? 30.h : 36.h)),

                  // TÍTULO
                  Text(
                    l10n.proioApp,
                    style: TextStyle(
                      fontSize: isVerySmall ? 28.sp : (isSmall ? 32.sp : 36.sp),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isVerySmall ? 6.h : 8.h),

                  Text(
                    l10n.businessManagementSystem,
                    style: TextStyle(
                      fontSize: isVerySmall ? 14.sp : (isSmall ? 16.sp : 18.sp),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isVerySmall ? 32.h : (isSmall ? 40.h : 48.h)),

                  // ✅ TARJETA DE LOGIN RESPONSIVA
                  Container(
                    padding: EdgeInsets.all(isVerySmall ? 20.w : (isSmall ? 24.w : 28.w)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // TÍTULO SECCIÓN
                        Text(
                          l10n.loginAsAdministrator,
                          style: TextStyle(
                            fontSize: isVerySmall ? 18.sp : (isSmall ? 20.sp : 22.sp),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A5F),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isVerySmall ? 20.h : (isSmall ? 24.h : 28.h)),

                        // ✅ CAMPO DE CONTRASEÑA RESPONSIVO
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !_isLoading,
                          style: TextStyle(
                            fontSize: isVerySmall ? 14.sp : 16.sp,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            labelStyle: TextStyle(
                              fontSize: isVerySmall ? 13.sp : 15.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: const Color(0xFF1E3A5F),
                              size: isVerySmall ? 20.sp : 24.sp,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                                size: isVerySmall ? 20.sp : 24.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF1E3A5F),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: isVerySmall ? 14.h : 16.h,
                            ),
                          ),
                          onSubmitted: (_) => _loginAsAdmin(),
                        ),

                        SizedBox(height: isVerySmall ? 20.h : (isSmall ? 24.h : 28.h)),

                        // ✅ BOTÓN LOGIN ADMIN RESPONSIVO
                        SizedBox(
                          height: isVerySmall ? 50.h : (isSmall ? 54.h : 58.h),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginAsAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      l10n.loginButton,
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 15.sp : (isSmall ? 16.sp : 18.sp),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: isVerySmall ? 16.h : 20.h),

                        // DIVISOR
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'o',
                                style: TextStyle(
                                  fontSize: isVerySmall ? 13.sp : 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),

                        SizedBox(height: isVerySmall ? 16.h : 20.h),

                        // ✅ BOTÓN USUARIO RESPONSIVO
                        SizedBox(
                          height: isVerySmall ? 50.h : (isSmall ? 54.h : 58.h),
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _continueAsUser,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E3A5F),
                              side: const BorderSide(
                                color: Color(0xFF1E3A5F),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.continueAsUser,
                                style: TextStyle(
                                  fontSize: isVerySmall ? 15.sp : (isSmall ? 16.sp : 18.sp),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isVerySmall ? 16.h : (isSmall ? 20.h : 24.h)),

                  // NOTA INFORMATIVA
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      l10n.userOnlyMode,
                      style: TextStyle(
                        fontSize: isVerySmall ? 11.sp : 13.sp,
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isVerySmall ? 8.h : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
