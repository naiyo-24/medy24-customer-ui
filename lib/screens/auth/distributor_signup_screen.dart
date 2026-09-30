import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DistributorSignupScreen extends ConsumerStatefulWidget {
  const DistributorSignupScreen({super.key});

  @override
  ConsumerState<DistributorSignupScreen> createState() => _DistributorSignupScreenState();
}

class _DistributorSignupScreenState extends ConsumerState<DistributorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _companyController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _emailController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();

  File? _license20b;
  File? _license21b;
  bool _obscurePassword = true;

  Future<void> _pickImage(bool is20b) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (is20b) {
          _license20b = File(pickedFile.path);
        } else {
          _license21b = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_license20b == null || _license21b == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both Form 20B and Form 21B licenses'), backgroundColor: AppColors.error),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).registerDistributor(
      companyName: _companyController.text.trim(),
      ownerName: _ownerController.text.trim(),
      phone: '+91${_phoneController.text.trim()}',
      password: _passwordController.text,
      address: _addressController.text.trim(),
      latitude: 0.0, // Hardcoded for demo, normally fetched via location package
      longitude: 0.0,
      gstinNo: _gstinController.text.trim(),
      panNumber: _panController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      bankAccountNo: _bankAccountController.text.trim().isEmpty ? null : _bankAccountController.text.trim(),
      bankIfscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
      license20bDoc: _license20b!,
      license21bDoc: _license21b!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration submitted! Pending Super Admin verification.'), backgroundColor: Colors.green),
      );
      context.go('/distributor-login');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Registration failed', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Distributor Onboarding', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Business Details', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Company Name', _companyController, Iconsax.building, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Owner Name', _ownerController, Iconsax.user, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', _phoneController, Iconsax.mobile, isPhone: true, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Password', _passwordController, Iconsax.lock, isPassword: true, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Email Address (Optional)', _emailController, Iconsax.sms),
              const SizedBox(height: 12),
              _buildTextField('Complete Address', _addressController, Iconsax.location, isRequired: true, maxLines: 3),
              
              const SizedBox(height: 32),
              Text('Tax & Compliance', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('GSTIN Number', _gstinController, Iconsax.receipt, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('PAN Number', _panController, Iconsax.card, isRequired: true),
              
              const SizedBox(height: 32),
              Text('Bank Details (Optional)', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Bank Account Number', _bankAccountController, Iconsax.bank),
              const SizedBox(height: 12),
              _buildTextField('Bank IFSC Code', _ifscController, Iconsax.code),

              const SizedBox(height: 32),
              Text('Licenses (Required)', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildFilePicker('Wholesale Drug License (Form 20B)', _license20b, () => _pickImage(true)),
              const SizedBox(height: 12),
              _buildFilePicker('Wholesale Drug License (Form 21B)', _license21b, () => _pickImage(false)),
              
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Submit Application', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    bool isRequired = false, 
    bool isPhone = false,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          maxLength: isPhone ? 10 : null,
          obscureText: isPassword && _obscurePassword,
          maxLines: isPassword ? 1 : maxLines,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (isPhone && value.length != 10) return 'Enter 10 digit number';
            return null;
          } : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            prefixText: isPhone ? '+91 ' : null,
            counterText: '',
            suffixIcon: isPassword ? IconButton(
              icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: file != null ? Colors.green : AppColors.divider, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(file != null ? Iconsax.tick_circle : Iconsax.document_upload, color: file != null ? Colors.green : Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(file != null ? 'File selected' : 'Tap to upload image', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
