import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../models/business_profile.dart';
import '../providers/business_provider.dart';
import '../services/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _logoPath = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final businessProvider = context.read<BusinessProvider>();
    
    _businessNameController = TextEditingController(
      text: businessProvider.profile?.name ?? '',
    );
    _addressController = TextEditingController(
      text: businessProvider.profile?.address ?? '',
    );
    _phoneController = TextEditingController(
      text: businessProvider.profile?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: businessProvider.profile?.email ?? '',
    );
    _logoPath = businessProvider.profile?.logoPath ?? '';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    
    try {
      final hasPermission = await AppPermissionHandler.requestStoragePermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${l10n.permissionsNeeded}'), // ✅ TRADUCIDO
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _logoPath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.logoSelectedSuccess}'), // ✅ TRADUCIDO
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.errorSelectingImage(e.toString())}'), // ✅ TRADUCIDO
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!; // ✅ AGREGADO
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final businessProvider = context.read<BusinessProvider>();

    final updatedProfile = BusinessProfile(
      name: _businessNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      logoPath: _logoPath,
    );

    final success = await businessProvider.saveProfile(updatedProfile);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.profileUpdatedSuccess}'), // ✅ TRADUCIDO
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.errorSavingProfile}'), // ✅ TRADUCIDO
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.businessProfile, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isLargeScreen ? 32.w : 20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Stack(
                    children: [
                      Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.surfaceColor,
                          border: Border.all(
                            color: theme.primary,
                            width: 3,
                          ),
                        ),
                        child: _logoPath.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(_logoPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.store,
                                      size: 60.sp,
                                      color: theme.iconColorLight,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.store,
                                size: 60.sp,
                                color: theme.iconColorLight,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  l10n.tapToChangeLogo,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              TextFormField(
                controller: _businessNameController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.businessName,
                  labelStyle: TextStyle(color: theme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.store, color: theme.iconColor),
                  filled: true,
                  fillColor: theme.inputFillColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.businessNameRequired;
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _addressController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.address,
                  labelStyle: TextStyle(color: theme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: theme.iconColor),
                  filled: true,
                  fillColor: theme.inputFillColor,
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  labelStyle: TextStyle(color: theme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.phone, color: theme.iconColor),
                  filled: true,
                  fillColor: theme.inputFillColor,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: _emailController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  labelStyle: TextStyle(color: theme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.email, color: theme.iconColor),
                  filled: true,
                  fillColor: theme.inputFillColor,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return l10n.invalidEmail;
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
