import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class ConfigurarContrasenaScreen extends StatefulWidget {
  const ConfigurarContrasenaScreen({super.key});

  @override
  State<ConfigurarContrasenaScreen> createState() =>
      _ConfigurarContrasenaScreenState();
}

class _ConfigurarContrasenaScreenState
    extends State<ConfigurarContrasenaScreen> {
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _ocultarConfirmar = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _configurarContrasena() async {
    final l10n = AppLocalizations.of(context)!;
    final contrasena = _contrasenaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    // Validaciones
    if (contrasena.isEmpty || confirmar.isEmpty) {
      _mostrarMensaje(l10n.completeAllFields, esError: true);
      return;
    }

    if (contrasena.length < 4) {
      _mostrarMensaje(l10n.passwordMinLength, esError: true);
      return;
    }

    if (contrasena != confirmar) {
      _mostrarMensaje(l10n.passwordsDoNotMatch, esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final exito = await authProvider.configurarContrasenaAdmin(contrasena);

      setState(() => _isLoading = false);

      if (exito) {
        _mostrarMensaje(l10n.passwordConfiguredSuccessfully);
        
        // Esperar un momento y regresar al login
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        _mostrarMensaje(l10n.errorConfiguringPassword, esError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('${l10n.error}: ${e.toString()}', esError: true);
      debugPrint('Error al configurar contraseña: $e');
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 50.sp,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 32.h),

                // Título
                Text(
                  l10n.initialSetup,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  l10n.configureAdminPassword,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Tarjeta de configuración
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensaje informativo
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF283593),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF3949AB)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                l10n.firstTimeMessage,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Campo contraseña
                      TextField(
                        controller: _contrasenaController,
                        obscureText: _ocultarContrasena,
                        enabled: !_isLoading,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: l10n.newPassword,
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: l10n.minimumCharacters,
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarContrasena
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarContrasena = !_ocultarContrasena;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Campo confirmar contraseña
                      TextField(
                        controller: _confirmarController,
                        obscureText: _ocultarConfirmar,
                        enabled: !_isLoading,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: l10n.confirmPasswordLabel,
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: l10n.repeatPassword,
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.lock_clock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarConfirmar
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarConfirmar = !_ocultarConfirmar;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        onSubmitted: (_) => _configurarContrasena(),
                      ),

                      SizedBox(height: 24.h),

                      // Botón configurar
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _configurarContrasena,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF1A237E),
                                )
                              : Text(
                                  l10n.configureAndContinue,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Nota de seguridad
                Text(
                  l10n.savePasswordSecurely,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
