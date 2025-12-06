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

  void _loginAsEmployee() {
    final authProvider = context.read<AuthProvider>();
    authProvider.loginAsEmployee();
    _navigateToDashboard();
  }

  void _loginAsAdmin() async {
    final password = _passwordController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (password.isEmpty) {
      _showError(l10n.pleaseEnterPassword);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = authProvider.loginAsAdmin(password);

    setState(() => _isLoading = false);

    if (success) {
      _navigateToDashboard();
    } else {
      _showError(l10n.incorrectPassword);
      _passwordController.clear();
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store,
                  size: 80.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.loginTitle,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.loginSubtitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 48.h),

                // Botón Empleado
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loginAsEmployee,
                    icon: const Icon(Icons.person),
                    label: Text(
                      l10n.loginAsEmployee,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const Text('O', style: TextStyle(color: Colors.grey)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24.h),

                Text(
                  l10n.administrator,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  onSubmitted: (_) => _loginAsAdmin(),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loginAsAdmin,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.admin_panel_settings),
                    label: Text(
                      _isLoading ? l10n.verifying : l10n.loginAsAdmin,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.defaultPassword,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
