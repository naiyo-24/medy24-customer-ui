import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RetailerSignupScreen extends ConsumerStatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  ConsumerState<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends ConsumerState<RetailerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _shopController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).registerRetailer(
      phone: '+91${_phoneController.text.trim()}',
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      ownerName: _ownerController.text.trim(),
      shopName: _shopController.text.trim(),
      address: _addressController.text.trim(),
      latitude: 0.0, // Hardcoded for demo
      longitude: 0.0,
      licenseNumber: _licenseController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! You can now upload documents from your dashboard or wait for approval.'), backgroundColor: Colors.green),
      );
      context.go('/retailer-login');
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
        title: Text('Pharmacy Registration', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Shop Details', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Pharmacy Name', _shopController, Iconsax.shop, isRequired: true),
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
              Text('License Information', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Drug License Number', _licenseController, Iconsax.document, isRequired: true),
              
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Register Pharmacy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
